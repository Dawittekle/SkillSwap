export 'package:skill_swap/core/widgets/app_snackbar.dart';

// Simple form validators used by auth, profile, and skill forms.
String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Email is required.';
  if (!email.contains('@') || !email.contains('.')) {
    return 'Enter a valid email address.';
  }
  return null;
}

String? validatePassword(String? value) {
  final password = value ?? '';
  if (password.isEmpty) return 'Password is required.';
  if (password.length < 6) return 'Password must be at least 6 characters.';
  return null;
}

String? validateRequired(String? value, String fieldName) {
  if ((value ?? '').trim().isEmpty) return '$fieldName is required.';
  return null;
}
