import 'package:flutter/material.dart';

class LoginFormData {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  bool rememberMe = false;

  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
  }
}

class ForgotPasswordFormData {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }
}

class RegisterFormData {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController hospitalController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String? usernameError;
  String? hospitalError;
  String? passwordError;
  String? confirmPasswordError;

  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    hospitalController.dispose();
    confirmPasswordController.dispose();
  }

  void validateAll() {
    if (usernameController.text.isEmpty) {
      usernameError = 'Username is required';
    } else {
      usernameError = null;
    }
    
    if (hospitalController.text.isEmpty) {
      hospitalError = 'Hospital name is required';
    } else {
      hospitalError = null;
    }
    
    if (passwordController.text.length < 6) {
      passwordError = 'Password must be at least 6 characters';
    } else {
      passwordError = null;
    }
    
    if (confirmPasswordController.text != passwordController.text) {
      confirmPasswordError = 'Passwords do not match';
    } else {
      confirmPasswordError = null;
    }
  }

  bool get isValid => 
      usernameError == null && 
      hospitalError == null && 
      passwordError == null && 
      confirmPasswordError == null;
}
