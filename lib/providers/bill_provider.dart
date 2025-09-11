import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/bill_item.dart';
import '../models/validation_result.dart';
import '../services/validation_service.dart';

/// Provider for managing bill validation state
class BillProvider extends ChangeNotifier {
  final ValidationService _validationService = ValidationService();
  
  // State variables
  File? _currentImage;
  ValidationResult? _validationResult;
  BillStructure? _currentBill;
  bool _isProcessing = false;
  String? _errorMessage;

  // Getters
  File? get currentImage => _currentImage;
  ValidationResult? get validationResult => _validationResult;
  BillStructure? get currentBill => _currentBill;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  
  bool get hasImage => _currentImage != null;
  bool get hasResult => _validationResult != null;

  /// Set the current image to be processed
  void setCurrentImage(File image) {
    _currentImage = image;
    _validationResult = null;
    _currentBill = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Validate the current image
  Future<void> validateCurrentImage() async {
    if (_currentImage == null) {
      _errorMessage = 'No image selected for validation';
      notifyListeners();
      return;
    }

    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _validationService.validateBillFromImage(_currentImage!);
      _validationResult = result;
      _currentBill = result.detectedStructure;
    } catch (e) {
      _errorMessage = 'Error validating bill: ${e.toString()}';
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Clear all current data
  void clearAll() {
    _currentImage = null;
    _validationResult = null;
    _currentBill = null;
    _isProcessing = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Get validation summary text
  String get validationSummary {
    if (_validationResult == null) return 'No validation performed';
    return _validationResult!.summary;
  }

  /// Get overall validation status
  bool get isValid {
    return _validationResult?.isValid ?? false;
  }
}
