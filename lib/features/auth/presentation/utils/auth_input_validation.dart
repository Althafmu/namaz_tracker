class AuthInputValidation {
  static final RegExp _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  static String? validateName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return 'Please enter your full name';
    }
    if (trimmed.length > 100) {
      return 'Name must be under 100 characters';
    }
    return null;
  }

  static String? validateEmail(String email) {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      return 'Please enter your email';
    }
    if (trimmed.length > 254 || !_emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Please enter your password';
    }
    if (password.length < 8 || password.length > 128) {
      return 'Password must be 8-128 characters';
    }
    return null;
  }

  static String? validateLogin({
    required String email,
    required String password,
  }) {
    return validateEmail(email) ?? validatePassword(password);
  }

  static String? validateSignup({
    required String name,
    required String email,
    required String password,
  }) {
    return validateName(name) ??
        validateEmail(email) ??
        validatePassword(password);
  }
}
