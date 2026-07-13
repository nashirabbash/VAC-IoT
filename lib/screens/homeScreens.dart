import 'package:flutter/material.dart';
import 'package:vac_dashboard_app/component/button.dart';
import 'package:vac_dashboard_app/component/text.dart';
import 'package:vac_dashboard_app/component/header.dart';
import 'package:vac_dashboard_app/component/menu.dart';
import 'package:vac_dashboard_app/screens/welcomeScreens.dart';
import 'package:vac_dashboard_app/screens/scanScreens.dart';
import 'package:vac_dashboard_app/screens/deviceScreens.dart';
import 'package:vac_dashboard_app/screens/settingsScreen.dart';
import 'dart:convert';
import 'package:vac_dashboard_app/asset/color_tokens.dart';
import 'package:vac_dashboard_app/repositories/auth_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey _avatarKey = GlobalKey();
  bool _hasBoundDevice = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkDeviceBinding();
  }

  Future<void> _checkDeviceBinding() async {
    try {
      final token = await AuthRepository().getToken();
      if (token != null) {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = parts[1];
          final normalized = base64Url.normalize(payload);
          final decoded = utf8.decode(base64Url.decode(normalized));
          final data = jsonDecode(decoded) as Map<String, dynamic>;
          if (data['deviceId'] != null) {
            setState(() {
              _hasBoundDevice = true;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error parsing token: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAvatarMenu(BuildContext context) async {
    final RenderBox renderBox =
        _avatarKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    await showDialog(
      context: context,
      barrierColor: Colors.transparent, // Non-dimming barrier
      builder: (context) {
        return Stack(
          children: [
            // Tap detector outside the menu to dismiss it
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                behavior: HitTestBehavior.opaque,
              ),
            ),
            // Menu aligned below the avatar
            Positioned(
              top: offset.dy + size.height + 8, // Directly below the avatar
              left:
                  offset.dx -
                  238 +
                  size.width, // Right-aligned with the avatar (menu width 238)
              child: Material(
                color: Colors.transparent,
                child: AppContextMenu(
                  width: 238,
                  children: [
                    AppMenuItem(
                      label: 'Settings',
                      leadingIcon: Icons.settings_rounded,
                      onPressed: () {
                        Navigator.of(context).pop(); // Dismiss menu
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                    AppMenuItem(
                      label: 'Log out',
                      leadingIcon: Icons.logout_rounded,
                      isDestructive: true,
                      onPressed: () {
                        Navigator.of(context).pop(); // Dismiss menu
                        // Perform log out: redirect back to welcome screens
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const WelcomeScreens(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return GestureDetector(
      key: _avatarKey,
      onTap: () => _showAvatarMenu(context),
      child: Tooltip(
        message: 'Account Actions',
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(
              0xFF6750A4,
            ).withValues(alpha: 0.1), // Brand color background
            border: Border.all(color: const Color(0x1F000000), width: 1),
          ),
          child: ClipOval(
            child: Image.network(
              'https://placehold.co/42x42',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // High-quality fallback user initials
                return Center(
                  child: AppText(
                    'JD',
                    type: AppTextType.caption1,
                    fontWeight: FontWeight.w600,
                    customColor: const Color(0xFF6750A4),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: 'Home',
        variant: AppHeaderVariant.compactTitle3,
        trailing: _buildAvatar(context),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              // Pulsing Scan Wave Animation
              const PulsingScanner(size: 160),
              const SizedBox(height: 24),

              if (_isLoading)
                const CircularProgressIndicator()
              else ...[
                AppText(
                  _hasBoundDevice ? 'Device is bound' : 'Connect to device',
                  type: AppTextType.headline,
                  color: AppTextColor.secondary,
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.center,
                ),
                const Spacer(),

                // Scan Button
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: _hasBoundDevice ? 'View Device' : 'Scan',
                    size: ButtonSize.large,
                    variant: ButtonVariant.primary,
                    onPressed: () {
                      if (_hasBoundDevice) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const DeviceScreen(),
                          ),
                        );
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ScanScreen(),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A pulsing wave animation representing bluetooth/radar scanning
class PulsingScanner extends StatefulWidget {
  final double size;

  const PulsingScanner({super.key, this.size = 132});

  @override
  State<PulsingScanner> createState() => _PulsingScannerState();
}

class _PulsingScannerState extends State<PulsingScanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Wave 2
              _buildPulseRing(
                1.0 + _controller.value * 0.6,
                1.0 - _controller.value,
              ),
              // Wave 1
              _buildPulseRing(
                1.0 + ((_controller.value + 0.5) % 1.0) * 0.6,
                1.0 - ((_controller.value + 0.5) % 1.0),
              ),
              // Central Circle Anchor
              Container(
                width: widget.size * 0.5,
                height: widget.size * 0.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colors.accentsBlue, // Accents-Blue
                  boxShadow: [
                    BoxShadow(
                      color: context.colors.accentsBlue.withValues(alpha: 0.2),
                      blurRadius: 10,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.bluetooth_searching_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPulseRing(double scale, double opacity) {
    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Container(
          width: widget.size * 0.5,
          height: widget.size * 0.5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: context.colors.accentsBlue, width: 2),
          ),
        ),
      ),
    );
  }
}
