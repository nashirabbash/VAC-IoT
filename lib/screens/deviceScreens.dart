import 'package:flutter/material.dart';
import 'package:vac_dashboard_app/component/text.dart';
import 'package:vac_dashboard_app/component/header.dart';
import 'package:vac_dashboard_app/component/grouped_list.dart';
import 'package:vac_dashboard_app/component/alert_dialog.dart';
import 'package:vac_dashboard_app/component/button.dart';
import 'package:vac_dashboard_app/screens/historyScreens.dart';
import 'package:vac_dashboard_app/screens/homeScreens.dart';
import 'package:vac_dashboard_app/screens/scanScreens.dart';
import 'package:vac_dashboard_app/asset/color_tokens.dart';

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({super.key});

  void _showDisconnectConfirmation(BuildContext context) {
    showAppAlertDialog(
      context,
      title: 'Disconnect Device',
      description: 'Are you sure you want to disconnect from this VAC device?',
      primaryButtonLabel: 'Disconnect',
      onPrimaryPressed: () {
        Navigator.of(context).pop(); // Close dialog

        // Show a brief disconnection simulation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Disconnecting device...'),
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
    return Scaffold(
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
                      // High quality fallback illustration representation of a VAC Device
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
                  const AppGroupedListTile(
                    title: 'Device 01',
                    detail: 'Online',
                  ),
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
                  AppGroupedListTile(
                    title: 'Device log',
                    showChevron: true,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening device logs...')),
                      );
                    },
                  ),
                  AppGroupedListTile(
                    title: 'Change Device',
                    showChevron: true,
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const ScanScreen(),
                        ),
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
    );
  }
}
