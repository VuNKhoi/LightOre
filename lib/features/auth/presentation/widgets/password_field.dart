import 'package:flutter/material.dart';
import 'package:lightore/constants.dart';

class PasswordField extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onClearMessages;
  const PasswordField(
      {Key? key,
      required this.value,
      required this.onChanged,
      required this.onClearMessages})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: AppKeys.passwordField,
      decoration: const InputDecoration(labelText: 'Password'),
      obscureText: true,
      onChanged: (v) {
        if (v != value) {
          onChanged(v);
          onClearMessages();
        }
      },
      validator: (v) =>
          v != null && v.length >= 6 ? null : AppErrors.minPassword,
    );
  }
}
