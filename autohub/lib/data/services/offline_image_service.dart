import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

/// Service to handle offline image storage and queue for sync
class OfflineImageService {
  // Store local image paths temporarily for offline usage
  static final Map<String, String> _localImagePaths = {};

  /// Save image locally and return the local path
  static Future<String> saveImageLocally(
    String imageId,
    Uint8List imageBytes,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(path.join(directory.path, 'offline_images'));

      // Create directory if it doesn't exist
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final filePath = path.join(imagesDir.path, '$imageId.jpg');
      final file = File(filePath);

      await file.writeAsBytes(imageBytes);

      _localImagePaths[imageId] = filePath;

      print('✅ Image saved locally: $filePath');
      return filePath;
    } catch (e) {
      print('❌ Error saving image locally: $e');
      rethrow;
    }
  }

  /// Save XFile to local storage
  static Future<String> saveXFileLocally(String imageId, XFile xFile) async {
    try {
      if (kIsWeb) {
        // Web: convert to Uint8List
        final bytes = await xFile.readAsBytes();
        return await saveImageLocally(imageId, bytes);
      } else {
        // Mobile: copy file directly
        final directory = await getApplicationDocumentsDirectory();
        final imagesDir = Directory(
          path.join(directory.path, 'offline_images'),
        );

        if (!await imagesDir.exists()) {
          await imagesDir.create(recursive: true);
        }

        final filePath = path.join(imagesDir.path, '$imageId.jpg');
        final file = File(filePath);

        await file.writeAsBytes(await xFile.readAsBytes());

        _localImagePaths[imageId] = filePath;

        print('✅ Image saved locally: $filePath');
        return filePath;
      }
    } catch (e) {
      print('❌ Error saving XFile locally: $e');
      rethrow;
    }
  }

  /// Get local image path by ID
  static String? getLocalImagePath(String imageId) {
    return _localImagePaths[imageId];
  }

  /// Get File object from local path
  static Future<File?> getLocalImageFile(String imageId) async {
    final localPath = getLocalImagePath(imageId);
    if (localPath == null) return null;

    final file = File(localPath);
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  /// Check if image exists locally
  static Future<bool> imageExistsLocally(String imageId) async {
    final localPath = getLocalImagePath(imageId);
    if (localPath == null) return false;

    return await File(localPath).exists();
  }

  /// Delete local image
  static Future<void> deleteLocalImage(String imageId) async {
    try {
      final localPath = getLocalImagePath(imageId);
      if (localPath != null) {
        final file = File(localPath);
        if (await file.exists()) {
          await file.delete();
          _localImagePaths.remove(imageId);
          print('✅ Local image deleted: $localPath');
        }
      }
    } catch (e) {
      print('❌ Error deleting local image: $e');
    }
  }

  /// Clear all local images (cleanup)
  static Future<void> clearAllLocalImages() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(path.join(directory.path, 'offline_images'));

      if (await imagesDir.exists()) {
        await imagesDir.delete(recursive: true);
        _localImagePaths.clear();
        print('✅ All local images cleared');
      }
    } catch (e) {
      print('❌ Error clearing local images: $e');
    }
  }

  /// Get total size of offline images directory
  static Future<int> getOfflineImagesSize() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(path.join(directory.path, 'offline_images'));

      if (!await imagesDir.exists()) {
        return 0;
      }

      int totalSize = 0;
      await for (final file in imagesDir.list()) {
        if (file is File) {
          totalSize += await file.length();
        }
      }

      return totalSize;
    } catch (e) {
      print('❌ Error calculating offline images size: $e');
      return 0;
    }
  }

  /// Get list of all local image IDs
  static List<String> getAllLocalImageIds() {
    return _localImagePaths.keys.toList();
  }

  /// Generate a unique image ID
  static String generateImageId(String userId) {
    return '${userId}_${DateTime.now().millisecondsSinceEpoch}';
  }
}



