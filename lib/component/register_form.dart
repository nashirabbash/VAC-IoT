import 'package:flutter/material.dart';
import 'package:vac_dashboard_app/asset/color_tokens.dart';
import 'package:vac_dashboard_app/component/bottom_sheet_header.dart';
import 'package:vac_dashboard_app/component/button.dart';
import 'package:vac_dashboard_app/component/grouped_list.dart';
import 'package:vac_dashboard_app/component/text.dart';
import 'package:vac_dashboard_app/component/auth_input_field.dart';
import 'package:vac_dashboard_app/models/auth_form_data.dart';

class RegisterForm extends StatefulWidget {
  final RegisterFormData formData;
  final bool isLoading;
  final VoidCallback onNext;
  final VoidCallback onToggleMode;
  final VoidCallback onClose;

  const RegisterForm({
    super.key,
    required this.formData,
    required this.isLoading,
    required this.onNext,
    required this.onToggleMode,
    required this.onClose,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  bool _forceShowErrors = false;
  bool _nameTouched = false;
  bool _usernameTouched = false;
  bool _hospitalTouched = false;
  bool _passwordTouched = false;
  bool _confirmPasswordTouched = false;

  @override
  void initState() {
    super.initState();
    widget.formData.nameController.addListener(() {
      if (mounted) {
        setState(() {
          _nameTouched = true;
          widget.formData.validateAll();
        });
      }
    });
    widget.formData.usernameController.addListener(() {
      if (mounted) {
        setState(() {
          _usernameTouched = true;
          widget.formData.validateAll();
        });
      }
    });
    widget.formData.hospitalController.addListener(() {
      if (mounted) {
        setState(() {
          _hospitalTouched = true;
          widget.formData.validateAll();
        });
      }
    });
    widget.formData.passwordController.addListener(() {
      if (mounted) {
        setState(() {
          _passwordTouched = true;
          widget.formData.validateAll();
        });
      }
    });
    widget.formData.confirmPasswordController.addListener(() {
      if (mounted) {
        setState(() {
          _confirmPasswordTouched = true;
          widget.formData.validateAll();
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    return SingleChildScrollView(
      key: const ValueKey('register_form'),
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
                  'Register',
                  type: AppTextType.title3,
                  fontWeight: FontWeight.w600,
                  customColor: colors.labelsPrimary,
                ),
                const SizedBox(height: 4),
                AppText(
                  'Create an account to track your sessions and sync with devices.',
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
                    controller: widget.formData.nameController,
                    labelText: 'Full Name',
                    errorText: (_nameTouched || _forceShowErrors) ? widget.formData.nameError : null,
                    colors: colors,
                  ),
                  AuthInputField(
                    controller: widget.formData.usernameController,
                    labelText: 'Username',
                    errorText: (_usernameTouched || _forceShowErrors) ? widget.formData.usernameError : null,
                    colors: colors,
                  ),
                  AuthInputField(
                    controller: widget.formData.hospitalController,
                    labelText: 'Hospital',
                    errorText: (_hospitalTouched || _forceShowErrors) ? widget.formData.hospitalError : null,
                    colors: colors,
                  ),
                  AuthInputField(
                    controller: widget.formData.passwordController,
                    labelText: 'Password',
                    errorText: (_passwordTouched || _forceShowErrors) ? widget.formData.passwordError : null,
                    isPassword: true,
                    colors: colors,
                  ),
                  AuthInputField(
                    controller: widget.formData.confirmPasswordController,
                    labelText: 'Confirm Password',
                    errorText: (_confirmPasswordTouched || _forceShowErrors) ? widget.formData.confirmPasswordError : null,
                    isPassword: true,
                    colors: colors,
                  ),
                ],
              ),
              const SizedBox(height: 14),
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
                        label: 'Next',
                        size: ButtonSize.large,
                        variant: ButtonVariant.primary,
                        onPressed: () {
                          setState(() {
                            _forceShowErrors = true;
                            widget.formData.validateAll();
                          });
                          if (widget.formData.isValid) {
                            widget.onNext();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: AppText('Please fix the errors in the form')),
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
                      'Already have an account? ',
                      type: AppTextType.subheadline,
                      customColor: colors.labelsSecondary,
                    ),
                    AppText(
                      'Sign In',
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
