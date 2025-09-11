import 'package:flutter/material.dart';
import '../models/bill_item.dart';

/// Widget for displaying a bill item with validation status
class BillItemCard extends StatelessWidget {
  final BillItem item;
  final bool hasError;
  final VoidCallback? onTap;

  const BillItemCard({
    super.key,
    required this.item,
    this.hasError = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Item details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Qty: ${item.quantity} × \$${item.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Price and validation status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${item.lineTotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: hasError ? Colors.red : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    hasError ? Icons.error : Icons.check_circle,
                    size: 16,
                    color: hasError ? Colors.red : Colors.green,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
