import 'dart:math';

class StringUtils {
  /// Generates a random string of specified length
  ///
  /// [length] determines how long the string will be (defaults to 10)
  /// [includeLetters] determines if letters should be included (default: true)
  /// [includeNumbers] determines if numbers should be included (default: true)
  /// [includeSpecial] determines if special characters should be included (default: false)
  static String generateRandomString({
    int length = 10,
    bool includeLetters = true,
    bool includeNumbers = true,
    bool includeSpecial = false,
  }) {
    final random = Random();
    const letterLowercase = 'abcdefghijklmnopqrstuvwxyz';
    const letterUppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    const special = '!@#\$%^&*()_+{}|:<>?-=[];,./';

    String chars = '';
    if (includeLetters) {
      chars += letterLowercase + letterUppercase;
    }
    if (includeNumbers) {
      chars += numbers;
    }
    if (includeSpecial) {
      chars += special;
    }

    if (chars.isEmpty) {
      chars = letterLowercase + numbers; // Default if nothing selected
    }

    return String.fromCharCodes(List.generate(
        length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  /// Generates a user-friendly random ID (no special chars, easier to read)
  static String generateUserId({int length = 8}) {
    return generateRandomString(
      length: length,
      includeLetters: true,
      includeNumbers: true,
      includeSpecial: false,
    );
  }
}
