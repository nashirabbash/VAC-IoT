import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vac_dashboard_app/asset/color_tokens.dart';
import 'package:vac_dashboard_app/component/button.dart';
import 'package:vac_dashboard_app/component/text.dart';
import 'package:vac_dashboard_app/component/grouped_list.dart';
import 'package:vac_dashboard_app/component/bottom_sheet_header.dart';
import 'package:vac_dashboard_app/screens/homeScreens.dart';
import 'package:vac_dashboard_app/services/api_service.dart';
import 'package:vac_dashboard_app/repositories/auth_repository.dart';

enum AuthMode { login, signUp, forgotPassword }

class AuthBottomSheet extends StatefulWidget {
  final AuthMode initialMode;

  const AuthBottomSheet({super.key, this.initialMode = AuthMode.login});

  static void show(
    BuildContext context, {
    AuthMode initialMode = AuthMode.login,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Allows bottom sheet to resize when keyboard appears
      backgroundColor: Colors.transparent, // Custom rounded shape with blur
      barrierColor: Colors.black26,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // Keyboard offset
        ),
        child: AuthBottomSheet(initialMode: initialMode),
      ),
    );
  }

  @override
  State<AuthBottomSheet> createState() => _AuthBottomSheetState();
}

class _AuthBottomSheetState extends State<AuthBottomSheet> {
  late AuthMode _mode;
  final _usernameController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _hospitalController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _mode = _mode == AuthMode.login ? AuthMode.signUp : AuthMode.login;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isLogin = _mode == AuthMode.login;
    final bool isSignUp = _mode == AuthMode.signUp;
    final bool isForgotPassword = _mode == AuthMode.forgotPassword;
    final colors = context.colors;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(34),
        topRight: Radius.circular(34),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colors.backgroundsPrimaryElevated, // Solid white background
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(34),
              topRight: Radius.circular(34),
            ),
          ),
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 24,
            top: 8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Reusable Bottom Sheet Header (no title, no grabber)
              BottomSheetHeader(
                title: '',
                showGrabber: false,
                leadingIcon: isForgotPassword
                    ? Icons.arrow_back_ios_new_rounded
                    : null,
                onLeadingPressed: isForgotPassword
                    ? () => setState(() => _mode = AuthMode.login)
                    : null,
                trailingIcon: Icons.close_rounded,
                trailingVariant: ButtonVariant.tertiary,
                onTrailingPressed: () => Navigator.of(context).pop(),
              ),

              // GROUP 1: Title & Description
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(bottom: 8),
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      isForgotPassword
                          ? 'Reset Password'
                          : isLogin
                          ? 'Welcome back'
                          : 'Register',
                      type: AppTextType.title3,
                      fontWeight: FontWeight.w600,
                      customColor: colors.labelsPrimary,
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      isForgotPassword
                          ? 'Enter your username and your new password to update your credentials.'
                          : isLogin
                          ? 'Sign in to access your therapy history and manage connected devices.'
                          : 'Create an account to track your sessions and sync with devices.',
                      type: AppTextType.body,
                      customColor: colors.labelsSecondary,
                    ),
                  ],
                ),
              ),
              // Gap between Group 1 and Group 2 is 0px (no space)

              // GROUP 2: Input Forms + Checkbox (spacing 14px)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppGroupedList(
                    backgroundColor: colors
                        .backgroundsSecondaryElevated, // iOS Grouped background
                    children: [
                      // Username Field
                      TextField(
                        controller: _usernameController,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16,
                          color: colors.labelsPrimary,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Username',
                          labelStyle: TextStyle(color: colors.labelsSecondary),
                          floatingLabelStyle: TextStyle(
                            color: colors.accentsBlue,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),

                      // Hospital Field (Only for Sign Up mode)
                      if (isSignUp)
                        TextField(
                          controller: _hospitalController,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16,
                            color: colors.labelsPrimary,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Hospital',
                            labelStyle: TextStyle(
                              color: colors.labelsSecondary,
                            ),
                            floatingLabelStyle: TextStyle(
                              color: colors.accentsBlue,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),

                      // Password Field
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16,
                          color: colors.labelsPrimary,
                        ),
                        decoration: InputDecoration(
                          labelText: isForgotPassword
                              ? 'New Password'
                              : 'Password',
                          labelStyle: TextStyle(color: colors.labelsSecondary),
                          floatingLabelStyle: TextStyle(
                            color: colors.accentsBlue,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: _obscurePassword
                                  ? colors.labelsTertiary
                                  : colors.accentsBlue,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),

                      // Confirm Password Field (Only for Sign Up mode)
                      if (!isLogin)
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16,
                            color: colors.labelsPrimary,
                          ),
                          decoration: InputDecoration(
                            labelText: isForgotPassword
                                ? 'Confirm New Password'
                                : 'Confirm Password',
                            labelStyle: TextStyle(
                              color: colors.labelsSecondary,
                            ),
                            floatingLabelStyle: TextStyle(
                              color: colors.accentsBlue,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: _obscureConfirmPassword
                                    ? colors.labelsTertiary
                                    : colors.accentsBlue,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Remember Me Checkbox Row & Forgot Password Link
                  if (!isForgotPassword)
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
                                  _rememberMe = !_rememberMe;
                                });
                              },
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: _rememberMe
                                      ? colors.accentsBlue
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: _rememberMe
                                        ? colors.accentsBlue
                                        : colors.labelsTertiary,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: _rememberMe
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
                        if (isLogin)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _mode = AuthMode.forgotPassword;
                              });
                            },
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

              // Gap between Group 2 and Group 3 is 48px
              const SizedBox(height: 64),

              // GROUP 3: Button & Text
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Primary Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : AppButton(
                            label: isForgotPassword
                                ? 'Reset Password'
                                : isLogin
                                ? 'Login'
                                : 'Register',
                            size: ButtonSize.large,
                            variant: ButtonVariant.primary,
                            onPressed: () async {
                              if (isForgotPassword) {
                                setState(() {
                                  _mode = AuthMode.login;
                                  _passwordController.clear();
                                  _confirmPasswordController.clear();
                                });
                              } else if (isLogin) {
                                setState(() => _isLoading = true);
                                try {
                                  final token = await apiService.login(
                                    _usernameController.text,
                                    _passwordController.text,
                                  );
                                  final authRepo = AuthRepository();
                                  await authRepo.saveToken(token);
                                  if (!context.mounted) return;
                                  Navigator.of(
                                    context,
                                  ).pop(); // Dismiss bottom sheet
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => const HomeScreen(),
                                    ),
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        e.toString().replaceAll(
                                          'Exception: ',
                                          '',
                                        ),
                                      ),
                                    ),
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() => _isLoading = false);
                                  }
                                }
                              } else {
                                if (_passwordController.text !=
                                    _confirmPasswordController.text) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Passwords do not match'),
                                    ),
                                  );
                                  return;
                                }
                                setState(() => _isLoading = true);
                                try {
                                  await apiService.register(
                                    _usernameController.text,
                                    _passwordController.text,
                                    _hospitalController.text,
                                  );
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Registration successful. Please login.',
                                      ),
                                    ),
                                  );
                                  setState(() {
                                    _mode = AuthMode.login;
                                    _passwordController.clear();
                                    _confirmPasswordController.clear();
                                  });
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        e.toString().replaceAll(
                                          'Exception: ',
                                          '',
                                        ),
                                      ),
                                    ),
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() => _isLoading = false);
                                  }
                                }
                              }
                            },
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Mode Switcher Option
                  if (!isForgotPassword)
                    GestureDetector(
                      onTap: _toggleMode,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppText(
                            isLogin
                                ? 'Don’t have an account? '
                                : 'Already have an account? ',
                            type: AppTextType.subheadline,
                            customColor: colors.labelsSecondary,
                          ),
                          AppText(
                            isLogin ? 'Sign Up' : 'Sign In',
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
        ),
      ),
    );
  }
}
