import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

/// Loading overlay widget for processing states
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final String? message;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SpinKitWaveSpinner(
                      color: Colors.blue,
                      size: 50.0,
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        message!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Simple circular loading indicator
class SimpleLoader extends StatelessWidget {
  final String? message;
  final Color? color;

  const SimpleLoader({
    super.key,
    this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: color ?? Theme.of(context).primaryColor,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Processing stages indicator
class ProcessingStagesIndicator extends StatelessWidget {
  final List<String> stages;
  final int currentStage;

  const ProcessingStagesIndicator({
    super.key,
    required this.stages,
    required this.currentStage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SpinKitThreeBounce(
            color: Colors.blue,
            size: 30.0,
          ),
          const SizedBox(height: 20),
          ...stages.asMap().entries.map((entry) {
            final index = entry.key;
            final stage = entry.value;
            final isActive = index == currentStage;
            final isCompleted = index < currentStage;
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    isCompleted ? Icons.check_circle : 
                    isActive ? Icons.hourglass_empty : Icons.circle_outlined,
                    size: 16,
                    color: isCompleted ? Colors.green :
                           isActive ? Colors.blue : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      stage,
                      style: TextStyle(
                        color: isActive ? Colors.blue : 
                               isCompleted ? Colors.green : Colors.grey,
                        fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
