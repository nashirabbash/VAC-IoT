import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:vac_dashboard_app/component/button.dart';
import 'package:vac_dashboard_app/component/text.dart';
import 'package:vac_dashboard_app/component/header.dart';
import 'package:vac_dashboard_app/screens/deviceScreens.dart';
import 'package:vac_dashboard_app/asset/color_tokens.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isScanning = true;
  Timer? _autoConnectTimer;

  // Animation controller for the sweeping laser line inside the viewfinder box
  late AnimationController _laserController;
  late Animation<double> _laserAnimation;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _startSimulatedScan();

    // Set up laser sweep animation
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _laserController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _cameraController = CameraController(
          _cameras.first,
          ResolutionPreset.medium,
          enableAudio: false,
        );

        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Camera initialization failed: $e');
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
        });
      }
    }
  }

  void _startSimulatedScan() {
    setState(() {
      _isScanning = true;
    });

    _autoConnectTimer?.cancel();
    // Simulate auto-detecting a device within the viewfinder area after 3 seconds
    _autoConnectTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isScanning) {
        _connectToDevice('VAC Device #3098');
      }
    });
  }

  void _toggleScan() {
    if (_isScanning) {
      _autoConnectTimer?.cancel();
      setState(() {
        _isScanning = false;
      });
    } else {
      _startSimulatedScan();
    }
  }

  void _connectToDevice(String deviceName) {
    _autoConnectTimer?.cancel();
    setState(() {
      _isScanning = false;
    });

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
                AppText(
                  'Connecting to $deviceName...',
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

    // Simulate successful connection and route to history
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop(); // Dismiss connecting dialog
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DeviceScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _autoConnectTimer?.cancel();
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
          Positioned.fill(child: _buildCameraBackground()),

          // 2. MAIN LAYOUT STRUCTURE (matching scanScreen.txt)
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

                  // EXPANDED: Center Scanner view with 182x182 viewfinder box
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
                              if (_isScanning)
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

  Widget _buildCameraBackground() {
    if (_isCameraInitialized && _cameraController != null) {
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _cameraController!.value.previewSize!.height,
          height: _cameraController!.value.previewSize!.width,
          child: CameraPreview(_cameraController!),
        ),
      );
    }

    // Modern fallback gradient when camera is unavailable
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 48,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            AppText(
              'Real Camera Preview',
              type: AppTextType.subheadline,
              fontWeight: FontWeight.w500,
              customColor: Colors.white.withValues(alpha: 0.5),
            ),
          ],
        ),
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

    // Top-Left Corner
    canvas.drawLine(Offset.zero, const Offset(cornerLength, 0), paint);
    canvas.drawLine(Offset.zero, const Offset(0, cornerLength), paint);

    // Top-Right Corner
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

    // Bottom-Left Corner
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

    // Bottom-Right Corner
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
