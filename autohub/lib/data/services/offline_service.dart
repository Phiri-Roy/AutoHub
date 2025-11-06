import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../models/post_model.dart';

class OfflineService {
  static Database? _database;
  static const String _databaseName = 'autohub_offline.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String _usersTable = 'users';
  static const String _eventsTable = 'events';
  static const String _postsTable = 'posts';
  static const String _syncQueueTable = 'sync_queue';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE $_usersTable (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        username TEXT NOT NULL,
        profile_photo_url TEXT,
        cars TEXT,
        followers_count INTEGER DEFAULT 0,
        following_count INTEGER DEFAULT 0,
        total_wins INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    // Events table
    await db.execute('''
      CREATE TABLE $_eventsTable (
        id TEXT PRIMARY KEY,
        event_name TEXT NOT NULL,
        description TEXT,
        location TEXT NOT NULL,
        event_date TEXT NOT NULL,
        created_by TEXT NOT NULL,
        attendee_count INTEGER DEFAULT 0,
        attendees TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    // Posts table
    await db.execute('''
      CREATE TABLE $_postsTable (
        id TEXT PRIMARY KEY,
        content TEXT NOT NULL,
        image_urls TEXT,
        posted_by TEXT NOT NULL,
        like_count INTEGER DEFAULT 0,
        comment_count INTEGER DEFAULT 0,
        likes TEXT,
        comments TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    // Sync queue table
    await db.execute('''
      CREATE TABLE $_syncQueueTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        record_id TEXT NOT NULL,
        action TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // User operations
  static Future<void> saveUser(UserModel user) async {
    final db = await database;
    await db.insert(
      _usersTable,
      _userToMap(user),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<UserModel?> getUser(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _usersTable,
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (maps.isNotEmpty) {
      return _userFromMap(maps.first);
    }
    return null;
  }

  static Future<List<UserModel>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_usersTable);
    return maps.map((map) => _userFromMap(map)).toList();
  }

  // Event operations
  static Future<void> saveEvent(EventModel event) async {
    final db = await database;
    await db.insert(
      _eventsTable,
      _eventToMap(event),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<EventModel?> getEvent(String eventId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _eventsTable,
      where: 'id = ?',
      whereArgs: [eventId],
    );

    if (maps.isNotEmpty) {
      return _eventFromMap(maps.first);
    }
    return null;
  }

  static Future<List<EventModel>> getAllEvents() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_eventsTable);
    return maps.map((map) => _eventFromMap(map)).toList();
  }

  // Post operations
  static Future<void> savePost(PostModel post) async {
    final db = await database;
    await db.insert(
      _postsTable,
      _postToMap(post),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<PostModel?> getPost(String postId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _postsTable,
      where: 'id = ?',
      whereArgs: [postId],
    );

    if (maps.isNotEmpty) {
      return _postFromMap(maps.first);
    }
    return null;
  }

  static Future<List<PostModel>> getAllPosts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_postsTable);
    return maps.map((map) => _postFromMap(map)).toList();
  }

  // Sync queue operations
  static Future<void> addToSyncQueue(
    String tableName,
    String recordId,
    String action,
    Map<String, dynamic> data,
  ) async {
    final db = await database;
    await db.insert(_syncQueueTable, {
      'table_name': tableName,
      'record_id': recordId,
      'action': action,
      'data': jsonEncode(data),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>> getSyncQueue() async {
    final db = await database;
    return await db.query(_syncQueueTable, orderBy: 'created_at ASC');
  }

  static Future<void> removeFromSyncQueue(int id) async {
    final db = await database;
    await db.delete(_syncQueueTable, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> clearSyncQueue() async {
    final db = await database;
    await db.delete(_syncQueueTable);
  }

  // Helper methods
  static Map<String, dynamic> _userToMap(UserModel user) {
    return {
      'id': user.id,
      'email': user.email,
      'username': user.username,
      'profile_photo_url': user.profilePhotoUrl,
      'cars': jsonEncode(user.cars.map((car) => _carToMap(car)).toList()),
      'followers_count': user.followersCount,
      'following_count': user.followingCount,
      'total_wins': user.totalWins,
      'created_at': user.createdAt.toIso8601String(),
      'updated_at': user.updatedAt.toIso8601String(),
      'is_synced': 0,
    };
  }

  static UserModel _userFromMap(Map<String, dynamic> map) {
    final carsList = jsonDecode(map['cars'] ?? '[]') as List;
    final cars = carsList.map((carMap) => _carFromMap(carMap)).toList();

    return UserModel(
      id: map['id'],
      email: map['email'],
      username: map['username'],
      profilePhotoUrl: map['profile_photo_url'],
      cars: cars,
      followersCount: map['followers_count'] ?? 0,
      followingCount: map['following_count'] ?? 0,
      totalWins: map['total_wins'] ?? 0,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  static Map<String, dynamic> _eventToMap(EventModel event) {
    return {
      'id': event.id,
      'event_name': event.eventName,
      'description': event.description,
      'location': event.location,
      'event_date': event.eventDate.toIso8601String(),
      'created_by': event.createdBy,
      'attendee_count': event.attendeeCount,
      'attendees': jsonEncode(event.attendees),
      'created_at': event.createdAt.toIso8601String(),
      'is_synced': 0,
    };
  }

  static EventModel _eventFromMap(Map<String, dynamic> map) {
    final attendeesList = jsonDecode(map['attendees'] ?? '[]') as List;
    final attendees = attendeesList.cast<String>();

    return EventModel(
      id: map['id'],
      eventName: map['event_name'],
      description: map['description'] ?? '',
      location: map['location'],
      eventDate: DateTime.parse(map['event_date']),
      createdBy: map['created_by'],
      attendees: attendees,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  static Map<String, dynamic> _postToMap(PostModel post) {
    return {
      'id': post.id,
      'content': post.content,
      'image_urls': jsonEncode(post.imageUrls),
      'posted_by': post.postedBy,
      'like_count': post.likeCount,
      'comment_count': post.commentCount,
      'likes': jsonEncode(post.likes),
      'comments': jsonEncode(
        post.comments.map((c) => _commentToMap(c)).toList(),
      ),
      'created_at': post.timestamp.toIso8601String(),
      'is_synced': 0,
    };
  }

  static PostModel _postFromMap(Map<String, dynamic> map) {
    final imageUrlsList = jsonDecode(map['image_urls'] ?? '[]') as List;
    final imageUrls = imageUrlsList.cast<String>();

    final likesList = jsonDecode(map['likes'] ?? '[]') as List;
    final likes = likesList.cast<String>();

    final commentsList = jsonDecode(map['comments'] ?? '[]') as List;
    final comments = commentsList
        .map((commentMap) => _commentFromMap(commentMap))
        .toList();

    return PostModel(
      id: map['id'],
      content: map['content'],
      imageUrls: imageUrls,
      postedBy: map['posted_by'],
      likes: likes,
      comments: comments,
      timestamp: DateTime.parse(map['created_at']),
    );
  }

  static Map<String, dynamic> _carToMap(CarModel car) {
    return {
      'id': car.id,
      'make': car.make,
      'model': car.model,
      'year': car.year,
      'color': car.color,
      'image_urls': jsonEncode(car.imageUrls),
      'modifications': jsonEncode(car.modifications),
      'description': car.description,
      'created_at': car.createdAt.toIso8601String(),
    };
  }

  static CarModel _carFromMap(Map<String, dynamic> map) {
    final imageUrlsList = jsonDecode(map['image_urls'] ?? '[]') as List;
    final imageUrls = imageUrlsList.cast<String>();

    final modificationsList = jsonDecode(map['modifications'] ?? '[]') as List;
    final modifications = modificationsList.cast<String>();

    return CarModel(
      id: map['id'],
      make: map['make'],
      model: map['model'],
      year: map['year'],
      color: map['color'],
      imageUrls: imageUrls,
      modifications: modifications,
      description: map['description'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  static Map<String, dynamic> _commentToMap(CommentModel comment) {
    return {
      'id': comment.id,
      'content': comment.content,
      'posted_by': comment.postedBy,
      'timestamp': comment.timestamp.toIso8601String(),
      'likes': jsonEncode(comment.likes),
    };
  }

  static CommentModel _commentFromMap(Map<String, dynamic> map) {
    final likesList = jsonDecode(map['likes'] ?? '[]') as List;
    final likes = likesList.cast<String>();

    return CommentModel(
      id: map['id'],
      content: map['content'],
      postedBy: map['posted_by'],
      timestamp: DateTime.parse(map['timestamp']),
      likes: likes,
    );
  }

  // Utility methods
  static Future<bool> isOnline() async {
    // First, try Firebase connectivity if available
    // Since login requires internet, if we can access Firebase, we're online
    try {
      final firebaseService = await _checkFirebaseConnectivity();
      if (firebaseService != null) {
        return firebaseService;
      }
    } catch (e) {
      print('Firebase connectivity check failed: $e');
    }
    
    // Fallback to DNS/HTTP checks
    try {
      // Use a timeout to prevent hanging
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      // If DNS lookup fails, try a simple HTTP connection as fallback
      try {
        final client = HttpClient();
        client.connectionTimeout = const Duration(seconds: 5);
        final request = await client.getUrl(Uri.parse('https://www.google.com'));
        final response = await request.close().timeout(const Duration(seconds: 5));
        client.close();
        return response.statusCode == 200 || response.statusCode == 301 || response.statusCode == 302;
      } catch (e2) {
        // If both methods fail, assume offline
        return false;
      }
    }
  }

  // Check Firebase connectivity by attempting a lightweight operation
  static Future<bool?> _checkFirebaseConnectivity() async {
    try {
      // Check if Firestore is initialized and accessible
      // Since login requires internet, if we can access Firestore, we're online
      final firestore = FirebaseFirestore.instance;
      
      // Try a lightweight Firestore operation with timeout
      // This will fail if truly offline, succeed if online
      // Using a minimal query to test connectivity
      await firestore
          .collection('_metadata') // Use a lightweight collection
          .limit(1)
          .get(const GetOptions(source: Source.server)) // Force server check
          .timeout(const Duration(seconds: 3));
      
      return true; // If we got here, Firebase is accessible
    } catch (e) {
      // If Firebase operation fails, it might be offline or uninitialized
      // Return null to fallback to DNS/HTTP check
      return null;
    }
  }

  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete(_usersTable);
    await db.delete(_eventsTable);
    await db.delete(_postsTable);
    await db.delete(_syncQueueTable);
  }
}
