import '../models/app_config.dart';

class ParsedResult {
  final String category;
  final String type;
  final String value;

  ParsedResult({
    required this.category,
    required this.type,
    required this.value,
  });
}

class SpeechParserService {
  ParsedResult? parse(String text, AppConfig config) {
    if (text.isEmpty || text.contains('Konuşmaya başlamak için butona basın...')) return null;

    final lowerText = text.toLowerCase();

    for (var category in config.categories) {
      final lowerCategoryName = category.name.toLowerCase();
      if (lowerText.contains(lowerCategoryName)) {
        for (var type in category.types) {
          final lowerTypeName = type.toLowerCase();
          if (lowerText.contains(lowerTypeName)) {
            final value = _extractValue(text);
            
            if (value != null) {
              return ParsedResult(
                category: category.name,
                type: type,
                value: value,
              );
            }
          }
        }
      }
    }

    return null;
  }

  String? _extractValue(String text) {
    // Try to find a number in the text.
    // Supports integers and decimals (e.g., 500, 500.50, 500,50)
    final numberRegex = RegExp(r'(\d+([.,]\d+)?)');
    final match = numberRegex.firstMatch(text);
    
    if (match != null) {
      // Replace comma with dot for consistent parsing if needed
      return match.group(0)!.replaceAll(',', '.');
    }
    
    return null;
  }
}
