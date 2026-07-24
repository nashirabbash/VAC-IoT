import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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

  bool _showScanner = false;
  String? _usernameError;
  String? _hospitalError;
  String? _passwordError;
  String? _confirmPasswordError;
  final MobileScannerController _scannerController = MobileScannerController();

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _usernameController.addListener(_validateUsername);
    _hospitalController.addListener(_validateHospital);
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validateConfirmPassword);
  }

  void _validateUsername() {
    if (_mode != AuthMode.signUp) return;
    setState(() {
      if (_usernameController.text.isEmpty) {
        _usernameError = 'Username is required';
      } else {
        _usernameError = null;
      }
    });
  }

  void _validateHospital() {
    if (_mode != AuthMode.signUp) return;
    setState(() {
      if (_hospitalController.text.isEmpty) {
        _hospitalError = 'Hospital name is required';
      } else {
        _hospitalError = null;
      }
    });
  }

  void _validatePassword() {
    if (_mode != AuthMode.signUp) return;
    setState(() {
      if (_passwordController.text.length < 6) {
        _passwordError = 'Password must be at least 6 characters';
      } else {
        _passwordError = null;
      }
    });
    _validateConfirmPassword();
  }

  void _validateConfirmPassword() {
    if (_mode != AuthMode.signUp) return;
    setState(() {
      if (_confirmPasswordController.text != _passwordController.text) {
        _confirmPasswordError = 'Passwords do not match';
      } else {
        _confirmPasswordError = null;
      }
    });
  }

  bool _validateAll() {
    _validateUsername();
    _validateHospital();
    _validatePassword();
    _validateConfirmPassword();
    return _usernameError == null &&
        _hospitalError == null &&
        _passwordError == null &&
        _confirmPasswordError == null;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _hospitalController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _mode = _mode == AuthMode.login ? AuthMode.signUp : AuthMode.login;
      _showScanner = false;
    });
  }

  void _handleForgotPassword() {
    setState(() {
      _mode = AuthMode.login;
      _passwordController.clear();
      _confirmPasswordController.clear();
      _showScanner = false;
    });
  }

  Future<void> _handleLogin() async {
    final nav = Navigator.of(context);
    final scaffoldMsg = ScaffoldMessenger.of(context);
    setState(() => _isLoading = true);
    try {
      final token = await apiService.login(
        _usernameController.text,
        _passwordController.text,
      );
      final authRepo = AuthRepository();
      await authRepo.saveToken(token);
      if (!mounted) return;
      nav.pop(); // Dismiss bottom sheet
      nav.pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      scaffoldMsg.showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleRegisterNext() async {
    if (!_validateAll()) {
      // Show error fields and don't proceed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the errors in the form')),
      );
      return;
    }
    // Snap to scanner view
    setState(() {
      _showScanner = true;
    });
    _scannerController.start();
  }

  Future<void> _handleQRScan(String qrKey) async {
    final scaffoldMsg = ScaffoldMessenger.of(context);
    setState(() => _isLoading = true);
    _scannerController.stop();
    try {
      await apiService.register(
        _usernameController.text,
        _passwordController.text,
        _hospitalController.text,
        qrKey,
      );
      if (!mounted) return;
      scaffoldMsg.showSnackBar(
        const SnackBar(content: Text('Registration successful!')),
      );
      final nav = Navigator.of(context);
      nav.pop(); // Dismiss bottom sheet
      nav.pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      scaffoldMsg.showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
      setState(() => _isLoading = false);
      _scannerController.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLogin = _mode == AuthMode.login;
    final bool isSignUp = _mode == AuthMode.signUp;
    final bool isForgotPassword = _mode == AuthMode.forgotPassword;
    final colors = context.colors;
    final screenHeight = MediaQuery.of(context).size.height;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(34),
        topRight: Radius.circular(34),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          height: _showScanner ? screenHeight : null,
          width: double.infinity,
          decoration: BoxDecoration(
            color: colors.backgroundsPrimaryElevated,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(34),
              topRight: Radius.circular(34),
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _showScanner
                ? _buildScanner(colors)
                : _buildForm(colors, isLogin, isSignUp, isForgotPassword),
          ),
        ),
      ),
    );
  }

  Widget _buildScanner(AppColorTokenSet colors) {
    return SafeArea(
      child: Column(
        key: const ValueKey('scanner'),
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 8),
            child: BottomSheetHeader(
              title: 'Scan QR to Bind',
              showGrabber: false,
              leadingIcon: Icons.arrow_back_ios_new_rounded,
              onLeadingPressed: () {
                setState(() {
                  _showScanner = false;
                });
                _scannerController.stop();
              },
              trailingIcon: Icons.close_rounded,
              trailingVariant: ButtonVariant.tertiary,
              onTrailingPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AppText(
              'Scan the QR code on your device to complete registration.',
              type: AppTextType.body,
              customColor: colors.labelsSecondary,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Stack(
              children: [
                MobileScanner(
                  controller: _scannerController,
                  onDetect: (BarcodeCapture capture) {
                    if (_isLoading) return;
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      if (barcode.rawValue != null) {
                        _handleQRScan(barcode.rawValue!);
                        break;
                      }
                    }
                  },
                ),
                if (_isLoading)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colors.accentsBlue,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(
      AppColorTokenSet colors, bool isLogin, bool isSignUp, bool isForgotPassword) {
    return SingleChildScrollView(
      key: const ValueKey('form'),
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24, top: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BottomSheetHeader(
            title: '',
            showGrabber: false,
            leadingIcon:
                isForgotPassword ? Icons.arrow_back_ios_new_rounded : null,
            onLeadingPressed: isForgotPassword
                ? () => setState(() => _mode = AuthMode.login)
                : null,
            trailingIcon: Icons.close_rounded,
            trailingVariant: ButtonVariant.tertiary,
            onTrailingPressed: () => Navigator.of(context).pop(),
          ),
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
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppGroupedList(
                backgroundColor: colors.backgroundsSecondaryElevated,
                children: [
                  TextField(
                    controller: _usernameController,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      color: colors.labelsPrimary,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Username',
                      errorText: isSignUp ? _usernameError : null,
                      labelStyle: TextStyle(color: colors.labelsSecondary),
                      floatingLabelStyle: TextStyle(color: colors.accentsBlue),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
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
                        errorText: _hospitalError,
                        labelStyle: TextStyle(color: colors.labelsSecondary),
                        floatingLabelStyle:
                            TextStyle(color: colors.accentsBlue),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      color: colors.labelsPrimary,
                    ),
                    decoration: InputDecoration(
                      labelText:
                          isForgotPassword ? 'New Password' : 'Password',
                      errorText: isSignUp ? _passwordError : null,
                      labelStyle: TextStyle(color: colors.labelsSecondary),
                      floatingLabelStyle: TextStyle(color: colors.accentsBlue),
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
                        errorText: isSignUp ? _confirmPasswordError : null,
                        labelStyle: TextStyle(color: colors.labelsSecondary),
                        floatingLabelStyle:
                            TextStyle(color: colors.accentsBlue),
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
          const SizedBox(height: 64),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                                : 'Next',
                        size: ButtonSize.large,
                        variant: ButtonVariant.primary,
                        onPressed: () async {
                          if (isForgotPassword) {
                            _handleForgotPassword();
                          } else if (isLogin) {
                            await _handleLogin();
                          } else {
                            await _handleRegisterNext();
                          }
                        },
                      ),
              ),
              const SizedBox(height: 16),
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
    );
  }
}
