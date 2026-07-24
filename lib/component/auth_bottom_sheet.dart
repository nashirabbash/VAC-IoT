import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vac_dashboard_app/asset/color_tokens.dart';
import 'package:vac_dashboard_app/component/bottom_sheet_header.dart';
import 'package:vac_dashboard_app/component/button.dart';
import 'package:vac_dashboard_app/component/text.dart';
import 'package:vac_dashboard_app/screens/homeScreens.dart';
import 'package:vac_dashboard_app/screens/deviceScreens.dart';
import 'package:vac_dashboard_app/screens/scanScreens.dart';
import 'package:vac_dashboard_app/component/header.dart';
import 'package:vac_dashboard_app/services/api_service.dart';
import 'package:vac_dashboard_app/models/auth_form_data.dart';
import 'package:vac_dashboard_app/models/register_dto.dart';
import 'package:vac_dashboard_app/component/login_form.dart';
import 'package:vac_dashboard_app/component/register_form.dart';
import 'package:vac_dashboard_app/component/forgot_password_form.dart';

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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black26,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AuthBottomSheet(initialMode: initialMode),
      ),
    );
  }

  @override
  State<AuthBottomSheet> createState() => _AuthBottomSheetState();
}

class _AuthBottomSheetState extends State<AuthBottomSheet> with TickerProviderStateMixin {
  late AuthMode _mode;
  final LoginFormData _loginData = LoginFormData();
  final RegisterFormData _registerData = RegisterFormData();
  final ForgotPasswordFormData _forgotPasswordData = ForgotPasswordFormData();
  
  bool _isLoading = false;
  bool _showScanner = false;
  bool _isAnimationComplete = false;
  MobileScannerController? _scannerController;
  
  late AnimationController _laserController;
  late Animation<double> _laserAnimation;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _laserController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _loginData.dispose();
    _registerData.dispose();
    _forgotPasswordData.dispose();
    _scannerController?.dispose();
    _laserController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      if (_mode == AuthMode.login) {
        _mode = AuthMode.signUp;
      } else {
        _mode = AuthMode.login;
      }
      _showScanner = false;
    });
  }

  Future<void> _handleLogin() async {
    final nav = Navigator.of(context);
    final scaffoldMsg = ScaffoldMessenger.of(context);
    setState(() => _isLoading = true);
    try {
      await apiService.login(
        _loginData.usernameController.text,
        _loginData.passwordController.text,
      );
      if (!mounted) return;
      nav.pop(); // Dismiss bottom sheet
      nav.pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      scaffoldMsg.showSnackBar(
        SnackBar(content: AppText(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleRegisterNext() async {
    // Validation is now handled inside RegisterForm before this is called
    // Snap to scanner view
    FocusScope.of(context).unfocus(); // Dismiss the keyboard to prevent RenderFlex overflow
    setState(() {
      _showScanner = true;
      _isAnimationComplete = false;
    });
    // Wait for the 400ms transition animation to complete before mounting camera
    await Future.delayed(const Duration(milliseconds: 450));
    if (mounted && _showScanner) {
      setState(() {
        _scannerController = MobileScannerController();
        _isAnimationComplete = true;
      });
    }
  }

  Future<void> _handleQRScan(String qrKey) async {
    if (_isLoading) return;

    final scaffoldMsg = ScaffoldMessenger.of(context);
    
    if (qrKey.trim().isEmpty || !qrKey.contains('|')) {
      _scannerController?.stop();
      // DO NOT collapse the scanner view
      final snackBar = scaffoldMsg.showSnackBar(
        SnackBar(content: AppText('Invalid QR Code format')),
      );
      await snackBar.closed;
      if (mounted) {
        _scannerController?.start();
      }
      return;
    }

    setState(() => _isLoading = true);
    _scannerController?.stop();
    try {
      final dto = RegisterDto(
        username: _registerData.usernameController.text,
        password: _registerData.passwordController.text,
        hospitalName: _registerData.hospitalController.text,
        qrKey: qrKey,
      );
      await apiService.register(dto);
      
      if (!mounted) return;
      scaffoldMsg.showSnackBar(
        SnackBar(content: AppText('Registration successful!')),
      );
      final nav = Navigator.of(context);
      nav.pop(); // Dismiss bottom sheet
      
      // Navigate to HomeScreen as the base, then push DeviceScreen on top
      nav.pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
      nav.push(
        MaterialPageRoute(builder: (context) => const DeviceScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      final snackBar = scaffoldMsg.showSnackBar(
        SnackBar(content: AppText(e.toString().replaceAll('Exception: ', ''))),
      );
      await snackBar.closed;
      if (mounted) {
        setState(() {
          _isLoading = false;
          _showScanner = true;
        });
        _scannerController?.start();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final screenHeight = MediaQuery.of(context).size.height;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(34),
        topRight: Radius.circular(34),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: _showScanner ? Colors.black : colors.backgroundsPrimaryElevated,
              borderRadius: _showScanner
                  ? BorderRadius.zero
                  : const BorderRadius.only(
                      topLeft: Radius.circular(34),
                      topRight: Radius.circular(34),
                    ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: _showScanner ? screenHeight : null,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildForm(colors),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(AppColorTokenSet colors) {
    if (_showScanner) {
      return _buildScanner(colors);
    }
    switch (_mode) {
      case AuthMode.login:
        return LoginForm(
          formData: _loginData,
          isLoading: _isLoading,
          onLogin: _handleLogin,
          onToggleMode: _toggleMode,
          onClose: () => Navigator.of(context).pop(),
          onForgotPassword: () => setState(() => _mode = AuthMode.forgotPassword),
        );
      case AuthMode.signUp:
        return RegisterForm(
          formData: _registerData,
          isLoading: _isLoading,
          onNext: _handleRegisterNext,
          onToggleMode: _toggleMode,
          onClose: () => Navigator.of(context).pop(),
        );
      case AuthMode.forgotPassword:
        return ForgotPasswordForm(
          formData: _forgotPasswordData,
          isLoading: _isLoading,
          onResetPassword: () {
            // Optional: handle forgot password
            setState(() => _mode = AuthMode.login);
          },
          onBackToLogin: () => setState(() => _mode = AuthMode.login),
          onClose: () => Navigator.of(context).pop(),
        );
    }
  }

  Widget _buildScanner(AppColorTokenSet colors) {
    if (!_isAnimationComplete || _scannerController == null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(colors.accentsBlue),
          ),
        ),
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: MobileScanner(
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
        ),
        if (_isLoading)
          Container(
            color: Colors.black54,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(colors.accentsBlue),
              ),
            ),
          ),
        SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppHeader(
                  title: 'Scan QR to Bind',
                  variant: AppHeaderVariant.inline,
                  backgroundColor: Colors.transparent,
                  titleColor: Colors.white,
                  leading: IconButton(
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        _showScanner = false;
                        _isAnimationComplete = false;
                      });
                      _scannerController?.dispose();
                      _scannerController = null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: AppText(
                    'Scan the QR code on your device to complete registration.',
                    type: AppTextType.body,
                    customColor: Colors.white70,
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              painter: ViewfinderPainter(),
                              child: const SizedBox(width: 182, height: 182),
                            ),
                            if (!_isLoading)
                              AnimatedBuilder(
                                animation: _laserAnimation,
                                builder: (context, child) {
                                  return Positioned(
                                    top: 6 + (_laserAnimation.value * 170),
                                    left: 6,
                                    right: 6,
                                    child: Container(
                                      height: 3,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0088FF),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF0088FF).withValues(alpha: 0.8),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
