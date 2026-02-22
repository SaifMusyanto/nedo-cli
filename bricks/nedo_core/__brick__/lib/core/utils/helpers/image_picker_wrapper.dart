import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Result of image picking operation
class ImagePickerResult {
  final File? file;
  final String? path;
  final Uint8List? bytes;
  final String? name;

  const ImagePickerResult({this.file, this.path, this.bytes, this.name});

  bool get hasImage => file != null || bytes != null;
}

/// Wrapper for image_picker with additional functionality
///
/// Example:
/// ```dart
/// final result = await ImagePickerWrapper.pickImage(
///   source: ImageSource.gallery,
///   maxWidth: 800,
///   compressQuality: 70,
/// );
///
/// if (result.hasImage) {
///   // Use result.file or result.bytes
/// }
/// ```
class ImagePickerWrapper {
  static final ImagePicker _picker = ImagePicker();

  /// Pick a single image from gallery or camera
  ///
  /// [source] - Source of the image (gallery or camera)
  /// [maxWidth] - Maximum width of the image (optional)
  /// [maxHeight] - Maximum height of the image (optional)
  /// [compressQuality] - Image quality (0-100, default: 85)
  /// [imageQuality] - Alias for compressQuality for backward compatibility
  static Future<ImagePickerResult?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int compressQuality = 85,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    try {
      final quality = imageQuality ?? compressQuality;

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: quality,
        preferredCameraDevice: preferredCameraDevice,
      );

      if (pickedFile == null) return null;

      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        return ImagePickerResult(
          bytes: bytes,
          name: pickedFile.name,
          path: pickedFile.path,
        );
      } else {
        return ImagePickerResult(
          file: File(pickedFile.path),
          path: pickedFile.path,
          name: pickedFile.name,
        );
      }
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  /// Pick multiple images from gallery
  ///
  /// [maxImages] - Maximum number of images to pick (optional)
  /// [maxWidth] - Maximum width of each image (optional)
  /// [maxHeight] - Maximum height of each image (optional)
  /// [compressQuality] - Image quality (0-100, default: 85)
  static Future<List<ImagePickerResult>> pickMultipleImages({
    int? maxImages,
    double? maxWidth,
    double? maxHeight,
    int compressQuality = 85,
  }) async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: compressQuality,
      );

      if (pickedFiles.isEmpty) return [];

      // Limit number of images if specified
      final filesToProcess = maxImages != null && pickedFiles.length > maxImages
          ? pickedFiles.sublist(0, maxImages)
          : pickedFiles;

      final results = <ImagePickerResult>[];

      for (final file in filesToProcess) {
        if (kIsWeb) {
          final bytes = await file.readAsBytes();
          results.add(
            ImagePickerResult(bytes: bytes, name: file.name, path: file.path),
          );
        } else {
          results.add(
            ImagePickerResult(
              file: File(file.path),
              path: file.path,
              name: file.name,
            ),
          );
        }
      }

      return results;
    } catch (e) {
      print('Error picking multiple images: $e');
      return [];
    }
  }

  /// Pick image from camera
  static Future<ImagePickerResult?> pickFromCamera({
    double? maxWidth,
    double? maxHeight,
    int compressQuality = 85,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) {
    return pickImage(
      source: ImageSource.camera,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      compressQuality: compressQuality,
      preferredCameraDevice: preferredCameraDevice,
    );
  }

  /// Pick image from gallery
  static Future<ImagePickerResult?> pickFromGallery({
    double? maxWidth,
    double? maxHeight,
    int compressQuality = 85,
  }) {
    return pickImage(
      source: ImageSource.gallery,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      compressQuality: compressQuality,
    );
  }

  /// Pick a video from gallery or camera
  ///
  /// [source] - Source of the video (gallery or camera)
  /// [maxDuration] - Maximum duration of the video (optional)
  static Future<ImagePickerResult?> pickVideo({
    required ImageSource source,
    Duration? maxDuration,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickVideo(
        source: source,
        maxDuration: maxDuration,
        preferredCameraDevice: preferredCameraDevice,
      );

      if (pickedFile == null) return null;

      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        return ImagePickerResult(
          bytes: bytes,
          name: pickedFile.name,
          path: pickedFile.path,
        );
      } else {
        return ImagePickerResult(
          file: File(pickedFile.path),
          path: pickedFile.path,
          name: pickedFile.name,
        );
      }
    } catch (e) {
      print('Error picking video: $e');
      return null;
    }
  }

  /// Pick video from camera
  static Future<ImagePickerResult?> recordVideo({
    Duration? maxDuration,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) {
    return pickVideo(
      source: ImageSource.camera,
      maxDuration: maxDuration,
      preferredCameraDevice: preferredCameraDevice,
    );
  }

  /// Pick video from gallery
  static Future<ImagePickerResult?> pickVideoFromGallery({
    Duration? maxDuration,
  }) {
    return pickVideo(source: ImageSource.gallery, maxDuration: maxDuration);
  }

  /// Show dialog to choose between camera and gallery
  /// Returns true if camera is chosen, false if gallery
  static Future<ImageSource?> showImageSourceDialog({
    required Function(BuildContext) getContext,
  }) async {
    // This is a placeholder. Implement your own dialog based on your UI framework
    // For now, we'll just return null and let the caller handle it
    return null;
  }

  /// Get file size in bytes
  static Future<int> getFileSize(ImagePickerResult result) async {
    if (result.bytes != null) {
      return result.bytes!.length;
    } else if (result.file != null) {
      return await result.file!.length();
    }
    return 0;
  }

  /// Check if file size is within limit
  ///
  /// [result] - The image picker result
  /// [maxSizeInMB] - Maximum allowed size in megabytes
  static Future<bool> isFileSizeValid(
    ImagePickerResult result,
    double maxSizeInMB,
  ) async {
    final sizeInBytes = await getFileSize(result);
    final sizeInMB = sizeInBytes / (1024 * 1024);
    return sizeInMB <= maxSizeInMB;
  }

  /// Validate image dimensions
  static Future<bool> validateDimensions(
    ImagePickerResult result, {
    int? minWidth,
    int? minHeight,
    int? maxWidth,
    int? maxHeight,
  }) async {
    // This would require image processing library like 'image' package
    // For now, return true. Implement based on your needs.
    return true;
  }
}

/// Extension to help with BuildContext requirement
extension ImagePickerExtension on BuildContext {
  Future<ImagePickerResult?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int compressQuality = 85,
  }) {
    return ImagePickerWrapper.pickImage(
      source: source,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      compressQuality: compressQuality,
    );
  }
}
