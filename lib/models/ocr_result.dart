import 'dart:ui';

/// Represents a text element detected by OCR
class TextElement {
  final String text;
  final Rect boundingBox;
  final double confidence;

  const TextElement({
    required this.text,
    required this.boundingBox,
    required this.confidence,
  });

  @override
  String toString() {
    return 'TextElement(text: "$text", confidence: ${(confidence * 100).toStringAsFixed(1)}%)';
  }
}

/// Result of OCR processing on an image
class OCRResult {
  final List<TextElement> textElements;
  final double overallConfidence;
  final Duration processingTime;

  const OCRResult({
    required this.textElements,
    required this.overallConfidence,
    required this.processingTime,
  });

  /// Get all text as a single string
  String get fullText {
    return textElements.map((e) => e.text).join(' ');
  }

  /// Get text elements that likely contain numeric values
  List<TextElement> get numericElements {
    return textElements.where((element) {
      return RegExp(r'\d+\.?\d*').hasMatch(element.text);
    }).toList();
  }

  @override
  String toString() {
    return 'OCRResult(elements: ${textElements.length}, confidence: ${(overallConfidence * 100).toStringAsFixed(1)}%, time: ${processingTime.inMilliseconds}ms)';
  }
}
