import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;
import '../utils/constants.dart';

/// Service for handling image capture and processing
class ImageService {
  final ImagePicker _picker = ImagePicker();

  /// Capture image from camera
  Future<File?> captureFromCamera() async {
    try {
      // Check camera permission
      final cameraPermission = await Permission.camera.status;
      if (!cameraPermission.isGranted) {
        final result = await Permission.camera.request();
        if (!result.isGranted) {
          throw Exception(AppConstants.permissionDeniedError);
        }
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85, // Good balance between quality and file size
        maxWidth: AppConstants.maxImageWidth,
        maxHeight: AppConstants.maxImageHeight,
      );

      if (image == null) return null;

      final File imageFile = File(image.path);
      
      // Validate image
      if (!isImageValid(imageFile)) {
        throw Exception('Selected image is not valid for processing');
      }

      return imageFile;
    } catch (e) {
      throw Exception('Failed to capture image: ${e.toString()}');
    }
  }

  /// Select image from gallery
  Future<File?> selectFromGallery() async {
    try {
      // Check storage permission (for older Android versions)
      if (Platform.isAndroid) {
        final storagePermission = await Permission.storage.status;
        if (!storagePermission.isGranted) {
          final result = await Permission.storage.request();
          if (!result.isGranted) {
            // Try photos permission for newer Android versions
            final photosPermission = await Permission.photos.request();
            if (!photosPermission.isGranted) {
              throw Exception(AppConstants.permissionDeniedError);
            }
          }
        }
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: AppConstants.maxImageWidth,
        maxHeight: AppConstants.maxImageHeight,
      );

      if (image == null) return null;

      final File imageFile = File(image.path);
      
      // Validate image
      if (!isImageValid(imageFile)) {
        throw Exception('Selected image is not valid for processing');
      }

      return imageFile;
    } catch (e) {
      throw Exception('Failed to select image: ${e.toString()}');
    }
  }

  /// Crop image for better OCR accuracy
  Future<File?> cropImage(File imageFile) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 3, ratioY: 4), // Good for receipts
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Bill Image',
            toolbarColor: const Color(0xFF2196F3),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.ratio4x3,
            lockAspectRatio: false,
            showCropGrid: true,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'Crop Bill Image',
            minimumAspectRatio: 0.5,
            aspectRatioLockEnabled: false,
            showCancelConfirmationDialog: true,
          ),
        ],
      );

      if (croppedFile == null) return null;

      return File(croppedFile.path);
    } catch (e) {
      throw Exception('Failed to crop image: ${e.toString()}');
    }
  }

  /// Preprocess image for optimal OCR
  Future<File> preprocessImage(File imageFile) async {
    try {
      // Read the image
      final imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);
      
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Convert to grayscale for better OCR
      image = img.grayscale(image);
      
      // Enhance contrast
      image = img.contrast(image, contrast: 1.2);
      
      // Sharpen the image for better text recognition
      image = img.convolution(image, filter: [
        0, -1, 0,
        -1, 5, -1,
        0, -1, 0
      ]);

      // Resize if too large (but maintain aspect ratio)
      if (image.width > 2000 || image.height > 2000) {
        image = img.copyResize(
          image,
          width: image.width > image.height ? 2000 : null,
          height: image.height > image.width ? 2000 : null,
          interpolation: img.Interpolation.cubic,
        );
      }

      // Save processed image to temporary file
      final processedBytes = img.encodeJpg(image, quality: 90);
      final tempDir = Directory.systemTemp;
      final processedFile = File(
        '${tempDir.path}/${AppConstants.tempImagePrefix}processed_${DateTime.now().millisecondsSinceEpoch}${AppConstants.tempImageExtension}'
      );
      
      await processedFile.writeAsBytes(processedBytes);
      return processedFile;
    } catch (e) {
      throw Exception('Failed to preprocess image: ${e.toString()}');
    }
  }

  /// Validate if image is suitable for processing
  bool isImageValid(File imageFile) {
    try {
      // Check if file exists
      if (!imageFile.existsSync()) {
        return false;
      }

      // Check file size
      final fileSizeBytes = imageFile.lengthSync();
      if (fileSizeBytes > AppConstants.maxImageSizeBytes || fileSizeBytes < 1024) {
        return false;
      }

      // Check file extension
      final extension = imageFile.path.split('.').last.toLowerCase();
      if (!AppConstants.supportedImageFormats.contains(extension)) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clean up temporary files
  Future<void> cleanupTempFiles() async {
    try {
      final tempDir = Directory.systemTemp;
      final tempFiles = tempDir.listSync().where((file) =>
        file.path.contains(AppConstants.tempImagePrefix) &&
        file is File
      );

      for (final file in tempFiles) {
        try {
          await file.delete();
        } catch (e) {
          // Ignore individual file deletion errors
        }
      }
    } catch (e) {
      // Ignore cleanup errors
    }
  }

  /// Get image dimensions
  Future<Map<String, int>?> getImageDimensions(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) return null;
      
      return {
        'width': image.width,
        'height': image.height,
      };
    } catch (e) {
      return null;
    }
  }
}
