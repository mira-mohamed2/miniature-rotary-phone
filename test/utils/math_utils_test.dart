import 'package:flutter_test/flutter_test.dart';
import 'package:bill_validator/utils/math_utils.dart';

void main() {
  group('MathUtils', () {
    test('areEqual within tolerance', () {
      expect(MathUtils.areEqual(1.000, 1.005, tolerance: 0.01), isTrue);
      expect(MathUtils.areEqual(1.000, 1.02, tolerance: 0.01), isFalse);
    });

    test('calculateTax returns expected value', () {
      final tax = MathUtils.calculateTax(100, 8.25);
      expect(tax, closeTo(8.25, 0.0001));
    });

    test('validateTotal passes for correct values', () {
      final ok = MathUtils.validateTotal(50, 5, 2.5, 57.5);
      expect(ok, isTrue);
    });

    test('calculateConfidenceScore boosts for valid calculations', () {
      final score = MathUtils.calculateConfidenceScore(
        baseConfidence: 0.6,
        detectedElements: 10,
        calculationsValid: true,
        minElements: 5,
      );
      expect(score, greaterThan(0.6));
    });
  });
}
