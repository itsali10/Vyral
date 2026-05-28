import '../services/api_client.dart';

/// Turns backend error text into clear messages for the user (no backend changes).
String friendlyApiMessage(ApiException error, {bool authContext = false}) {
  final raw = error.message.trim();
  final lower = raw.toLowerCase();

  if (lower.contains('socket') ||
      lower.contains('connection refused') ||
      lower.contains('failed host lookup') ||
      lower.contains('network is unreachable')) {
    return 'Cannot reach the server. Start the backend (npm run start:dev) and check your connection.';
  }
  if (lower.contains('timed out') || lower.contains('timeout')) {
    return 'The server took too long to respond. Make sure the backend is running.';
  }

  if (authContext) {
    return _friendlyAuthMessage(raw, lower, error.statusCode);
  }

  return _friendlyGeneralMessage(raw, lower, error.statusCode);
}

String _friendlyAuthMessage(String raw, String lower, int? statusCode) {
  if (lower.contains('account not found')) {
    return "This account doesn't exist. Please sign up first.";
  }
  if (lower.contains('invalid email or password')) {
    return "We couldn't sign you in. Wrong email or password, or this account isn't registered yet — try Sign up.";
  }
  if (lower.contains('email already registered')) {
    return 'An account with this email already exists. Try logging in instead.';
  }
  if (lower.contains('username already taken')) {
    return 'That username is already taken. Choose another one.';
  }
  if (lower.contains('account is suspended')) {
    return 'This account has been suspended. Contact support if you think this is a mistake.';
  }
  if (lower.contains('invalid google token')) {
    return 'Google sign-in failed. Try again or use email and password.';
  }
  if (lower.contains('invalid or expired reset token')) {
    return 'This reset link is invalid or expired. Request a new one.';
  }
  if (lower.contains('invalid or expired refresh token')) {
    return 'Your session expired. Please log in again.';
  }
  if (lower.contains('no session returned')) {
    return 'Sign-in completed but no session was returned. Try again.';
  }
  if (lower.contains('account created but login failed')) {
    return 'Account was created but sign-in failed. Try logging in with your email and password.';
  }
  if (statusCode == 401) {
    return "We couldn't sign you in. Check your details or create an account.";
  }
  if (statusCode == 409) {
    return raw.isNotEmpty ? raw : 'That information is already in use.';
  }
  if (statusCode == 400) {
    return raw.isNotEmpty ? raw : 'Please check your information and try again.';
  }

  return raw.isNotEmpty ? raw : 'Something went wrong. Please try again.';
}

String _friendlyGeneralMessage(String raw, String lower, int? statusCode) {
  if (statusCode == 401) {
    return 'Please log in again to continue.';
  }
  if (statusCode == 403) {
    return "You don't have permission to do that.";
  }
  if (statusCode == 404) {
    return 'That item was not found.';
  }
  if (statusCode == 409) {
    return raw.isNotEmpty ? raw : 'This action conflicts with existing data.';
  }
  if (statusCode != null && statusCode >= 500) {
    return 'Server error. Try again in a moment.';
  }
  return raw.isNotEmpty ? raw : 'Something went wrong. Please try again.';
}
