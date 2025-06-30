import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lightore/features/auth/application/auth_provider.dart';
import 'auth_error_mapper.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String? _errorMessage;
  String? _infoMessage;
  bool _loading = false;

  // --- Auth Actions ---
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    _setLoading(true, clearMessages: true);
    try {
      await ref
          .read(authProvider.notifier)
          .registerWithEmail(_email, _password);
      if (mounted) Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      _setError(mapAuthErrorToMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  // --- State Helpers ---
  void _setLoading(bool value, {bool clearMessages = false}) {
    setState(() {
      _loading = value;
      if (clearMessages) {
        _errorMessage = null;
        _infoMessage = null;
      }
    });
  }

  void _setError(Object e) {
    setState(() {
      _errorMessage = mapAuthErrorToMessage(e);
      _infoMessage = null;
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
        decoration: const InputDecoration(labelText: 'Email'),
        keyboardType: TextInputType.emailAddress,
        onChanged: (v) {
          _email = v;
          _clearMessages();
        },
        validator: (v) =>
            v != null && v.contains('@') ? null : 'Enter a valid email',
      );

  Widget _buildPasswordField() => TextFormField(
        decoration: const InputDecoration(labelText: 'Password'),
        obscureText: true,
        onChanged: (v) {
          _password = v;
          _clearMessages();
        },
        validator: (v) => v != null && v.length >= 6 ? null : 'Min 6 chars',
      );

  Widget _buildRegisterButton() => ElevatedButton(
        onPressed: _loading ? null : _register,
        child: _loading
            ? const CircularProgressIndicator()
            : const Text('Register'),
      );

  Widget _buildLoginButton() => TextButton(
        onPressed: _loading
            ? null
            : () => Navigator.of(context).pushReplacementNamed('/login'),
        child: const Text('Already have an account? Login'),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildError(),
                _buildInfo(),
                _buildEmailField(),
                const SizedBox(height: 16),
                _buildPasswordField(),
                const SizedBox(height: 24),
                _buildRegisterButton(),
                _buildLoginButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
