import 'package:firebase_auth/firebase_auth.dart';

const String noInternetMessage =
    'No internet connection. Please check your connection and try again.';
const String fallbackErrorMessage = 'Something went wrong. Please try again.';

String friendlyFirebaseErrorMessage(
  Object? error, {
  String fallback = fallbackErrorMessage,
}) {
  if (error is FirebaseAuthException) {
    return friendlyAuthErrorMessage(error);
  }

  if (error is FirebaseException) {
    return friendlyFirestoreErrorMessage(error);
  }

  final message = error?.toString().replaceFirst('Exception: ', '').trim();
  if (message == null || message.isEmpty) return fallback;
  if (_looksLikeNetworkMessage(message)) return noInternetMessage;

  return message;
}

String friendlyAuthErrorMessage(FirebaseAuthException error) {
  switch (error.code) {
    case 'invalid-email':
      return 'Please enter a valid email address.';
    case 'user-not-found':
      return 'No account found with this email. Please sign up first.';
    case 'wrong-password':
    case 'invalid-credential':
      return 'Incorrect email or password. Please check your details and try again.';
    case 'email-already-in-use':
      return 'This email is already registered. Please log in instead.';
    case 'weak-password':
      return 'Please choose a stronger password.';
    case 'network-request-failed':
      return noInternetMessage;
    case 'too-many-requests':
      return 'Too many attempts. Please wait a moment and try again.';
    default:
      return fallbackErrorMessage;
  }
}

String friendlyFirestoreErrorMessage(FirebaseException error) {
  switch (error.code) {
    case 'unavailable':
      return noInternetMessage;
    case 'permission-denied':
      return 'You do not have permission to access this data. Please sign in again.';
    case 'not-found':
      return 'The requested data was not found.';
    case 'deadline-exceeded':
      return 'This is taking longer than usual. Please check your connection and try again.';
    default:
      return fallbackErrorMessage;
  }
}

bool isNetworkFirebaseError(Object? error) {
  if (error is FirebaseAuthException) {
    return error.code == 'network-request-failed';
  }

  if (error is FirebaseException) {
    return error.code == 'unavailable';
  }

  return _looksLikeNetworkMessage(error?.toString() ?? '');
}

bool _looksLikeNetworkMessage(String message) {
  final normalized = message.toLowerCase();

  return normalized.contains('network-request-failed') ||
      normalized.contains('no internet') ||
      normalized.contains('network error') ||
      normalized.contains('unavailable');
}
