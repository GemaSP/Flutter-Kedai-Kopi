class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password harus terdiri dari minimal 6 karakter';
    }
    return null;
  }

  static String? validatePasswordConfirmation(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value != password) {
      return 'Password harus sama';
    }
    return null;
  }

  static String? validateRequired(String? value, {String fieldname = 'Field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldname tidak boleh kosong';
    }
    return null;
  }
}