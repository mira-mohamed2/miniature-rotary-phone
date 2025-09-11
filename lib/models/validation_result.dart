import 'bill_item.dart';

/// Types of calculation errors that can be detected
enum CalculationErrorType {
  subtotal,
  tax,
  total,
  lineItem,
  rounding,
}

/// Represents a specific calculation error
class CalculationError {
  final CalculationErrorType type;
  final String description;
  final double expectedValue;
  final double actualValue;
  final double difference;

  const CalculationError({
    required this.type,
    required this.description,
    required this.expectedValue,
    required this.actualValue,
  }) : difference = actualValue - expectedValue;

  /// Get a user-friendly error message
  String get userMessage {
    switch (type) {
      case CalculationErrorType.subtotal:
        return 'Subtotal calculation error: Expected \$${expectedValue.toStringAsFixed(2)}, found \$${actualValue.toStringAsFixed(2)}';
      case CalculationErrorType.tax:
        return 'Tax calculation error: Expected \$${expectedValue.toStringAsFixed(2)}, found \$${actualValue.toStringAsFixed(2)}';
      case CalculationErrorType.total:
        return 'Total calculation error: Expected \$${expectedValue.toStringAsFixed(2)}, found \$${actualValue.toStringAsFixed(2)}';
      case CalculationErrorType.lineItem:
        return 'Line item error: $description';
      case CalculationErrorType.rounding:
        return 'Rounding error: $description';
    }
  }

  @override
  String toString() {
    return 'CalculationError(${type.name}: $description)';
  }
}

/// Result of validating a bill's calculations
class ValidationResult {
  final bool isValid;
  final List<CalculationError> errors;
  final double confidenceScore;
  final BillStructure detectedStructure;
  final BillStructure? correctedStructure;

  const ValidationResult({
    required this.isValid,
    required this.errors,
    required this.confidenceScore,
    required this.detectedStructure,
    this.correctedStructure,
  });

  /// Get a summary of the validation result
  String get summary {
    if (isValid) {
      return 'All calculations are correct!';
    } else {
      return '${errors.length} error(s) found in calculations';
    }
  }

  /// Get the total monetary difference
  double get totalDifference {
    return errors.fold(0.0, (sum, error) => sum + error.difference.abs());
  }

  @override
  String toString() {
    return 'ValidationResult(valid: $isValid, errors: ${errors.length}, confidence: ${(confidenceScore * 100).toStringAsFixed(1)}%)';
  }
}
