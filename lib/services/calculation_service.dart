import '../models/bill_item.dart';
import '../models/validation_result.dart';

/// Service for validating bill calculations
class CalculationService {

  /// Validate all calculations in a bill structure
  ValidationResult validateBillCalculations(BillStructure bill) {
    final errors = <CalculationError>[];
    
    // Validate line items first
    final lineItemErrors = validateLineItems(bill.items);
    errors.addAll(lineItemErrors);
    
    // Validate subtotal
    if (!validateSubtotal(bill.items, bill.subtotal)) {
      errors.add(CalculationError(
        type: CalculationErrorType.subtotal,
        description: 'Subtotal does not match sum of line items',
        expectedValue: bill.calculatedSubtotal,
        actualValue: bill.subtotal,
      ));
    }

    // Validate tax calculation
    if (bill.taxRate > 0 && !validateTaxCalculation(bill.subtotal, bill.taxRate, bill.taxAmount)) {
      errors.add(CalculationError(
        type: CalculationErrorType.tax,
        description: 'Tax amount does not match tax rate calculation',
        expectedValue: bill.calculatedTaxAmount,
        actualValue: bill.taxAmount,
      ));
    }

    // Validate total
    if (!validateTotal(bill.subtotal, bill.taxAmount, bill.tipAmount, bill.finalTotal)) {
      errors.add(CalculationError(
        type: CalculationErrorType.total,
        description: 'Total does not match subtotal + tax + tip',
        expectedValue: bill.calculatedTotal,
        actualValue: bill.finalTotal,
      ));
    }

    // Calculate confidence score based on accuracy and complexity
    final confidenceScore = _calculateConfidenceScore(bill, errors);

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      confidenceScore: confidenceScore,
      detectedStructure: bill,
    );
  }

  /// Validate that subtotal equals sum of line items
  bool validateSubtotal(List<BillItem> items, double subtotal) {
    final calculatedSubtotal = items.fold(0.0, (sum, item) => sum + item.lineTotal);
    return (subtotal - calculatedSubtotal).abs() < 0.01;
  }

  /// Validate tax calculation
  bool validateTaxCalculation(double subtotal, double taxRate, double taxAmount) {
    final calculatedTax = subtotal * (taxRate / 100);
    return (taxAmount - calculatedTax).abs() < 0.01;
  }

  /// Validate total calculation
  bool validateTotal(double subtotal, double tax, double tip, double total) {
    final calculatedTotal = subtotal + tax + tip;
    return (total - calculatedTotal).abs() < 0.01;
  }

  /// Find all discrepancies in a bill
  List<CalculationError> findDiscrepancies(BillStructure bill) {
    final errors = <CalculationError>[];
    
    // Check line items
    errors.addAll(validateLineItems(bill.items));
    
    // Check subtotal
    if (!validateSubtotal(bill.items, bill.subtotal)) {
      errors.add(CalculationError(
        type: CalculationErrorType.subtotal,
        description: 'Subtotal calculation error',
        expectedValue: bill.calculatedSubtotal,
        actualValue: bill.subtotal,
      ));
    }
    
    // Check tax
    if (bill.taxRate > 0 && !validateTaxCalculation(bill.subtotal, bill.taxRate, bill.taxAmount)) {
      errors.add(CalculationError(
        type: CalculationErrorType.tax,
        description: 'Tax calculation error',
        expectedValue: bill.calculatedTaxAmount,
        actualValue: bill.taxAmount,
      ));
    }
    
    // Check total
    if (!validateTotal(bill.subtotal, bill.taxAmount, bill.tipAmount, bill.finalTotal)) {
      errors.add(CalculationError(
        type: CalculationErrorType.total,
        description: 'Total calculation error',
        expectedValue: bill.calculatedTotal,
        actualValue: bill.finalTotal,
      ));
    }
    
    return errors;
  }

  /// Validate individual line items
  List<CalculationError> validateLineItems(List<BillItem> items) {
    final errors = <CalculationError>[];
    
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      if (!item.isValid) {
        errors.add(CalculationError(
          type: CalculationErrorType.lineItem,
          description: 'Line item "${item.name}" calculation error: ${item.quantity} × \$${item.price.toStringAsFixed(2)} should equal \$${item.calculatedTotal.toStringAsFixed(2)}',
          expectedValue: item.calculatedTotal,
          actualValue: item.lineTotal,
        ));
      }
      
      // Check for rounding errors
      final roundingDifference = (item.lineTotal - item.calculatedTotal).abs();
      if (roundingDifference > 0.01 && roundingDifference <= 0.05) {
        errors.add(CalculationError(
          type: CalculationErrorType.rounding,
          description: 'Possible rounding error in "${item.name}"',
          expectedValue: item.calculatedTotal,
          actualValue: item.lineTotal,
        ));
      }
    }
    
    return errors;
  }

  /// Calculate confidence score based on validation results
  double _calculateConfidenceScore(BillStructure bill, List<CalculationError> errors) {
    if (errors.isEmpty) {
      return 1.0; // Perfect score for no errors
    }
    
    // Start with base confidence
    double confidence = 0.8;
    
    // Reduce confidence based on number and severity of errors
    for (final error in errors) {
      switch (error.type) {
        case CalculationErrorType.lineItem:
          confidence -= 0.1;
          break;
        case CalculationErrorType.subtotal:
          confidence -= 0.15;
          break;
        case CalculationErrorType.tax:
          confidence -= 0.1;
          break;
        case CalculationErrorType.total:
          confidence -= 0.2;
          break;
        case CalculationErrorType.rounding:
          confidence -= 0.05;
          break;
      }
    }
    
    // Adjust based on bill complexity
    final complexity = bill.items.length + (bill.taxRate > 0 ? 1 : 0) + (bill.tipAmount > 0 ? 1 : 0);
    if (complexity > 10) {
      confidence += 0.1; // Bonus for successfully handling complex bills
    }
    
    return (confidence).clamp(0.0, 1.0);
  }
}
