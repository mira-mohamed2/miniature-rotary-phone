import 'package:flutter_test/flutter_test.dart';
import 'package:bill_validator/services/calculation_service.dart';
import 'package:bill_validator/models/bill_item.dart';
import 'package:bill_validator/models/validation_result.dart';

void main() {
  group('CalculationService', () {
    final service = CalculationService();

    BillStructure buildStructure({
      List<BillItem>? items,
      double? subtotal,
      double taxRate = 10.0,
      double? taxAmount,
      double? tipAmount,
    }) {
      final List<BillItem> theItems = items ?? [
        const BillItem(name: 'Item A', price: 5.00, quantity: 2, lineTotal: 10.00),
        const BillItem(name: 'Item B', price: 3.50, quantity: 1, lineTotal: 3.50),
      ];
      final double sub = subtotal ?? theItems.fold(0.0, (double s, BillItem i) => s + i.lineTotal);
      final double tax = taxAmount ?? sub * (taxRate / 100);
      final double tip = tipAmount ?? 0.0;
      final double total = sub + tax + tip;
      return BillStructure(
        items: theItems,
        subtotal: sub,
        taxRate: taxRate,
        taxAmount: tax,
        total: total,
        tipAmount: tip,
        finalTotal: total,
      );
    }

    test('valid bill passes validation', () {
      final bill = buildStructure();
      final result = service.validateBillCalculations(bill);
      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
    });

    test('subtotal discrepancy detected', () {
      final bill = buildStructure(subtotal: 50); // Wrong subtotal
      final result = service.validateBillCalculations(bill);
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.type == CalculationErrorType.subtotal), isTrue);
    });

    test('tax discrepancy detected', () {
      final base = buildStructure();
      final wrong = BillStructure(
        items: base.items,
        subtotal: base.subtotal,
        taxRate: base.taxRate,
        taxAmount: base.taxAmount + 1.0, // wrong tax
        total: base.total + 1.0,
        tipAmount: base.tipAmount,
        finalTotal: base.finalTotal + 1.0,
      );
      final result = service.validateBillCalculations(wrong);
      expect(result.errors.any((e) => e.type == CalculationErrorType.tax), isTrue);
    });

    test('line item error detected', () {
      final items = [
        const BillItem(name: 'Item A', price: 5.00, quantity: 2, lineTotal: 9.50), // wrong total
      ];
      final bill = buildStructure(items: items, taxRate: 0);
      final result = service.validateBillCalculations(bill);
      expect(result.errors.any((e) => e.type == CalculationErrorType.lineItem), isTrue);
    });
  });
}
