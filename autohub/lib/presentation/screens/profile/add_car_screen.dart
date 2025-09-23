import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/app_providers.dart';
import '../../../core/utils/constants.dart';
import 'package:uuid/uuid.dart';

class AddCarScreen extends ConsumerStatefulWidget {
  const AddCarScreen({super.key});

  @override
  ConsumerState<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends ConsumerState<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _modificationController = TextEditingController();

  final List<String> _modifications = [];
  final List<XFile> _selectedImages = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _descriptionController.dispose();
    _modificationController.dispose();
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

  void _addModification() {
    if (_modificationController.text.trim().isNotEmpty) {
      setState(() {
        _modifications.add(_modificationController.text.trim());
        _modificationController.clear();
      });
    }
  }

  void _removeModification(int index) {
    setState(() {
      _modifications.removeAt(index);
    });
  }

  Future<void> _addCar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final firestoreService = ref.read(firestoreServiceProvider);

      // Upload images
      List<String> imageUrls = [];
      for (int i = 0; i < _selectedImages.length; i++) {
        final imageUrl = await firestoreService.uploadImageFromXFile(
          _selectedImages[i],
          '${AppConstants.carImagesPath}/${currentUser.id}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
        );
        imageUrls.add(imageUrl);
      }

      // Create car model
      final car = CarModel(
        id: const Uuid().v4(),
        make: _makeController.text.trim(),
        model: _modelController.text.trim(),
        year: int.parse(_yearController.text.trim()),
        color: _colorController.text.trim().isNotEmpty
            ? _colorController.text.trim()
            : null,
        imageUrls: imageUrls,
        modifications: _modifications,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        createdAt: DateTime.now(),
      );

      // Update user with new car
      final updatedUser = currentUser.copyWith(
        cars: [...currentUser.cars, car],
        updatedAt: DateTime.now(),
      );

      await firestoreService.updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Car added to your garage!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add car: ${e.toString()}'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Car'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _addCar,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Add'),
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
              // Car images
              if (_selectedImages.isNotEmpty) ...[
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: kIsWeb
                                ? Image.network(
                                    _selectedImages[index].path,
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.image, size: 100);
                                    },
                                  )
                                : Image.file(
                                    File(_selectedImages[index].path),
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImages.removeAt(index);
                                });
                              },
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
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Image picker button
              OutlinedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.photo_library),
                label: Text(
                  _selectedImages.isNotEmpty ? 'Add More Photos' : 'Add Photos',
                ),
              ),

              const SizedBox(height: 24),

              // Make
              TextFormField(
                controller: _makeController,
                decoration: const InputDecoration(
                  labelText: 'Make',
                  prefixIcon: Icon(Icons.directions_car),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter car make';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Model
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Model',
                  prefixIcon: Icon(Icons.directions_car),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter car model';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Year
              TextFormField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Year',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter car year';
                  }
                  final year = int.tryParse(value.trim());
                  if (year == null ||
                      year < 1900 ||
                      year > DateTime.now().year + 1) {
                    return 'Please enter a valid year';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Color
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: 'Color (Optional)',
                  prefixIcon: Icon(Icons.palette),
                ),
              ),

              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  prefixIcon: Icon(Icons.description),
                  hintText: 'Tell us about your car...',
                ),
              ),

              const SizedBox(height: 24),

              // Modifications
              Text(
                'Modifications',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _modificationController,
                      decoration: const InputDecoration(
                        labelText: 'Add modification',
                        hintText: 'e.g., Cold air intake',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addModification,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Modifications list
              if (_modifications.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _modifications.asMap().entries.map((entry) {
                    return Chip(
                      label: Text(entry.value),
                      onDeleted: () => _removeModification(entry.key),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Add car button
              ElevatedButton(
                onPressed: _isLoading ? null : _addCar,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Add Car to Garage'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
