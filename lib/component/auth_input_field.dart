import 'package:flutter/material.dart';
import 'package:vac_dashboard_app/asset/color_tokens.dart';

class AuthInputField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? errorText;
  final bool isPassword;
  final AppColorTokenSet colors;

  const AuthInputField({
    super.key,
    required this.controller,
    required this.labelText,
    this.errorText,
    this.isPassword = false,
    required this.colors,
  });

  @override
  State<AuthInputField> createState() => _AuthInputFieldState();
}

class _AuthInputFieldState extends State<AuthInputField> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscureText,
      style: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 16,
        color: widget.colors.labelsPrimary,
      ),
      decoration: InputDecoration(
        labelText: widget.labelText,
        errorText: widget.errorText,
        labelStyle: TextStyle(color: widget.colors.labelsSecondary),
        floatingLabelStyle: TextStyle(color: widget.colors.accentsBlue),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: _obscureText ? widget.colors.labelsTertiary : widget.colors.accentsBlue,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
      ),
    );
  }
}
