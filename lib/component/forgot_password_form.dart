import 'package:flutter/material.dart';
import 'package:vac_dashboard_app/asset/color_tokens.dart';
import 'package:vac_dashboard_app/component/bottom_sheet_header.dart';
import 'package:vac_dashboard_app/component/button.dart';
import 'package:vac_dashboard_app/component/grouped_list.dart';
import 'package:vac_dashboard_app/component/text.dart';
import 'package:vac_dashboard_app/component/auth_input_field.dart';
import 'package:vac_dashboard_app/models/auth_form_data.dart';

class ForgotPasswordForm extends StatefulWidget {
  final ForgotPasswordFormData formData;
  final bool isLoading;
  final VoidCallback onResetPassword;
  final VoidCallback onBackToLogin;
  final VoidCallback onClose;

  const ForgotPasswordForm({
    super.key,
    required this.formData,
    required this.isLoading,
    required this.onResetPassword,
    required this.onBackToLogin,
    required this.onClose,
  });

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    return SingleChildScrollView(
      key: const ValueKey('forgot_password_form'),
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24, top: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BottomSheetHeader(
            title: '',
            showGrabber: false,
            leadingIcon: Icons.arrow_back_ios_new_rounded,
            onLeadingPressed: widget.onBackToLogin,
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
                  'Reset Password',
                  type: AppTextType.title3,
                  fontWeight: FontWeight.w600,
                  customColor: colors.labelsPrimary,
                ),
                const SizedBox(height: 4),
                AppText(
                  'Enter your username and your new password to update your credentials.',
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
                    colors: colors,
                  ),
                  AuthInputField(
                    controller: widget.formData.passwordController,
                    labelText: 'New Password',
                    isPassword: true,
                    colors: colors,
                  ),
                  AuthInputField(
                    controller: widget.formData.confirmPasswordController,
                    labelText: 'Confirm New Password',
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
                        label: 'Reset Password',
                        size: ButtonSize.large,
                        variant: ButtonVariant.primary,
                        onPressed: widget.onResetPassword,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
