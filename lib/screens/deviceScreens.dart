import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vac_dashboard_app/asset/color_tokens.dart';
import 'package:vac_dashboard_app/component/alert_dialog.dart';
import 'package:vac_dashboard_app/component/button.dart';
import 'package:vac_dashboard_app/component/grouped_list.dart';
import 'package:vac_dashboard_app/component/header.dart';
import 'package:vac_dashboard_app/component/text.dart';
import 'package:vac_dashboard_app/screens/historyScreens.dart';
import 'package:vac_dashboard_app/screens/homeScreens.dart';
import 'package:vac_dashboard_app/screens/wifiScreens.dart';
import 'package:vac_dashboard_app/services/ble_service.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key});

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  static String _generateRandomAlias() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return 'VAC-${List.generate(6, (index) => chars[random.nextInt(chars.length)]).join()}';
  }

  static final String _randomName = _generateRandomAlias();
  StreamSubscription<bool>? _connSub;

  @override
  void initState() {
    super.initState();
    // Automatically navigate back to HomeScreen if BLE disconnects
    _connSub = bleService.onConnectionStateChanged.listen((connected) {
      if (!connected && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    _connSub?.cancel();
    super.dispose();
  }

  void _showDisconnectConfirmation(BuildContext context) {
    showAppAlertDialog(
      context,
      title: 'Disconnect Device',
      description: 'Are you sure you want to disconnect from this VAC device?',
      primaryButtonLabel: 'Disconnect',
      onPrimaryPressed: () {
        Navigator.of(context).pop(); // Close dialog

        // Trigger manual BLE disconnection
        bleService.disconnect();

        // Show a brief disconnection feedback
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: AppText('Disconnecting device...'),
            duration: Duration(seconds: 1),
          ),
        );

        Future.delayed(const Duration(milliseconds: 800), () {
          if (context.mounted) {
            // Navigate back to Home screen and clear navigation history
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            );
          }
        });
      },
      secondaryButtonLabel: 'Cancel',
      onSecondaryPressed: () => Navigator.of(context).pop(),
      buttonLayout: AppAlertDialogButtonLayout.horizontal,
      primaryButtonVariant: ButtonVariant.primaryDestructive,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent user from navigating back to HomeScreen via back gesture or button
      child: Scaffold(
        appBar: AppHeader(
          title: 'Device',
          variant: AppHeaderVariant.compactTitle3,
          titleTextAlign: TextAlign.center,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 252x252 Rounded Device Image Card (Transparent)
                Container(
                  width: 252,
                  height: 252,
                  decoration: const BoxDecoration(color: Colors.transparent),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Image.asset(
                      'lib/asset/ChatGPT_Image_9_Jul_2026__15.23.34-removebg-preview.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: context.colors.backgroundsSecondary,
                          child: Center(
                            child: Icon(
                              Icons.settings_input_hdmi_rounded,
                              size: 80,
                              color: context.colors.accentsPurple,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Detail Section Header Title
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: AppText(
                      'Detail',
                      type: AppTextType.headline,
                      color: AppTextColor.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // First Grouped List (Device info + actions)
                AppGroupedList(
                  borderRadius: 26,
                  children: [
                    AppGroupedListTile(title: _randomName, detail: 'Online'),
                  ],
                ),

                const SizedBox(height: 20),

                AppGroupedList(
                  borderRadius: 26,
                  children: [
                    AppGroupedListTile(
                      title: 'Device History',
                      showChevron: true,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const HistoryScreens(),
                          ),
                        );
                      },
                    ),
                    StreamBuilder<String>(
                      stream: bleService.onWifiStatusChanged,
                      initialData: bleService.wifiStatus,
                      builder: (context, snapshot) {
                        final status = snapshot.data ?? bleService.wifiStatus;
                        final isConnected = status.toUpperCase() == 'CONNECTED';
                        return AppGroupedListTile(
                          title: 'Connect Wifi',
                          detail: isConnected ? 'Connected' : 'Not Connected',
                          showChevron: true,
                          onTap: () {
                            WifiBottomSheet.show(context);
                          },
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Second Grouped List (Centered Red Disconnect Button)
                AppGroupedList(
                  borderRadius: 26,
                  children: [
                    AppGroupedListTile(
                      title: 'Disconnect Device',
                      isDestructive: true,
                      textAlign: TextAlign.center,
                      showChevron: false,
                      onTap: () => _showDisconnectConfirmation(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
