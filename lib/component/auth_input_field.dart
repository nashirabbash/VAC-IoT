import 'package:flutter/material.dart';
import 'package:vac_dashboard_app/asset/color_tokens.dart';

class AuthInputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? errorText;
  final bool obscureText;
  final Widget? suffixIcon;
  final AppColorTokenSet colors;

  const AuthInputField({
    super.key,
    required this.controller,
    required this.labelText,
    this.errorText,
    this.obscureText = false,
    this.suffixIcon,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 16,
        color: colors.labelsPrimary,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        errorText: errorText,
        labelStyle: TextStyle(color: colors.labelsSecondary),
        floatingLabelStyle: TextStyle(color: colors.accentsBlue),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
