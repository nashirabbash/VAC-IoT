import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vac_dashboard_app/asset/color_tokens.dart';
import 'package:vac_dashboard_app/component/alert_dialog.dart';
import 'package:vac_dashboard_app/component/auth_input_field.dart';
import 'package:vac_dashboard_app/component/bottom_sheet_header.dart';
import 'package:vac_dashboard_app/component/button.dart';
import 'package:vac_dashboard_app/component/grouped_list.dart';
import 'package:vac_dashboard_app/component/text.dart';
import 'package:vac_dashboard_app/services/ble_service.dart';

enum WifiConnectionState { notConnected, connecting, connected, failed }

class WifiBottomSheet extends StatefulWidget {
  const WifiBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black26,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const WifiBottomSheet(),
      ),
    );
  }

  @override
  State<WifiBottomSheet> createState() => _WifiBottomSheetState();
}

class _WifiBottomSheetState extends State<WifiBottomSheet> {
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  late WifiConnectionState _state;
  StreamSubscription<String>? _wifiSub;
  Timer? _connectTimeoutTimer;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (bleService.wifiStatus.toUpperCase() == 'CONNECTED') {
      _state = WifiConnectionState.connected;
    } else {
      _state = WifiConnectionState.notConnected;
    }

    _fetchInitialWifiStatus();

    _wifiSub = bleService.onWifiStatusChanged.listen((status) {
      if (!mounted) return;
      final upper = status.toUpperCase();
      setState(() {
        if (upper == 'CONNECTED') {
          _connectTimeoutTimer?.cancel();
          _state = WifiConnectionState.connected;
          _errorMessage = null;
        } else if (upper == 'CONNECTING') {
          _state = WifiConnectionState.connecting;
        } else if (upper == 'FAILED') {
          _connectTimeoutTimer?.cancel();
          _state = WifiConnectionState.failed;
          _errorMessage = 'Failed to connect to Wi-Fi. Please check credentials.';
        } else if (upper == 'DISCONNECTED') {
          _connectTimeoutTimer?.cancel();
          _state = WifiConnectionState.notConnected;
        }
      });
    });
  }

  Future<void> _fetchInitialWifiStatus() async {
    final status = await bleService.readWifiStatus();
    if (!mounted) return;
    final upper = status.toUpperCase();
    setState(() {
      if (upper == 'CONNECTED') {
        _state = WifiConnectionState.connected;
      } else if (upper == 'CONNECTING') {
        _state = WifiConnectionState.connecting;
      } else if (upper == 'FAILED') {
        _state = WifiConnectionState.failed;
      } else if (upper == 'DISCONNECTED') {
        _state = WifiConnectionState.notConnected;
      }
    });
  }

  @override
  void dispose() {
    _connectTimeoutTimer?.cancel();
    _wifiSub?.cancel();
    _ssidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleConnect() async {
    final ssid = _ssidController.text.trim();
    final password = _passwordController.text;

    if (ssid.isEmpty) {
      setState(() {
        _errorMessage = 'Wi-Fi SSID cannot be empty.';
      });
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _state = WifiConnectionState.connecting;
      _errorMessage = null;
    });

    _connectTimeoutTimer?.cancel();

    final success = await bleService.sendWifiConfig(ssid, password);
    if (!success && mounted) {
      setState(() {
        _state = WifiConnectionState.failed;
        _errorMessage = 'Could not send Wi-Fi settings over BLE. Ensure device is nearby.';
      });
      return;
    }

    // Safety fallback timeout: if no wifi_status event received within 30s
    _connectTimeoutTimer = Timer(const Duration(seconds: 30), () {
      if (mounted && _state == WifiConnectionState.connecting) {
        setState(() {
          _state = WifiConnectionState.failed;
          _errorMessage = 'Connection timeout. Check Wi-Fi range or password.';
        });
      }
    });
  }

  void _showDisconnectConfirmation() {
    showAppAlertDialog(
      context,
      title: 'Disconnect Wi-Fi',
      description: 'Are you sure you want to disconnect the device from this Wi-Fi network?',
      primaryButtonLabel: 'Disconnect',
      primaryButtonVariant: ButtonVariant.primaryDestructive,
      onPrimaryPressed: () async {
        Navigator.of(context).pop(); // Close dialog
        await bleService.disconnectWifi();
        if (mounted) {
          setState(() {
            _state = WifiConnectionState.notConnected;
            _ssidController.clear();
            _passwordController.clear();
          });
        }
      },
      secondaryButtonLabel: 'Cancel',
      onSecondaryPressed: () => Navigator.of(context).pop(),
      buttonLayout: AppAlertDialogButtonLayout.horizontal,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(34),
        topRight: Radius.circular(34),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: colors.backgroundsPrimaryElevated,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(34),
              topRight: Radius.circular(34),
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: _state == WifiConnectionState.connected
                ? _buildConnectedContent(colors)
                : _buildFormContent(colors),
          ),
        ),
      ),
    );
  }

  // Content for Connected state: NO HEADER, icon + catchy text + bottom disconnect button
  Widget _buildConnectedContent(AppColorTokenSet colors) {
    final connectedSsid = bleService.connectedSsid ?? 'Wi-Fi Network';

    return SingleChildScrollView(
      key: const ValueKey('wifi_connected_content'),
      padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Drag grabber line
          Container(
            width: 36,
            height: 5,
            decoration: BoxDecoration(
              color: colors.labelsSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          const SizedBox(height: 36),

          // Eye-catching Connected Icon
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.accentsGreen.withValues(alpha: 0.12),
            ),
            child: Center(
              child: Icon(
                Icons.wifi_rounded,
                size: 54,
                color: colors.accentsGreen,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Eye-catching Status Text
          AppText(
            'Device Connected',
            type: AppTextType.title2,
            fontWeight: FontWeight.w700,
            customColor: colors.labelsPrimary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppText(
              'Your VAC device is online and synchronized via $connectedSsid.',
              type: AppTextType.body,
              customColor: colors.labelsSecondary,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 56),

          // Red Disconnect Button at the bottom
          SizedBox(
            width: double.infinity,
            height: 50,
            child: AppButton(
              label: 'Disconnect Wifi',
              size: ButtonSize.large,
              variant: ButtonVariant.primaryDestructive,
              onPressed: _showDisconnectConfirmation,
            ),
          ),
        ],
      ),
    );
  }

  // Content for Not Connected / Form state
  Widget _buildFormContent(AppColorTokenSet colors) {
    final bool isLoading = _state == WifiConnectionState.connecting;

    return SingleChildScrollView(
      key: const ValueKey('wifi_form_content'),
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 28, top: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BottomSheetHeader(
            title: 'Connect Wi-Fi',
            showGrabber: true,
            trailingIcon: Icons.close_rounded,
            trailingVariant: ButtonVariant.tertiary,
            onTrailingPressed: () => Navigator.of(context).pop(),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 12),
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  'Wi-Fi Setup',
                  type: AppTextType.title3,
                  fontWeight: FontWeight.w600,
                  customColor: colors.labelsPrimary,
                ),
                const SizedBox(height: 4),
                AppText(
                  'Enter network credentials to link your VAC device to local Wi-Fi.',
                  type: AppTextType.body,
                  customColor: colors.labelsSecondary,
                ),
              ],
            ),
          ),
          if (_errorMessage != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: colors.accentsRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: AppText(
                _errorMessage!,
                type: AppTextType.subheadline,
                customColor: colors.accentsRed,
              ),
            ),
          ],
          AppGroupedList(
            backgroundColor: colors.backgroundsSecondaryElevated,
            children: [
              AuthInputField(
                controller: _ssidController,
                labelText: 'Wi-Fi Name (SSID)',
                colors: colors,
              ),
              AuthInputField(
                controller: _passwordController,
                labelText: 'Password',
                isPassword: true,
                colors: colors,
              ),
            ],
          ),
          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(colors.accentsBlue),
                    ),
                  )
                : AppButton(
                    label: 'Connect Wi-Fi',
                    size: ButtonSize.large,
                    variant: ButtonVariant.primary,
                    onPressed: _handleConnect,
                  ),
          ),
        ],
      ),
    );
  }
}
