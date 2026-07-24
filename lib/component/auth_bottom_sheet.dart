import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vac_dashboard_app/asset/color_tokens.dart';
import 'package:vac_dashboard_app/component/bottom_sheet_header.dart';
import 'package:vac_dashboard_app/component/button.dart';
import 'package:vac_dashboard_app/component/text.dart';
import 'package:vac_dashboard_app/screens/homeScreens.dart';
import 'package:vac_dashboard_app/services/api_service.dart';
import 'package:vac_dashboard_app/models/auth_form_data.dart';
import 'package:vac_dashboard_app/models/register_dto.dart';
import 'package:vac_dashboard_app/component/login_form.dart';
import 'package:vac_dashboard_app/component/register_form.dart';

enum AuthMode { login, signUp }

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

class _AuthBottomSheetState extends State<AuthBottomSheet> {
  late AuthMode _mode;
  final LoginFormData _loginData = LoginFormData();
  final RegisterFormData _registerData = RegisterFormData();
  
  bool _isLoading = false;
  bool _showScanner = false;
  final MobileScannerController _scannerController = MobileScannerController();

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  @override
  void dispose() {
    _loginData.dispose();
    _registerData.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _mode = _mode == AuthMode.login ? AuthMode.signUp : AuthMode.login;
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
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleRegisterNext() async {
    _registerData.validateAll();
    if (!_registerData.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the errors in the form')),
      );
      return;
    }
    // Snap to scanner view
    FocusScope.of(context).unfocus(); // Dismiss the keyboard to prevent RenderFlex overflow
    setState(() {
      _showScanner = true;
    });
    _scannerController.start();
  }

  Future<void> _handleQRScan(String qrKey) async {
    if (_isLoading) return;

    final scaffoldMsg = ScaffoldMessenger.of(context);
    
    if (qrKey.trim().isEmpty) {
      _scannerController.stop();
      setState(() => _showScanner = false);
      final snackBar = scaffoldMsg.showSnackBar(
        const SnackBar(content: Text('Invalid QR Code format')),
      );
      await snackBar.closed;
      if (mounted) {
        _scannerController.start();
        setState(() => _showScanner = true);
      }
      return;
    }

    setState(() => _isLoading = true);
    _scannerController.stop();
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
        const SnackBar(content: Text('Registration successful!')),
      );
      final nav = Navigator.of(context);
      nav.pop(); // Dismiss bottom sheet
      nav.pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      final snackBar = scaffoldMsg.showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
      await snackBar.closed;
      if (mounted) {
        setState(() {
          _isLoading = false;
          _showScanner = true;
        });
        _scannerController.start();
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
                : (_mode == AuthMode.login
                    ? LoginForm(
                        formData: _loginData,
                        isLoading: _isLoading,
                        onLogin: _handleLogin,
                        onToggleMode: _toggleMode,
                        onClose: () => Navigator.of(context).pop(),
                      )
                    : RegisterForm(
                        formData: _registerData,
                        isLoading: _isLoading,
                        onNext: _handleRegisterNext,
                        onToggleMode: _toggleMode,
                        onClose: () => Navigator.of(context).pop(),
                      )),
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
}
