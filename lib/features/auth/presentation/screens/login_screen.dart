// lib/features/auth/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lightore/features/auth/application/auth_provider.dart';
import 'package:lightore/constants.dart';
import 'package:lightore/features/auth/presentation/screens/auth_error_mapper.dart';
import '../widgets/error_banner.dart';
import '../widgets/info_banner.dart';
import '../widgets/email_field.dart';
import '../widgets/password_field.dart';
import '../widgets/google_login_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.onLoginSuccess});

  /// Optional callback for navigation after successful login (for testability)
  final void Function(BuildContext context)? onLoginSuccess;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;
  String? _infoMessage; // For non-error info (e.g., password reset sent)
  String _email = '';
  String _password = '';
  bool _loading = false;

  // --- Auth Actions ---
  Future<void> _login() async {
    // debugPrint('LOGIN: Attempting login with email=[4memail[24m');
    if (!_formKey.currentState!.validate()) return;
    _setLoading(true, clearMessages: true);
    try {
      await ref.read(authProvider.notifier).signInWithEmail(_email, _password);
      if (!mounted) return;
      // debugPrint('LOGIN: Success, calling onLoginSuccess? [4mwidget.onLoginSuccess != null[24m');
      widget.onLoginSuccess?.call(context);
      context.go('/home');
    } catch (e) {
      // debugPrint('LOGIN: Exception caught: ' + e.toString());
      _setError(mapAuthErrorToMessage(e));
    } finally {
      if (mounted) _setLoading(false);
    }
  }

  Future<void> _resetPassword() async {
    if (_email.isEmpty) {
      _setError('Enter your email to reset password');
      return;
    }
    _setLoading(true, clearMessages: true);
    try {
      await ref.read(authProvider.notifier).sendPasswordResetEmail(_email);
      _setInfo('Password reset email sent!');
    } catch (e) {
      _setError(mapAuthErrorToMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  // --- State Helpers ---
  void _setLoading(bool value, {bool clearMessages = false}) {
    if (!mounted) return;
    // debugPrint('SET LOADING: ' + value.toString());
    setState(() {
      _loading = value;
      if (clearMessages) {
        _errorMessage = null;
        _infoMessage = null;
      }
    });
  }

  void _setError(Object e) {
    if (!mounted) return;
    final msg = e is String ? e : e.toString();
    // debugPrint('SET ERROR: ' + msg);
    setState(() {
      _errorMessage = msg;
      _infoMessage = null;
    });
  }

  void _setInfo(String msg) {
    // debugPrint('SET INFO: ' + msg);
    setState(() {
      _infoMessage = msg;
      _errorMessage = null;
    });
  }

  void _clearMessages() {
    if (_errorMessage != null || _infoMessage != null) {
      setState(() {
        _errorMessage = null;
        _infoMessage = null;
      });
    }
  }

  // --- Widget Builders ---
  Widget _buildLoginButton() {
    final canLogin = _canLogin();
    return ElevatedButton(
      key: AppKeys.loginButton,
      onPressed: _loading || !canLogin ? null : _login,
      style: AppTheme.buttonStyle,
      child: _loading
          ? const CircularProgressIndicator()
          : const Text(AppLabels.login),
    );
  }

  bool _canLogin() {
    return _email.contains('@') && _password.length >= 6;
  }

  Widget _buildForgotPasswordButton() => TextButton(
        key: AppKeys.forgotPasswordButton,
        onPressed: _loading ? null : _resetPassword,
        child: const Text(AppLabels.forgotPassword),
      );

  Widget _buildRegisterButton() => TextButton(
        key: AppKeys.registerButton,
        onPressed: _loading
            ? null
            : () {
                debugPrint('Register button pressed');
                context.go(AppRoutes.register);
                debugPrint('context.go(/register) called');
              },
        child: const Text(AppLabels.register),
      );

  @override
  Widget build(BuildContext context) {
    debugPrint('LoginScreen build called');
    return Scaffold(
      appBar: AppBar(title: const Text('Login or Pay')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ErrorBanner(message: _errorMessage),
                InfoBanner(message: _infoMessage),
                EmailField(
                  value: _email,
                  onChanged: (v) => setState(() => _email = v),
                  onClearMessages: _clearMessages,
                ),
                const SizedBox(height: 16),
                PasswordField(
                  value: _password,
                  onChanged: (v) => setState(() => _password = v),
                  onClearMessages: _clearMessages,
                ),
                const SizedBox(height: 24),
                _buildLoginButton(),
                _buildForgotPasswordButton(),
                _buildRegisterButton(),
                GoogleLoginButton(
                  loading: _loading,
                  onError: (msg) => _setError(msg),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
