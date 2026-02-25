class FirebaseUtils {
  /// Sanitizes string inputs to prevent exceptionally large writes to Firestore
  static String sanitizeString(String? input, {int maxLength = 100}) {
    if (input == null) return "";
    String sanitized = input.trim();
    if (sanitized.length > maxLength) {
      sanitized = sanitized.substring(0, maxLength);
    }
    return sanitized;
  }
}
