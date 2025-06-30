// lib/features/auth/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lightore/features/auth/application/auth_provider.dart';
import 'auth_error_mapper.dart';

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
      if (widget.onLoginSuccess != null) {
        widget.onLoginSuccess!(context);
      } else {
        Navigator.of(context).pushReplacementNamed('/home');
      }
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
  Widget _buildError() => _errorMessage == null
      ? const SizedBox.shrink()
      : Column(children: [
          Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
        ]);

  Widget _buildInfo() => _infoMessage == null
      ? const SizedBox.shrink()
      : Column(children: [
          Text(_infoMessage!, style: const TextStyle(color: Colors.green)),
          const SizedBox(height: 16),
        ]);

  Widget _buildEmailField() => TextFormField(
        key: const Key('login_email_field'),
        decoration: const InputDecoration(labelText: 'Email'),
        keyboardType: TextInputType.emailAddress,
        autofocus: true,
        onChanged: (v) {
          if (v != _email) {
            setState(() {
              _email = v;
              _clearMessages();
            });
          }
        },
        validator: (v) =>
            v != null && v.contains('@') ? null : 'Enter a valid email',
      );

  Widget _buildPasswordField() => TextFormField(
        key: const Key('login_password_field'),
        decoration: const InputDecoration(labelText: 'Password'),
        obscureText: true,
        onChanged: (v) {
          if (v != _password) {
            setState(() {
              _password = v;
              _clearMessages();
            });
          }
        },
        validator: (v) => v != null && v.length >= 6 ? null : 'Min 6 chars',
      );

  Widget _buildLoginButton() {
    final canLogin = _canLogin();
    // debugPrint('BUILD LOGIN BUTTON: loading=$_loading, canLogin=$canLogin');
    return ElevatedButton(
      key: const Key('login_button'),
      onPressed: _loading || !canLogin ? null : _login,
      child: _loading ? const CircularProgressIndicator() : const Text('Login'),
    );
  }

  bool _canLogin() {
    return _email.contains('@') && _password.length >= 6;
  }

  Widget _buildForgotPasswordButton() => TextButton(
        key: const Key('forgot_password_button'),
        onPressed: _loading ? null : _resetPassword,
        child: const Text('Forgot password?'),
      );

  Widget _buildRegisterButton() => TextButton(
        key: const Key('go_to_register_button'),
        onPressed: _loading
            ? null
            : () => Navigator.of(context).pushReplacementNamed('/register'),
        child: const Text('Don\'t have an account? Register'),
      );

  @override
  Widget build(BuildContext context) {
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
                _buildError(),
                _buildInfo(),
                _buildEmailField(),
                const SizedBox(height: 16),
                _buildPasswordField(),
                const SizedBox(height: 24),
                _buildLoginButton(),
                _buildForgotPasswordButton(),
                _buildRegisterButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
