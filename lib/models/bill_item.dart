import 'dart:ui';

/// Represents a single item on a bill/receipt
class BillItem {
  final String name;
  final double price;
  final int quantity;
  final double lineTotal;
  final Rect? boundingBox; // For highlighting in UI

  const BillItem({
    required this.name,
    required this.price,
    required this.quantity,
    required this.lineTotal,
    this.boundingBox,
  });

  /// Calculate what the line total should be
  double get calculatedTotal => price * quantity;

  /// Check if the line total is correct
  bool get isValid => (lineTotal - calculatedTotal).abs() < 0.01;

  @override
  String toString() {
    return 'BillItem(name: $name, price: $price, quantity: $quantity, lineTotal: $lineTotal)';
  }
}

/// Represents the complete structure of a bill
class BillStructure {
  final List<BillItem> items;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double total;
  final double tipAmount;
  final double finalTotal;

  const BillStructure({
    required this.items,
    required this.subtotal,
    required this.taxRate,
    required this.taxAmount,
    required this.total,
    this.tipAmount = 0.0,
    required this.finalTotal,
  });

  /// Calculate what the subtotal should be based on items
  double get calculatedSubtotal {
    return items.fold(0.0, (sum, item) => sum + item.lineTotal);
  }

  /// Calculate what the tax amount should be
  double get calculatedTaxAmount => subtotal * (taxRate / 100);

  /// Calculate what the total should be
  double get calculatedTotal => subtotal + taxAmount + tipAmount;

  @override
  String toString() {
    return 'BillStructure(items: ${items.length}, subtotal: $subtotal, tax: $taxAmount, total: $finalTotal)';
  }
}
