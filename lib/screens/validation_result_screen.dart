import 'package:flutter/material.dart';
import '../models/validation_result.dart';
import '../models/bill_item.dart';
import '../widgets/bill_item_card.dart';
import '../widgets/validation_status_widget.dart';

/// Screen for displaying bill validation results
class ValidationResultScreen extends StatelessWidget {
  final ValidationResult result;
  
  const ValidationResultScreen({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validation Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement result sharing
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing not yet implemented')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall status
            ValidationStatusWidget(
              isValid: result.isValid,
              errorCount: result.errors.length,
              confidenceScore: result.confidenceScore,
              statusMessage: result.summary,
            ),
            
            const SizedBox(height: 16),
            
            // Bill details
            _BillDetailsCard(result: result),
            
            const SizedBox(height: 16),
            
            // Line items
            if (result.detectedStructure.items.isNotEmpty) ...[
              _LineItemsCard(result: result),
              const SizedBox(height: 16),
            ],
            
            const SizedBox(height: 16),
            
            // Errors (if any)
            if (result.errors.isNotEmpty) ...[
              _ErrorsCard(errors: result.errors),
              const SizedBox(height: 16),
            ],
            
            // Confidence score
            _ConfidenceCard(confidence: result.confidenceScore),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.popUntil(context, (route) => route.isFirst);
        },
        icon: const Icon(Icons.home),
        label: const Text('New Validation'),
      ),
    );
  }
}

class _LineItemsCard extends StatelessWidget {
  final ValidationResult result;
  
  const _LineItemsCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final bill = result.detectedStructure;
    final errorTypes = result.errors.where((e) => e.type == CalculationErrorType.lineItem).toList();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Line Items (${bill.items.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...bill.items.map((item) {
              final hasError = errorTypes.any((error) => error.description.contains(item.name));
              return BillItemCard(
                item: item,
                hasError: hasError,
                onTap: hasError ? () {
                  // Show error details for this item
                  _showItemErrorDetails(context, item, errorTypes);
                } : null,
              );
            }),
          ],
        ),
      ),
    );
  }
  
  void _showItemErrorDetails(BuildContext context, BillItem item, List<CalculationError> errors) {
    final itemErrors = errors.where((e) => e.description.contains(item.name)).toList();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error in "${item.name}"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Expected: \$${item.calculatedTotal.toStringAsFixed(2)}'),
            Text('Found: \$${item.lineTotal.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            ...itemErrors.map((error) => Text(
              error.description,
              style: const TextStyle(color: Colors.red),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _BillDetailsCard extends StatelessWidget {
  final ValidationResult result;
  
  const _BillDetailsCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final bill = result.detectedStructure;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bill Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _DetailRow('Items', '${bill.items.length}'),
            _DetailRow('Subtotal', '\$${bill.subtotal.toStringAsFixed(2)}'),
            _DetailRow('Tax Rate', '${bill.taxRate.toStringAsFixed(1)}%'),
            _DetailRow('Tax Amount', '\$${bill.taxAmount.toStringAsFixed(2)}'),
            _DetailRow('Total', '\$${bill.finalTotal.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
  
  Widget _DetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _ErrorsCard extends StatelessWidget {
  final List<CalculationError> errors;
  
  const _ErrorsCard({required this.errors});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Found ${errors.length} Error(s)',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...errors.map((error) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                '• ${error.userMessage}',
                style: const TextStyle(color: Colors.red),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _ConfidenceCard extends StatelessWidget {
  final double confidence;
  
  const _ConfidenceCard({required this.confidence});

  @override
  Widget build(BuildContext context) {
    final percentage = (confidence * 100).toStringAsFixed(1);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Confidence Score',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: confidence,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      confidence > 0.8 ? Colors.green : 
                      confidence > 0.6 ? Colors.orange : Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$percentage%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
