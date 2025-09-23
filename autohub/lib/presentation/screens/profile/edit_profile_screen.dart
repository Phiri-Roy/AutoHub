import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../providers/app_providers.dart';
import '../../../core/utils/constants.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  XFile? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser != null) {
      _usernameController.text = currentUser.username;
      _bioController.text = currentUser.bio ?? '';
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() => _selectedImage = image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final firestoreService = ref.read(firestoreServiceProvider);
      String? imageUrl = currentUser.profilePhotoUrl;

      // Upload new image if selected
      if (_selectedImage != null) {
        imageUrl = await firestoreService.uploadImageFromXFile(
          _selectedImage!,
          '${AppConstants.profileImagesPath}/${currentUser.id}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }

      // Update user model
      final updatedUser = currentUser.copyWith(
        username: _usernameController.text.trim(),
        bio: _bioController.text.trim(),
        profilePhotoUrl: imageUrl,
        updatedAt: DateTime.now(),
      );

      await firestoreService.updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
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
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updateProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: currentUser.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Please log in'));
          }

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile photo
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: _selectedImage != null
                            ? ClipOval(
                                child: kIsWeb
                                    ? Image.network(
                                        _selectedImage!.path,
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.person,
                                                size: 60,
                                                color: Colors.white,
                                              );
                                            },
                                      )
                                    : Image.file(
                                        File(_selectedImage!.path),
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                              )
                            : user.profilePhotoUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  user.profilePhotoUrl!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.white,
                                    );
                                  },
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.white,
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Username field
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a username';
                      }
                      if (value.length > AppConstants.maxUsernameLength) {
                        return 'Username must be less than ${AppConstants.maxUsernameLength} characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Bio field
                  TextFormField(
                    controller: _bioController,
                    maxLines: 3,
                    maxLength: AppConstants.maxBioLength,
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                      prefixIcon: Icon(Icons.description),
                      hintText: 'Tell us about yourself...',
                    ),
                    validator: (value) {
                      if (value != null &&
                          value.length > AppConstants.maxBioLength) {
                        return 'Bio is too long';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  // Update button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateProfile,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Update Profile'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
