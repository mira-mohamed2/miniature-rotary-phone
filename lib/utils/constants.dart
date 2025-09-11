import 'package:flutter/material.dart';

/// App-wide constants
class AppConstants {
  // App Information
  static const String appName = 'Bill Validator';
  static const String appVersion = '1.0.0';
  
  // Validation thresholds
  static const double minimumConfidenceScore = 0.7;
  static const double roundingTolerance = 0.01;
  static const int maxProcessingTimeSeconds = 30;
  
  // Image constraints
  static const int maxImageSizeBytes = 10 * 1024 * 1024; // 10MB
  static const double maxImageWidth = 4000;
  static const double maxImageHeight = 4000;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double buttonHeight = 56.0;
  static const double cardBorderRadius = 8.0;
  
  // Animation durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration loadingAnimationDuration = Duration(milliseconds: 1500);
  
  // Processing stages
  static const List<String> processingStages = [
    'Preprocessing image...',
    'Extracting text...',
    'Parsing bill structure...',
    'Validating calculations...',
    'Generating results...',
  ];
  
  // Error messages
  static const String imageNotFoundError = 'Selected image could not be found';
  static const String ocrFailedError = 'Failed to extract text from image';
  static const String parsingFailedError = 'Could not parse bill structure';
  static const String validationFailedError = 'Validation process failed';
  static const String permissionDeniedError = 'Permission denied for camera/storage access';
  
  // Success messages
  static const String validationSuccessMessage = 'All calculations are correct!';
  static const String imageProcessedMessage = 'Image processed successfully';
  
  // File paths and names
  static const String tempImagePrefix = 'bill_validator_';
  static const String tempImageExtension = '.jpg';
  
  // Supported image formats
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png'];
  
  // Default values
  static const double defaultTaxRate = 0.0;
  static const double defaultTipRate = 0.0;
}

/// Color constants for the app theme
class AppColors {
  static const validationSuccess = Color(0xFF4CAF50);
  static const validationError = Color(0xFFF44336);
  static const validationWarning = Color(0xFFFF9800);
  static const backgroundGrey = Color(0xFFF5F5F5);
  static const textSecondary = Color(0xFF757575);
  static const dividerColor = Color(0xFFE0E0E0);
}

/// Text style constants
class AppTextStyles {
  static const titleLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  
  static const titleMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );
  
  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );
  
  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );
  
  static const caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );
}
