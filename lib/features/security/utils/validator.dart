class Validator {
  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    final re = RegExp(r'^[\w\.-]+@[\w\.-]+\.[A-Za-z]{2,}$');
    return re.hasMatch(email.trim());
  }

  static bool isSafeUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    final u = url.trim().toLowerCase();
    return u.startsWith('http://') || u.startsWith('https://');
  }

  // Username: 3-30 chars, lowercase letters, numbers, underscore
  static bool isValidUsername(String? username) {
    if (username == null) return false;
    final u = username.trim();
    if (u.length < 3 || u.length > 30) return false;
    final re = RegExp(r'^[a-z0-9_]{3,30}$');
    return re.hasMatch(u);
  }
}


