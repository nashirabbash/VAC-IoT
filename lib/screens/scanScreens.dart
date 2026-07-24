import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vac_dashboard_app/component/button.dart';
import 'package:vac_dashboard_app/component/text.dart';
import 'package:vac_dashboard_app/component/header.dart';
import 'package:vac_dashboard_app/screens/deviceScreens.dart';
import 'package:vac_dashboard_app/asset/color_tokens.dart';
import 'package:vac_dashboard_app/services/api_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isScanning = true;
  bool _isProcessing = false;

  // Animation controller for the sweeping laser line inside the viewfinder box
  late AnimationController _laserController;
  late Animation<double> _laserAnimation;

  @override
  void initState() {
    super.initState();

    // Set up laser sweep animation
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _laserController, curve: Curves.easeInOut),
    );
  }

  void _toggleScan() {
    if (_isScanning) {
      _scannerController.stop();
      setState(() {
        _isScanning = false;
      });
    } else {
      _scannerController.start();
      setState(() {
        _isScanning = true;
      });
    }
  }

  Future<void> _bindDevice(String qrKey) async {
    if (_isProcessing) return;

    if (qrKey.trim().isEmpty) {
      _scannerController.stop();
      setState(() => _isScanning = false);
      final snackBar = ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid QR Code format')),
      );
      await snackBar.closed;
      if (mounted) {
        _scannerController.start();
        setState(() => _isScanning = true);
      }
      return;
    }

    setState(() {
      _isProcessing = true;
      _isScanning = false;
    });
    _scannerController.stop();

    // Show connecting loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    context.colors.accentsBlue,
                  ),
                ),
                const SizedBox(height: 16),
                const AppText(
                  'Binding Device...',
                  type: AppTextType.subheadline,
                  fontWeight: FontWeight.w600,
                  customColor: Colors.white,
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      await apiService.bindDevice(qrKey);
      if (mounted) {
        Navigator.of(context).pop(); // Dismiss connecting dialog
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DeviceScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Dismiss dialog
        final snackBar = ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
        await snackBar.closed;
        if (mounted) {
          setState(() {
            _isProcessing = false;
            _isScanning = true;
          });
          _scannerController.start();
        }
      }
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _laserController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark backing for camera preview
      body: Stack(
        children: [
          // 1. REAL CAMERA FEED OR FALLBACK
          Positioned.fill(
            child: MobileScanner(
              controller: _scannerController,
              onDetect: (BarcodeCapture capture) {
                if (!_isScanning || _isProcessing) return;
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    _bindDevice(barcode.rawValue!);
                    break;
                  }
                }
              },
            ),
          ),

          // 2. MAIN LAYOUT STRUCTURE
          SafeArea(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.all(20),
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // App Header Title
                  AppHeader(
                    title: 'Scan',
                    variant: AppHeaderVariant.inline,
                    backgroundColor: Colors.transparent,
                    titleColor: Colors.white,
                    leading: IconButton(
                      icon: const Icon(
                        Icons.chevron_left_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),

                  // Center Scanner view with 182x182 viewfinder box
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 182x182 Viewfinder Box with sweeps
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                painter: ViewfinderPainter(),
                                child: const SizedBox(width: 182, height: 182),
                              ),
                              // Laser Sweep Animation restricted to inside the box
                              if (_isScanning && !_isProcessing)
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
                                              color: const Color(
                                                0xFF0088FF,
                                              ).withValues(alpha: 0.8),
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

                  // BOTTOM CONTAINER: Anchored bottom actions with padding bottom 40
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: AppButton(
                            label: _isScanning ? 'Stop Scan' : 'Rescan',
                            size: ButtonSize.large,
                            variant: ButtonVariant.primary,
                            onPressed: _toggleScan,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ViewfinderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    const cornerLength = 24.0;

    canvas.drawLine(Offset.zero, const Offset(cornerLength, 0), paint);
    canvas.drawLine(Offset.zero, const Offset(0, cornerLength), paint);

    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width - cornerLength, 0),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, cornerLength),
      paint,
    );

    canvas.drawLine(
      Offset(0, size.height),
      Offset(cornerLength, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(0, size.height - cornerLength),
      paint,
    );

    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width - cornerLength, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
