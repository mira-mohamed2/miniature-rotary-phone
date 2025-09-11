import 'dart:math' as math;

/// Utility functions for mathematical operations and validations
class MathUtils {
  
  /// Default tolerance for floating point comparisons
  static const double defaultTolerance = 0.01;
  
  /// Compare two double values with tolerance
  static bool areEqual(double a, double b, {double tolerance = defaultTolerance}) {
    return (a - b).abs() <= tolerance;
  }
  
  /// Round to specified decimal places
  static double roundToDecimalPlaces(double value, int decimalPlaces) {
    final factor = math.pow(10, decimalPlaces).toDouble();
    return (value * factor).round() / factor;
  }
  
  /// Round to nearest cent (2 decimal places)
  static double roundToCents(double value) {
    return roundToDecimalPlaces(value, 2);
  }
  
  /// Calculate percentage of a value
  static double calculatePercentage(double value, double percentage) {
    return value * (percentage / 100.0);
  }
  
  /// Calculate what percentage one value is of another
  static double calculatePercentageOf(double part, double whole) {
    if (whole == 0) return 0;
    return (part / whole) * 100;
  }
  
  /// Validate that a sum equals the sum of its parts within tolerance
  static bool validateSum(List<double> parts, double expectedSum, {double tolerance = defaultTolerance}) {
    final actualSum = parts.fold(0.0, (sum, part) => sum + part);
    return areEqual(actualSum, expectedSum, tolerance: tolerance);
  }
  
  /// Calculate tax amount from subtotal and tax rate
  static double calculateTax(double subtotal, double taxRate) {
    return subtotal * (taxRate / 100.0);
  }
  
  /// Calculate tip amount from subtotal and tip rate
  static double calculateTip(double subtotal, double tipRate) {
    return subtotal * (tipRate / 100.0);
  }
  
  /// Calculate total from components
  static double calculateTotal(double subtotal, {double tax = 0.0, double tip = 0.0, double discount = 0.0}) {
    return subtotal + tax + tip - discount;
  }
  
  /// Validate tax calculation
  static bool validateTax(double subtotal, double taxRate, double taxAmount, {double tolerance = defaultTolerance}) {
    final expectedTax = calculateTax(subtotal, taxRate);
    return areEqual(expectedTax, taxAmount, tolerance: tolerance);
  }
  
  /// Validate total calculation
  static bool validateTotal(double subtotal, double tax, double tip, double total, {double tolerance = defaultTolerance}) {
    final expectedTotal = calculateTotal(subtotal, tax: tax, tip: tip);
    return areEqual(expectedTotal, total, tolerance: tolerance);
  }
  
  /// Get the difference between expected and actual values
  static double getDifference(double expected, double actual) {
    return actual - expected;
  }
  
  /// Get the absolute difference between expected and actual values
  static double getAbsoluteDifference(double expected, double actual) {
    return (actual - expected).abs();
  }
  
  /// Check if a value is within a percentage range of another value
  static bool isWithinPercentageRange(double value, double target, double percentageRange) {
    final tolerance = target * (percentageRange / 100.0);
    return getAbsoluteDifference(value, target) <= tolerance;
  }
  
  /// Format currency value to string
  static String formatCurrency(double value, {String symbol = '\$', int decimalPlaces = 2}) {
    return '$symbol${value.toStringAsFixed(decimalPlaces)}';
  }
  
  /// Format percentage to string
  static String formatPercentage(double value, {int decimalPlaces = 1}) {
    return '${value.toStringAsFixed(decimalPlaces)}%';
  }
  
  /// Parse currency string to double
  static double? parseCurrency(String currencyString) {
    // Remove currency symbols and whitespace
    final cleanString = currencyString
        .replaceAll(RegExp(r'[\$\s,]'), '')
        .trim();
    
    return double.tryParse(cleanString);
  }
  
  /// Parse percentage string to double
  static double? parsePercentage(String percentageString) {
    // Remove percentage symbol and whitespace
    final cleanString = percentageString
        .replaceAll(RegExp(r'[%\s]'), '')
        .trim();
    
    return double.tryParse(cleanString);
  }
  
  /// Calculate confidence score based on multiple factors
  static double calculateConfidenceScore({
    required double baseConfidence,
    required int detectedElements,
    required bool calculationsValid,
    int minElements = 3,
    double maxConfidence = 1.0,
  }) {
    // Start with base confidence (e.g., from OCR)
    double confidence = baseConfidence;
    
    // Boost confidence based on number of detected elements
    if (detectedElements >= minElements) {
      final elementBoost = math.min(0.2, (detectedElements - minElements) * 0.05);
      confidence += elementBoost;
    } else {
      // Penalize if too few elements detected
      confidence *= 0.7;
    }
    
    // Boost confidence if calculations are valid
    if (calculationsValid) {
      confidence += 0.15;
    } else {
      confidence *= 0.8;
    }
    
    // Ensure confidence stays within bounds
    return math.min(confidence, maxConfidence).clamp(0.0, 1.0);
  }
  
  /// Check if rounding could explain a discrepancy
  static bool isProbablyRoundingError(double difference, {double maxRoundingError = 0.02}) {
    return difference.abs() <= maxRoundingError;
  }
  
  /// Round using different rounding methods
  static double roundHalfUp(double value) {
    return (value + 0.5).floor().toDouble();
  }
  
  static double roundHalfDown(double value) {
    return (value - 0.5).ceil().toDouble();
  }
  
  static double roundHalfToEven(double value) {
    final rounded = value.round();
    if ((value - rounded).abs() == 0.5) {
      return rounded.isEven ? rounded.toDouble() : (rounded + (value > rounded ? -1 : 1)).toDouble();
    }
    return rounded.toDouble();
  }
}
