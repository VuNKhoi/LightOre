import 'package:flutter/material.dart';
import 'package:lightore/constants.dart';

class EmailField extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onClearMessages;
  const EmailField(
      {Key? key,
      required this.value,
      required this.onChanged,
      required this.onClearMessages})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: AppKeys.emailField,
      decoration: const InputDecoration(labelText: 'Email'),
      keyboardType: TextInputType.emailAddress,
      autofocus: true,
      onChanged: (v) {
        if (v != value) {
          onChanged(v);
          onClearMessages();
        }
      },
      validator: (v) =>
          v != null && v.contains('@') ? null : AppErrors.enterValidEmail,
    );
  }
}
