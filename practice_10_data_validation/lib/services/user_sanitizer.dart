class UserSanitizer {
  // Очищення імені: видаляємо зайві пробіли та нормалізуємо їх.
  static String sanitizeName(String name) {
    return name.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  // Очищення email: прибираємо пробіли та переводимо в нижній регістр.
  static String sanitizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  // Очищення телефону: залишаємо тільки цифри та початковий знак +.
  static String sanitizePhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final hasPlus = cleaned.startsWith('+');
    final digits = cleaned.replaceAll('+', '');

    return hasPlus ? '+$digits' : digits;
  }
}
