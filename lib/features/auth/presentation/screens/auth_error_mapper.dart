String mapAuthErrorToMessage(Object e) {
  var msg = e.toString();
  // Remove 'Exception: ' prefix if present
  if (msg.startsWith('Exception: ')) {
    msg = msg.replaceFirst('Exception: ', '');
  }
  if (msg.contains('user-not-found')) {
    return 'No user found for that email.';
  } else if (msg.contains('wrong-password')) {
    return 'Incorrect password.';
  } else if (msg.contains('invalid-email')) {
    return 'The email address is invalid.';
  } else if (msg.contains('network-request-failed')) {
    return 'Network error. Please check your connection.';
  } else if (msg.contains('too-many-requests')) {
    return 'Too many attempts. Please try again later.';
  } else if (msg.contains('Login failed')) {
    return 'Login failed. Please check your credentials.';
  } else if (msg.contains('Register failed')) {
    return 'Register failed. Please check your credentials.';
  } else if (msg.contains('password is invalid')) {
    return 'Password is invalid.';
  } else if (msg.contains('email-already-in-use')) {
    return 'This email is already registered.';
  }
  return 'Authentication failed. Please try again.';
}
