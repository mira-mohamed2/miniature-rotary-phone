import 'package:flutter/material.dart';

/// Widget for displaying validation status with visual indicators
class ValidationStatusWidget extends StatelessWidget {
  final bool isValid;
  final int errorCount;
  final double? confidenceScore;
  final String? statusMessage;

  const ValidationStatusWidget({
    super.key,
    required this.isValid,
    this.errorCount = 0,
    this.confidenceScore,
    this.statusMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        border: Border.all(color: _getStatusColor()),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status header
          Row(
            children: [
              Icon(
                _getStatusIcon(),
                color: _getStatusColor(),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getStatusTitle(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(),
                  ),
                ),
              ),
            ],
          ),
          
          if (statusMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              statusMessage!,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ],
          
          // Error count
          if (errorCount > 0) ...[
            const SizedBox(height: 8),
            Text(
              '$errorCount error(s) found',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          
          // Confidence score
          if (confidenceScore != null) ...[
            const SizedBox(height: 12),
            _ConfidenceBar(confidence: confidenceScore!),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor() {
    return isValid ? Colors.green : Colors.red;
  }

  IconData _getStatusIcon() {
    return isValid ? Icons.check_circle : Icons.error;
  }

  String _getStatusTitle() {
    return isValid ? 'Calculations Valid' : 'Validation Failed';
  }
}

class _ConfidenceBar extends StatelessWidget {
  final double confidence;

  const _ConfidenceBar({required this.confidence});

  @override
  Widget build(BuildContext context) {
    final percentage = (confidence * 100).toStringAsFixed(1);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Confidence',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$percentage%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: confidence,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            confidence > 0.8 ? Colors.green : 
            confidence > 0.6 ? Colors.orange : Colors.red,
          ),
        ),
      ],
    );
  }
}
