import 'package:flutter/material.dart';

// Keys
class AppKeys {
  static const googleLoginButton = Key('google_login_button');
  static const loginButton = Key('login_button');
  static const emailField = Key('login_email_field');
  static const passwordField = Key('login_password_field');
  static const forgotPasswordButton = Key('forgot_password_button');
  static const registerButton = Key('go_to_register_button');
  static const logoutButton = Key('logout_button');
}

// Labels
class AppLabels {
  static const loginWithGoogle = 'Login with Google';
  static const login = 'Login';
  static const forgotPassword = 'Forgot password?';
  static const register = "Don't have an account? Register";
}

// Error messages
class AppErrors {
  static const googleSignInNotSupported =
      'Google sign-in not supported on this platform';
  static const googleSignInFailed = 'Google sign-in failed';
  static const enterValidEmail = 'Enter a valid email';
  static const minPassword = 'Min 6 chars';
  static const enterEmailToReset = 'Enter your email to reset password';
  static const passwordResetSent = 'Password reset email sent!';
}

// Routes
class AppRoutes {
  static const home = '/home';
  static const login = '/login';
  static const register = '/register';
}

// Theming
class AppTheme {
  static const primaryColor = Colors.blue;
  static const errorColor = Colors.red;
  static const successColor = Colors.green;
  static final buttonStyle = ElevatedButton.styleFrom(
    minimumSize: const Size.fromHeight(48),
    textStyle: const TextStyle(fontSize: 16),
  );
}
