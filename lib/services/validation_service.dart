import 'dart:io';
import '../models/validation_result.dart';
import '../models/bill_item.dart';
import '../utils/math_utils.dart';
import '../utils/constants.dart';
import 'image_service.dart';
import 'ocr_service.dart';
import 'calculation_service.dart';

/// Main service that orchestrates the validation process
class ValidationService {
  final ImageService _imageService = ImageService();
  final OCRService _ocrService = OCRService();
  final CalculationService _calculationService = CalculationService();

  /// Validate a bill image end-to-end
  Future<ValidationResult> validateBillFromImage(File imageFile) async {
    try {
      // 1. Validate image first
      if (!_imageService.isImageValid(imageFile)) {
        return _createErrorResult('Invalid image file', const BillStructure(
          items: [],
          subtotal: 0.0,
          taxRate: 0.0,
          taxAmount: 0.0,
          total: 0.0,
          finalTotal: 0.0,
        ));
      }

      // 2. Preprocess image for better OCR
      final processedImage = await _imageService.preprocessImage(imageFile);
      
      // 3. Extract text with OCR
      final ocrResult = await _ocrService.extractTextFromImage(processedImage);
      
      // Check if OCR found enough text
      if (ocrResult.textElements.length < 3) {
        return _createErrorResult(
          'Could not extract enough text from image. Please ensure the bill is clear and well-lit.',
          const BillStructure(
            items: [],
            subtotal: 0.0,
            taxRate: 0.0,
            taxAmount: 0.0,
            total: 0.0,
            finalTotal: 0.0,
          ),
        );
      }
      
      // 4. Parse bill structure
      final billStructure = await _ocrService.extractBillStructure(ocrResult);
      
      if (billStructure == null) {
        return _createErrorResult(
          'Could not parse bill structure. Please try a clearer image or crop to show only the bill.',
          const BillStructure(
            items: [],
            subtotal: 0.0,
            taxRate: 0.0,
            taxAmount: 0.0,
            total: 0.0,
            finalTotal: 0.0,
          ),
        );
      }
      
      // 5. Validate calculations
      final validationResult = _calculationService.validateBillCalculations(billStructure);
      
      // 6. Calculate overall confidence score
      final confidence = calculateConfidenceScore(
        ocrConfidence: ocrResult.overallConfidence,
        elementsDetected: ocrResult.textElements.length,
        calculationsValid: validationResult.isValid,
        billComplexity: _assessBillComplexity(billStructure),
      );
      
      // 7. Create corrected structure if there are errors
      BillStructure? correctedStructure;
      if (!validationResult.isValid) {
        correctedStructure = _createCorrectedStructure(billStructure);
      }
      
      // 8. Clean up temporary files
      _cleanup(processedImage);
      
      return ValidationResult(
        isValid: validationResult.isValid,
        errors: validationResult.errors,
        confidenceScore: confidence,
        detectedStructure: billStructure,
        correctedStructure: correctedStructure,
      );
      
    } catch (e) {
      // Return detailed error result
      return _createErrorResult(
        'Validation failed: ${e.toString()}',
        const BillStructure(
          items: [],
          subtotal: 0.0,
          taxRate: 0.0,
          taxAmount: 0.0,
          total: 0.0,
          finalTotal: 0.0,
        ),
      );
    }
  }

  /// Get confidence score for the validation
  double calculateConfidenceScore({
    required double ocrConfidence,
    required int elementsDetected,
    required bool calculationsValid,
    double billComplexity = 1.0,
  }) {
    return MathUtils.calculateConfidenceScore(
      baseConfidence: ocrConfidence,
      detectedElements: elementsDetected,
      calculationsValid: calculationsValid,
      minElements: 5,
    ) * billComplexity;
  }

  /// Assess the complexity of a bill (affects confidence)
  double _assessBillComplexity(BillStructure bill) {
    double complexity = 1.0;
    
    // More items = higher complexity but also higher confidence if parsed correctly
    if (bill.items.length > 10) {
      complexity += 0.1;
    } else if (bill.items.length < 3) {
      complexity -= 0.2;
    }
    
    // Tax calculation adds complexity
    if (bill.taxAmount > 0) {
      complexity += 0.05;
    }
    
    // Tip adds complexity
    if (bill.tipAmount > 0) {
      complexity += 0.05;
    }
    
    return complexity.clamp(0.5, 1.2);
  }

  /// Create a corrected bill structure based on detected errors
  BillStructure _createCorrectedStructure(BillStructure original) {
    // Calculate corrected values
    final correctedSubtotal = original.items.fold(0.0, (sum, item) => sum + item.lineTotal);
    final correctedTax = MathUtils.calculateTax(correctedSubtotal, original.taxRate);
    final correctedTotal = MathUtils.calculateTotal(
      correctedSubtotal,
      tax: correctedTax,
      tip: original.tipAmount,
    );

    return BillStructure(
      items: original.items,
      subtotal: correctedSubtotal,
      taxRate: original.taxRate,
      taxAmount: correctedTax,
      total: correctedTotal,
      tipAmount: original.tipAmount,
      finalTotal: correctedTotal,
    );
  }

  /// Create an error validation result
  ValidationResult _createErrorResult(String message, BillStructure structure) {
    return ValidationResult(
      isValid: false,
      errors: [
        CalculationError(
          type: CalculationErrorType.subtotal,
          description: message,
          expectedValue: 0.0,
          actualValue: 0.0,
        ),
      ],
      confidenceScore: 0.0,
      detectedStructure: structure,
    );
  }

  /// Clean up temporary files
  void _cleanup(File? tempFile) {
    try {
      if (tempFile != null && tempFile.existsSync()) {
        tempFile.deleteSync();
      }
      _imageService.cleanupTempFiles();
    } catch (e) {
      // Ignore cleanup errors
    }
  }

  /// Dispose of resources
  void dispose() {
    _ocrService.dispose();
  }

  /// Validate multiple bills in sequence
  Future<List<ValidationResult>> validateMultipleBills(List<File> imageFiles) async {
    final results = <ValidationResult>[];
    
    for (final imageFile in imageFiles) {
      try {
        final result = await validateBillFromImage(imageFile);
        results.add(result);
      } catch (e) {
        results.add(_createErrorResult(
          'Failed to process image: ${e.toString()}',
          const BillStructure(
            items: [],
            subtotal: 0.0,
            taxRate: 0.0,
            taxAmount: 0.0,
            total: 0.0,
            finalTotal: 0.0,
          ),
        ));
      }
    }
    
    return results;
  }

  /// Get processing statistics
  Map<String, dynamic> getProcessingStats() {
    return {
      'ocrConfidenceThreshold': AppConstants.minimumConfidenceScore,
      'roundingTolerance': AppConstants.roundingTolerance,
      'maxProcessingTime': AppConstants.maxProcessingTimeSeconds,
      'supportedFormats': AppConstants.supportedImageFormats,
    };
  }
}
