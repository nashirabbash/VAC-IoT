import 'package:flutter/material.dart';
import 'package:vac_dashboard_app/asset/color_tokens.dart';
import 'package:vac_dashboard_app/component/bottom_sheet_header.dart';
import 'package:vac_dashboard_app/component/button.dart';
import 'package:vac_dashboard_app/component/grouped_list.dart';
import 'package:vac_dashboard_app/component/text.dart';
import 'package:vac_dashboard_app/component/auth_input_field.dart';
import 'package:vac_dashboard_app/models/auth_form_data.dart';

class LoginForm extends StatefulWidget {
  final LoginFormData formData;
  final bool isLoading;
  final VoidCallback onLogin;
  final VoidCallback onToggleMode;
  final VoidCallback onClose;
  final VoidCallback onForgotPassword;

  const LoginForm({
    super.key,
    required this.formData,
    required this.isLoading,
    required this.onLogin,
    required this.onToggleMode,
    required this.onClose,
    required this.onForgotPassword,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _forceShowErrors = false;
  bool _usernameTouched = false;
  bool _passwordTouched = false;

  void _onUsernameChanged() {
    if (mounted) {
      setState(() {
        _usernameTouched = true;
        widget.formData.validateAll();
      });
    }
  }

  void _onPasswordChanged() {
    if (mounted) {
      setState(() {
        _passwordTouched = true;
        widget.formData.validateAll();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    widget.formData.usernameController.addListener(_onUsernameChanged);
    widget.formData.passwordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    widget.formData.usernameController.removeListener(_onUsernameChanged);
    widget.formData.passwordController.removeListener(_onPasswordChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    return SingleChildScrollView(
      key: const ValueKey('login_form'),
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24, top: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BottomSheetHeader(
            title: '',
            showGrabber: false,
            trailingIcon: Icons.close_rounded,
            trailingVariant: ButtonVariant.tertiary,
            onTrailingPressed: widget.onClose,
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 8),
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  'Welcome back',
                  type: AppTextType.title3,
                  fontWeight: FontWeight.w600,
                  customColor: colors.labelsPrimary,
                ),
                const SizedBox(height: 4),
                AppText(
                  'Sign in to access your therapy history and manage connected devices.',
                  type: AppTextType.body,
                  customColor: colors.labelsSecondary,
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppGroupedList(
                backgroundColor: colors.backgroundsSecondaryElevated,
                children: [
                  AuthInputField(
                    controller: widget.formData.usernameController,
                    labelText: 'Username',
                    errorText: (_usernameTouched || _forceShowErrors) ? widget.formData.usernameError : null,
                    colors: colors,
                  ),
                  AuthInputField(
                    controller: widget.formData.passwordController,
                    labelText: 'Password',
                    errorText: (_passwordTouched || _forceShowErrors) ? widget.formData.passwordError : null,
                    isPassword: true,
                    colors: colors,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            widget.formData.rememberMe = !widget.formData.rememberMe;
                          });
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: widget.formData.rememberMe
                                ? colors.accentsBlue
                                : Colors.transparent,
                            border: Border.all(
                              color: widget.formData.rememberMe
                                  ? colors.accentsBlue
                                  : colors.labelsTertiary,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: widget.formData.rememberMe
                              ? Icon(
                                  Icons.check,
                                  size: 14,
                                  color: colors.graysWhite,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      AppText(
                        'Remember me',
                        type: AppTextType.subheadline,
                        customColor: colors.labelsPrimary,
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: widget.onForgotPassword,
                    child: AppText(
                      'Forgot Password?',
                      type: AppTextType.subheadline,
                      customColor: colors.accentsBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 64),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                height: 50,
                child: widget.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : AppButton(
                        label: 'Login',
                        size: ButtonSize.large,
                        variant: ButtonVariant.primary,
                        onPressed: () {
                          setState(() {
                            _forceShowErrors = true;
                            widget.formData.validateAll();
                          });
                          if (widget.formData.isValid) {
                            widget.onLogin();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: colors.backgroundsSecondaryElevated,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                content: AppText(
                                  'Please fill in all required fields',
                                  type: AppTextType.subheadline,
                                  customColor: colors.labelsPrimary,
                                ),
                              ),
                            );
                          }
                        },
                      ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: widget.onToggleMode,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText(
                      'Don’t have an account? ',
                      type: AppTextType.subheadline,
                      customColor: colors.labelsSecondary,
                    ),
                    AppText(
                      'Sign Up',
                      type: AppTextType.subheadline,
                      customColor: colors.accentsBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
