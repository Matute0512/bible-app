abstract final class TextNormalizer {
  static const Set<String> _minorWords = {'de', 'los', 'las', 'del', 'la', 'el', 'y'};

  /// Normalizes an all-caps or mixed-case string to Spanish Title Case.
  /// Minor connecting words (de, los, del, etc.) stay lowercased unless they start the text.
  static String toTitleCase(String text) {
    if (text.isEmpty) return text;
    final words = text.split(' ');
    final result = <String>[];

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      if (word.isEmpty) continue;

      final lower = word.toLowerCase();
      if (i > 0 && _minorWords.contains(lower)) {
        result.add(lower);
      } else {
        // Capitalize first char (handling unicode characters like Á, É, Í, Ó, Ú)
        final firstChar = word[0].toUpperCase();
        final rest = word.length > 1 ? word.substring(1).toLowerCase() : '';
        result.add('$firstChar$rest');
      }
    }

    return result.join(' ');
  }

  /// Removes diacritics/accents and converts to lowercase for diacritic-insensitive search.
  static String normalizeForSearch(String text) {
    var result = text.toLowerCase();
    const withAccents = 'áàäâéèëêíìïîóòöôúùüûñ';
    const withoutAccents = 'aaaaeeeeiiiioooouuuun';

    for (int i = 0; i < withAccents.length; i++) {
      result = result.replaceAll(withAccents[i], withoutAccents[i]);
    }
    return result;
  }
}

