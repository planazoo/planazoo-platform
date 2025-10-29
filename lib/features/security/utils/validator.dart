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
}


