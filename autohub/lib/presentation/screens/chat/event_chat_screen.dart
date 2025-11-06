import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/app_providers.dart';

class ChatMessage {
  final String id;
  final String eventId;
  final String userId;
  final String username;
  final String? userPhotoUrl;
  final String message;
  final DateTime timestamp;
  final MessageType type;

  ChatMessage({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.username,
    this.userPhotoUrl,
    required this.message,
    required this.timestamp,
    this.type = MessageType.text,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'userId': userId,
      'username': username,
      'userPhotoUrl': userPhotoUrl,
      'message': message,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'type': type.name,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      eventId: map['eventId'],
      userId: map['userId'],
      username: map['username'],
      userPhotoUrl: map['userPhotoUrl'],
      message: map['message'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      type: MessageType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MessageType.text,
      ),
    );
  }
}

enum MessageType { text, image, system }

class ChatService {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  static const String _messagesPath = 'event_messages';

  static Future<void> sendMessage({
    required String eventId,
    required String userId,
    required String username,
    String? userPhotoUrl,
    required String message,
    MessageType type = MessageType.text,
  }) async {
    final messageId = _database.ref().child(_messagesPath).push().key!;
    final chatMessage = ChatMessage(
      id: messageId,
      eventId: eventId,
      userId: userId,
      username: username,
      userPhotoUrl: userPhotoUrl,
      message: message,
      timestamp: DateTime.now(),
      type: type,
    );

    await _database
        .ref()
        .child(_messagesPath)
        .child(eventId)
        .child(messageId)
        .set(chatMessage.toMap());
  }

  static Stream<List<ChatMessage>> getMessages(String eventId) {
    return _database
        .ref()
        .child(_messagesPath)
        .child(eventId)
        .orderByChild('timestamp')
        .onValue
        .map((event) {
          if (event.snapshot.value == null) return <ChatMessage>[];

          final Map<dynamic, dynamic> data =
              event.snapshot.value as Map<dynamic, dynamic>;
          return data.values
              .map(
                (messageData) =>
                    ChatMessage.fromMap(Map<String, dynamic>.from(messageData)),
              )
              .toList();
        });
  }

  static Future<void> deleteMessage(String eventId, String messageId) async {
    await _database
        .ref()
        .child(_messagesPath)
        .child(eventId)
        .child(messageId)
        .remove();
  }

  static Future<void> sendSystemMessage(String eventId, String message) async {
    await sendMessage(
      eventId: eventId,
      userId: 'system',
      username: 'System',
      message: message,
      type: MessageType.system,
    );
  }
}

final chatMessagesProvider = StreamProvider.family<List<ChatMessage>, String>((
  ref,
  eventId,
) {
  return ChatService.getMessages(eventId);
});

class EventChatScreen extends ConsumerStatefulWidget {
  final String eventId;
  final String eventName;

  const EventChatScreen({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  ConsumerState<EventChatScreen> createState() => _EventChatScreenState();
}

class _EventChatScreenState extends ConsumerState<EventChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final messages = ref.watch(chatMessagesProvider(widget.eventId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat - ${widget.eventName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showEventInfo(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.when(
              data: (messageList) {
                if (messageList.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Start the conversation!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messageList.length,
                  itemBuilder: (context, index) {
                    final message = messageList[index];
                    final isCurrentUser =
                        currentUser.value?.id == message.userId;
                    final isSystemMessage = message.type == MessageType.system;

                    if (isSystemMessage) {
                      return _buildSystemMessage(message);
                    }

                    return _buildMessageBubble(
                      message,
                      isCurrentUser,
                      currentUser,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text('Error loading messages: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(chatMessagesProvider(widget.eventId));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildMessageInput(currentUser),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    ChatMessage message,
    bool isCurrentUser,
    AsyncValue<UserModel?> currentUser,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: message.userPhotoUrl != null
                  ? CachedNetworkImageProvider(message.userPhotoUrl!)
                  : null,
              child: message.userPhotoUrl == null
                  ? Text(
                      message.username.isNotEmpty
                          ? message.username[0].toUpperCase()
                          : 'U',
                    )
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: !isCurrentUser
                    ? Border.all(color: Theme.of(context).colorScheme.outline)
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isCurrentUser)
                    Text(
                      message.username,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  Text(
                    message.message,
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('h:mm a').format(message.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isCurrentUser
                          ? Colors.white.withOpacity(0.7)
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundImage: currentUser.value?.profilePhotoUrl != null
                  ? CachedNetworkImageProvider(
                      currentUser.value!.profilePhotoUrl!,
                    )
                  : null,
              child: currentUser.value?.profilePhotoUrl == null
                  ? Text(
                      currentUser.value?.username.isNotEmpty == true
                          ? currentUser.value!.username[0].toUpperCase()
                          : 'U',
                    )
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSystemMessage(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            message.message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput(AsyncValue<UserModel?> currentUser) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _sendMessage(currentUser),
            icon: const Icon(Icons.send),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(AsyncValue<UserModel?> currentUser) {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final user = currentUser.value;
    if (user == null) return;

    ChatService.sendMessage(
      eventId: widget.eventId,
      userId: user.id,
      username: user.username,
      userPhotoUrl: user.profilePhotoUrl,
      message: message,
    );

    _messageController.clear();
  }

  void _showEventInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chat Info - ${widget.eventName}'),
        content: const Text(
          'This is a real-time chat for event participants. '
          'Messages are visible to all attendees of this event.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class ChatButton extends ConsumerWidget {
  final String eventId;
  final String eventName;

  const ChatButton({super.key, required this.eventId, required this.eventName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.chat),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                EventChatScreen(eventId: eventId, eventName: eventName),
          ),
        );
      },
      tooltip: 'Open chat',
    );
  }
}
