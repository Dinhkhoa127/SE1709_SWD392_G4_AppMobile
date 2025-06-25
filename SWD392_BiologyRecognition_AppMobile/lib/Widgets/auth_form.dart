import 'package:flutter/material.dart';

class AuthField {
  final String label;
  final String keyName;
  final bool isPassword;
  final TextInputType keyboardType;

  AuthField({
    required this.label,
    required this.keyName,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  });
}

class AuthForm extends StatefulWidget {
  final String title;
  final List<AuthField> fields;
  final String submitButtonText;
  final void Function(Map<String, String> values) onSubmit;
  final Widget? footer;

  const AuthForm({
    required this.title,
    required this.fields,
    required this.submitButtonText,
    required this.onSubmit,
    this.footer,
    Key? key,
  }) : super(key: key);

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _values = {};

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 24),
            ...widget.fields.map((field) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextFormField(
                obscureText: field.isPassword,
                keyboardType: field.keyboardType,
                decoration: InputDecoration(labelText: field.label, border: OutlineInputBorder()),
                validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập ${field.label}' : null,
                onSaved: (value) => _values[field.keyName] = value ?? '',
              ),
            )),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  widget.onSubmit(_values);
                }
              },
              child: Text(widget.submitButtonText),
            ),
            if (widget.footer != null) ...[
              SizedBox(height: 16),
              widget.footer!,
            ]
          ],
        ),
      ),
    );
  }
}
