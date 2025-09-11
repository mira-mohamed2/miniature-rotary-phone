import 'dart:io';
import 'dart:ui';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart' hide TextElement;
import '../models/ocr_result.dart';
import '../models/bill_item.dart';
import '../utils/regex_patterns.dart';

/// Service for OCR text recognition and bill structure parsing
class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  /// Extract text from image using Google ML Kit
  Future<OCRResult> extractTextFromImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final stopwatch = Stopwatch()..start();
      
      final recognizedText = await _textRecognizer.processImage(inputImage);
      stopwatch.stop();

      final textElements = <TextElement>[];
      double totalConfidence = 0.0;
      int elementCount = 0;

      // Process each text block
      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          for (final element in line.elements) {
            final boundingBox = Rect.fromLTRB(
              element.boundingBox.left.toDouble(),
              element.boundingBox.top.toDouble(),
              element.boundingBox.right.toDouble(),
              element.boundingBox.bottom.toDouble(),
            );

            // Use a confidence estimation based on text characteristics
            final confidence = _estimateConfidence(element.text);
            totalConfidence += confidence;
            elementCount++;

            textElements.add(TextElement(
              text: element.text,
              boundingBox: boundingBox,
              confidence: confidence,
            ));
          }
        }
      }

      final overallConfidence = elementCount > 0 ? totalConfidence / elementCount : 0.0;

      return OCRResult(
        textElements: textElements,
        overallConfidence: overallConfidence,
        processingTime: stopwatch.elapsed,
      );
    } catch (e) {
      throw Exception('OCR processing failed: ${e.toString()}');
    }
  }

  /// Filter and categorize text elements
  List<String> filterNumericText(List<TextElement> elements) {
    return elements
        .where((element) => RegexPatterns.numericPattern.hasMatch(element.text))
        .map((element) => element.text)
        .cast<String>()
        .toList();
  }

  /// Extract bill structure from OCR results
  Future<BillStructure?> extractBillStructure(OCRResult ocrResult) async {
    try {
      final elements = ocrResult.textElements;
      if (elements.isEmpty) return null;

      // Sort elements by vertical position (top to bottom)
      elements.sort((a, b) => a.boundingBox.top.compareTo(b.boundingBox.top));

      // Extract bill components
      final items = _extractLineItems(elements);
      final financials = _extractFinancialTotals(elements);

      // If we can't extract basic structure, return null
      if (items.isEmpty && financials['total'] == null) {
        return null;
      }

      return BillStructure(
        items: items,
        subtotal: financials['subtotal'] ?? _calculateSubtotalFromItems(items),
        taxRate: financials['taxRate'] ?? 0.0,
        taxAmount: financials['tax'] ?? 0.0,
        total: financials['total'] ?? 0.0,
        tipAmount: financials['tip'] ?? 0.0,
        finalTotal: financials['finalTotal'] ?? financials['total'] ?? 0.0,
      );
    } catch (e) {
      // If parsing fails, return null rather than throwing
      return null;
    }
  }

  /// Extract line items from text elements
  List<BillItem> _extractLineItems(List<TextElement> elements) {
    final items = <BillItem>[];
    
    for (int i = 0; i < elements.length; i++) {
      final element = elements[i];
      final text = element.text.trim();
      
      // Skip if this looks like a total line
      if (RegexPatterns.isTotal(text) || 
          RegexPatterns.isSubtotal(text) || 
          RegexPatterns.isTax(text)) {
        continue;
      }

      // Look for price patterns in current or next elements
      final price = RegexPatterns.extractPrice(text);
      if (price != null && price > 0) {
        // Try to find item name by looking at previous elements on same line
        String itemName = _findItemName(elements, i);
        
        if (itemName.isNotEmpty) {
          // Extract quantity if present
          final quantity = _extractQuantity(text) ?? 1;
          
          items.add(BillItem(
            name: itemName,
            price: price / quantity, // Unit price
            quantity: quantity,
            lineTotal: price,
            boundingBox: element.boundingBox,
          ));
        }
      }
    }

    return items;
  }

  /// Extract financial totals (subtotal, tax, total) from text elements
  Map<String, double?> _extractFinancialTotals(List<TextElement> elements) {
    final result = <String, double?>{
      'subtotal': null,
      'tax': null,
      'taxRate': null,
      'tip': null,
      'total': null,
      'finalTotal': null,
    };

    for (int i = 0; i < elements.length; i++) {
      final element = elements[i];
      final text = element.text.toLowerCase().trim();

      // Look for subtotal
      if (RegexPatterns.isSubtotal(text)) {
        result['subtotal'] = _findAssociatedPrice(elements, i);
      }
      // Look for tax
      else if (RegexPatterns.isTax(text)) {
        result['tax'] = _findAssociatedPrice(elements, i);
        result['taxRate'] = RegexPatterns.extractPercentage(text);
      }
      // Look for tip
      else if (RegexPatterns.isTip(text)) {
        result['tip'] = _findAssociatedPrice(elements, i);
      }
      // Look for total
      else if (RegexPatterns.isTotal(text)) {
        result['total'] = _findAssociatedPrice(elements, i);
        result['finalTotal'] = result['total'];
      }
    }

    return result;
  }

  /// Find item name by looking at nearby text elements
  String _findItemName(List<TextElement> elements, int priceIndex) {
    final priceElement = elements[priceIndex];
    final priceY = priceElement.boundingBox.center.dy;
    
    // Look for text elements on the same horizontal line (within tolerance)
    const yTolerance = 20.0;
    
    final nameElements = <TextElement>[];
    
    for (final element in elements) {
      final elementY = element.boundingBox.center.dy;
      
      // Check if on same line and to the left of price
      if ((elementY - priceY).abs() <= yTolerance && 
          element.boundingBox.right < priceElement.boundingBox.left) {
        
        // Skip if this element also contains a price
        if (RegexPatterns.extractPrice(element.text) == null) {
          nameElements.add(element);
        }
      }
    }
    
    // Sort by x position (left to right)
    nameElements.sort((a, b) => a.boundingBox.left.compareTo(b.boundingBox.left));
    
    // Combine text elements to form item name
    return nameElements.map((e) => e.text).join(' ').trim();
  }

  /// Find price associated with a label (subtotal, tax, etc.)
  double? _findAssociatedPrice(List<TextElement> elements, int labelIndex) {
    final labelElement = elements[labelIndex];
    final labelY = labelElement.boundingBox.center.dy;
    
    // Look for prices on the same line or nearby lines
    const yTolerance = 30.0;
    
    for (final element in elements) {
      final elementY = element.boundingBox.center.dy;
      
      if ((elementY - labelY).abs() <= yTolerance) {
        final price = RegexPatterns.extractPrice(element.text);
        if (price != null) {
          return price;
        }
      }
    }
    
    return null;
  }

  /// Extract quantity from text if present
  int? _extractQuantity(String text) {
    final match = RegexPatterns.quantityPattern.firstMatch(text);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '');
    }
    return null;
  }

  /// Calculate subtotal from items if not explicitly found
  double _calculateSubtotalFromItems(List<BillItem> items) {
    return items.fold(0.0, (sum, item) => sum + item.lineTotal);
  }

  /// Estimate confidence for a text element based on characteristics
  double _estimateConfidence(String text) {
    double confidence = 0.7; // Base confidence
    
    // Boost confidence for numeric text (likely prices)
    if (RegexPatterns.numericPattern.hasMatch(text)) {
      confidence += 0.2;
    }
    
    // Boost confidence for common bill terms
    if (RegexPatterns.isTotal(text) || 
        RegexPatterns.isSubtotal(text) || 
        RegexPatterns.isTax(text)) {
      confidence += 0.1;
    }
    
    // Penalize very short text (likely OCR errors)
    if (text.length < 2) {
      confidence -= 0.3;
    }
    
    // Penalize text with many special characters
    final specialCharCount = text.replaceAll(RegExp(r'[a-zA-Z0-9\s\.\$\%]'), '').length;
    confidence -= (specialCharCount * 0.05);
    
    return confidence.clamp(0.0, 1.0);
  }

  /// Parse price from text string
  double? parsePrice(String text) {
    return RegexPatterns.extractPrice(text);
  }

  /// Parse percentage from text string
  double? parsePercentage(String text) {
    return RegexPatterns.extractPercentage(text);
  }

  /// Dispose of resources
  void dispose() {
    _textRecognizer.close();
  }
}
