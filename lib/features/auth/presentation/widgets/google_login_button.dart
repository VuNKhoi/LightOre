import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:lightore/constants.dart';

class GoogleLoginButton extends StatefulWidget {
  final bool loading;
  final void Function(String error)? onError;
  final void Function()? onSuccess;
  const GoogleLoginButton(
      {Key? key, required this.loading, this.onError, this.onSuccess})
      : super(key: key);

  @override
  State<GoogleLoginButton> createState() => _GoogleLoginButtonState();
}

class _GoogleLoginButtonState extends State<GoogleLoginButton> {
  bool _localLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _localLoading = true);
    try {
      final signIn = GoogleSignIn.instance;
      if (!signIn.supportsAuthenticate()) {
        throw Exception(AppErrors.googleSignInNotSupported);
      }
      final user = await signIn.authenticate();
      final auth = user.authentication;
      final credential = GoogleAuthProvider.credential(idToken: auth.idToken);
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (!mounted) return;
      widget.onSuccess?.call();
      context.go(AppRoutes.home);
    } catch (e) {
      widget.onError?.call('${AppErrors.googleSignInFailed}: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _localLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = widget.loading || _localLoading;
    return ElevatedButton.icon(
      key: AppKeys.googleLoginButton,
      icon: const Icon(Icons.login),
      label: const Text(AppLabels.loginWithGoogle),
      style: AppTheme.buttonStyle,
      onPressed: isLoading ? null : _handleGoogleSignIn,
    );
  }
}
