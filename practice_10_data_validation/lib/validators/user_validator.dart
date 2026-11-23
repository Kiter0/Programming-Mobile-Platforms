class UserValidator {
  // Перевірка імені користувача.
  static String? validateName(String name) {
    if (name.trim().isEmpty) {
      return 'Введіть ім’я користувача';
    }

    if (name.trim().length < 2) {
      return 'Ім’я повинно містити щонайменше 2 символи';
    }

    if (name.trim().length > 50) {
      return 'Ім’я не повинно перевищувати 50 символів';
    }

    return null;
  }

  // Перевірка електронної пошти.
  static String? validateEmail(String email) {
    if (email.trim().isEmpty) {
      return 'Введіть електронну пошту';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email.trim())) {
      return 'Введіть коректну електронну пошту';
    }

    return null;
  }

  // Перевірка номера телефону.
  static String? validatePhone(String phone) {
    if (phone.trim().isEmpty) {
      return 'Введіть номер телефону';
    }

    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');

    if (!phoneRegex.hasMatch(phone.trim())) {
      return 'Номер повинен містити від 10 до 15 цифр';
    }

    return null;
  }

  // Загальна перевірка всіх полів користувача.
  static Map<String, String> validateUser({
    required String name,
    required String email,
    required String phone,
  }) {
    final errors = <String, String>{};

    final nameError = validateName(name);
    final emailError = validateEmail(email);
    final phoneError = validatePhone(phone);

    if (nameError != null) errors['name'] = nameError;
    if (emailError != null) errors['email'] = emailError;
    if (phoneError != null) errors['phone'] = phoneError;

    return errors;
  }
}
