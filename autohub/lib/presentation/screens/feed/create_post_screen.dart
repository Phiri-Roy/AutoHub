import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../data/models/post_model.dart';
import '../../../providers/app_providers.dart';
import '../../../core/utils/constants.dart';
import 'package:uuid/uuid.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final List<XFile> _selectedImages = [];
  bool _isLoading = false;
  String _loadingMessage = 'Creating post...';

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();

      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick images: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to take photo: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _removeImage(int index) async {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _createPost() async {
    if (!_formKey.currentState!.validate()) return;
    if (_contentController.text.trim().isEmpty && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add some content or images')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('Starting post creation...');

      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      print('User authenticated: ${currentUser.id}');

      final firestoreService = ref.read(firestoreServiceProvider);
      List<String> imageUrls = [];

      // Upload images if any
      if (_selectedImages.isNotEmpty) {
        print('Uploading ${_selectedImages.length} images...');
        setState(() => _loadingMessage = 'Uploading images...');

        for (int i = 0; i < _selectedImages.length; i++) {
          print('Uploading image ${i + 1}/${_selectedImages.length}');
          setState(
            () => _loadingMessage =
                'Uploading image ${i + 1}/${_selectedImages.length}...',
          );

          try {
            final imageUrl = await firestoreService
                .uploadImageFromXFile(
                  _selectedImages[i],
                  '${AppConstants.postImagesPath}/${currentUser.id}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
                )
                .timeout(
                  const Duration(minutes: 2),
                  onTimeout: () {
                    throw Exception('Image upload timed out after 2 minutes');
                  },
                );
            imageUrls.add(imageUrl);
            print('Image ${i + 1} uploaded successfully: $imageUrl');
          } catch (uploadError) {
            print('Failed to upload image ${i + 1}: $uploadError');
            throw Exception('Failed to upload image ${i + 1}: $uploadError');
          }
        }
        print('All images uploaded successfully');
      }

      // Create post
      print('Creating post in Firestore...');
      setState(() => _loadingMessage = 'Creating post...');

      final post = PostModel(
        id: const Uuid().v4(),
        content: _contentController.text.trim(),
        imageUrls: imageUrls,
        postedBy: currentUser.id,
        timestamp: DateTime.now(),
      );

      await firestoreService
          .createPost(post)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Post creation timed out after 30 seconds');
            },
          );
      print('Post created successfully in Firestore');

      // Create notifications for followers
      if (imageUrls.isNotEmpty || _contentController.text.trim().isNotEmpty) {
        await firestoreService.createPostNotification(
          currentUser.id,
          currentUser.username,
          currentUser.profilePhotoUrl,
          post.id,
          _contentController.text.trim().isNotEmpty
              ? _contentController.text.trim()
              : 'Shared ${imageUrls.length} image(s)',
        );
        print('Post notifications sent to followers');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error creating post: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create post: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createPost,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Post'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Content text field
              TextFormField(
                controller: _contentController,
                maxLines: 5,
                maxLength: AppConstants.maxPostLength,
                decoration: const InputDecoration(
                  hintText: "What's on your mind?",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != null &&
                      value.length > AppConstants.maxPostLength) {
                    return 'Post content is too long';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Image picker buttons
              kIsWeb
                  ? OutlinedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Select Images'),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickImages,
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Gallery'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickImageFromCamera,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Camera'),
                          ),
                        ),
                      ],
                    ),

              const SizedBox(height: 16),

              // Selected images
              if (_selectedImages.isNotEmpty) ...[
                Text(
                  'Selected Images:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: kIsWeb
                                  ? Image.network(
                                      _selectedImages[index].path,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.image,
                                              size: 50,
                                            );
                                          },
                                    )
                                  : Image.file(
                                      File(_selectedImages[index].path),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Post button
              ElevatedButton(
                onPressed: _isLoading ? null : _createPost,
                child: _isLoading
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _loadingMessage,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      )
                    : const Text('Create Post'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
