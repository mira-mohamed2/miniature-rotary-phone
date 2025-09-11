/// Regular expression patterns for parsing bill text
class RegexPatterns {
  
  /// Pattern for matching prices (e.g., $12.99, 12.99, $12)
  static final RegExp pricePattern = RegExp(
    r'\$?(\d{1,6}\.?\d{0,2})',
    caseSensitive: false,
  );
  
  /// Pattern for matching percentages (e.g., 8.25%, 10%)
  static final RegExp percentagePattern = RegExp(
    r'(\d{1,2}\.?\d{0,2})%',
    caseSensitive: false,
  );
  
  /// Pattern for identifying total lines
  static final RegExp totalPattern = RegExp(
    r'\b(total|sum|amount|grand\s*total|final\s*total)\b',
    caseSensitive: false,
  );
  
  /// Pattern for identifying subtotal lines
  static final RegExp subtotalPattern = RegExp(
    r'\b(subtotal|sub-total|sub\s*total)\b',
    caseSensitive: false,
  );
  
  /// Pattern for identifying tax lines
  static final RegExp taxPattern = RegExp(
    r'\b(tax|vat|gst|sales\s*tax|state\s*tax)\b',
    caseSensitive: false,
  );
  
  /// Pattern for identifying tip/gratuity lines
  static final RegExp tipPattern = RegExp(
    r'\b(tip|gratuity|service\s*charge)\b',
    caseSensitive: false,
  );
  
  /// Pattern for identifying discount lines
  static final RegExp discountPattern = RegExp(
    r'\b(discount|savings|off|promotion|coupon)\b',
    caseSensitive: false,
  );
  
  /// Pattern for matching quantity indicators
  static final RegExp quantityPattern = RegExp(
    r'\b(\d{1,3})\s*[x×]\s*',
    caseSensitive: false,
  );
  
  /// Pattern for matching item codes or SKUs
  static final RegExp itemCodePattern = RegExp(
    r'\b([A-Z0-9]{3,10})\b',
    caseSensitive: false,
  );
  
  /// Pattern for matching dates
  static final RegExp datePattern = RegExp(
    r'\b(\d{1,2}[\/\-\.]\d{1,2}[\/\-\.]\d{2,4})\b',
    caseSensitive: false,
  );
  
  /// Pattern for matching time
  static final RegExp timePattern = RegExp(
    r'\b(\d{1,2}:\d{2}(?::\d{2})?\s*(?:AM|PM)?)\b',
    caseSensitive: false,
  );
  
  /// Pattern for extracting pure numeric values
  static final RegExp numericPattern = RegExp(r'\d+\.?\d*');
  
  /// Pattern for detecting line items (text followed by price)
  static final RegExp lineItemPattern = RegExp(
    r'^(.+?)\s+\$?(\d+\.?\d{0,2})$',
    multiLine: true,
  );
  
  /// Clean text by removing extra whitespace and special characters
  static String cleanText(String text) {
    return text
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[^\w\s\$\.\%\-]'), '')
        .trim();
  }
  
  /// Extract all numeric values from text
  static List<double> extractNumbers(String text) {
    final matches = numericPattern.allMatches(text);
    return matches
        .map((match) => double.tryParse(match.group(0) ?? ''))
        .where((value) => value != null)
        .cast<double>()
        .toList();
  }
  
  /// Extract price from text string
  static double? extractPrice(String text) {
    final match = pricePattern.firstMatch(text);
    if (match != null) {
      return double.tryParse(match.group(1) ?? '');
    }
    return null;
  }
  
  /// Extract percentage from text string
  static double? extractPercentage(String text) {
    final match = percentagePattern.firstMatch(text);
    if (match != null) {
      return double.tryParse(match.group(1) ?? '');
    }
    return null;
  }
  
  /// Check if text contains a total indicator
  static bool isTotal(String text) {
    return totalPattern.hasMatch(text.toLowerCase());
  }
  
  /// Check if text contains a subtotal indicator
  static bool isSubtotal(String text) {
    return subtotalPattern.hasMatch(text.toLowerCase());
  }
  
  /// Check if text contains a tax indicator
  static bool isTax(String text) {
    return taxPattern.hasMatch(text.toLowerCase());
  }
  
  /// Check if text contains a tip indicator
  static bool isTip(String text) {
    return tipPattern.hasMatch(text.toLowerCase());
  }
  
  /// Check if text contains a discount indicator
  static bool isDiscount(String text) {
    return discountPattern.hasMatch(text.toLowerCase());
  }
}
