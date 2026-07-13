import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vac_dashboard_app/component/button.dart';
import 'package:vac_dashboard_app/asset/color_tokens.dart';

enum AppAlertDialogButtonLayout { horizontal, vertical }

class AppAlertDialog extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? content;
  final String primaryButtonLabel;
  final VoidCallback onPrimaryPressed;
  final String? secondaryButtonLabel;
  final VoidCallback? onSecondaryPressed;
  final AppAlertDialogButtonLayout buttonLayout;
  final ButtonVariant primaryButtonVariant;

  const AppAlertDialog({
    super.key,
    required this.title,
    this.description,
    this.content,
    required this.primaryButtonLabel,
    required this.onPrimaryPressed,
    this.secondaryButtonLabel,
    this.onSecondaryPressed,
    this.buttonLayout = AppAlertDialogButtonLayout.horizontal,
    this.primaryButtonVariant = ButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: Container(
          width: 320,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(34),
            ),
            shadows: [
              BoxShadow(
                color: const Color(0x1E000000).withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.5 : 0.12),
                blurRadius: 40,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              )
            ],
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: Theme.of(context).brightness == Brightness.dark
                  ? context.colors.miscellaneousAlertOverlay
                  : const Color(0x99F5F5F5),
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title & Description Area
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: context.colors.labelsPrimary,
                            fontSize: 17,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w600,
                            height: 1.29,
                            letterSpacing: -0.43,
                          ),
                        ),
                        if (description != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            description!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: context.colors.labelsPrimary,
                              fontSize: 17,
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.w400,
                              height: 1.29,
                              letterSpacing: -0.43,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Optional Custom Content Area (e.g. List of Values)
                  if (content != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 19),
                      child: content!,
                    ),
                  ],

                  // Action Buttons Area
                  _buildButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtons() {
    final primaryBtn = AppButton(
      label: primaryButtonLabel,
      size: ButtonSize.large,
      variant: primaryButtonVariant,
      onPressed: onPrimaryPressed,
    );

    Widget? secondaryBtn;
    if (secondaryButtonLabel != null) {
      secondaryBtn = AppButton(
        label: secondaryButtonLabel,
        size: ButtonSize.large,
        variant: ButtonVariant.secondary,
        onPressed: onSecondaryPressed,
      );
    }

    if (buttonLayout == AppAlertDialogButtonLayout.horizontal && secondaryBtn != null) {
      return Row(
        children: [
          Expanded(child: secondaryBtn),
          const SizedBox(width: 16),
          Expanded(child: primaryBtn),
        ],
      );
    }

    // Vertical layout (or just primary button)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        primaryBtn,
        if (secondaryBtn != null) ...[
          const SizedBox(height: 10),
          secondaryBtn,
        ],
      ],
    );
  }
}

class AppAlertContentList extends StatelessWidget {
  final List<String> items;

  const AppAlertContentList({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: context.colors.fillsSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(items.length, (index) {
          final isFirst = index == 0;
          return Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!isFirst)
                  Container(
                    height: 1,
                    color: context.colors.separatorsVibrant,
                  ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      items[index],
                      style: TextStyle(
                        color: context.colors.labelsPrimary,
                        fontSize: 17,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w500,
                        height: 1.18,
                        letterSpacing: -0.43,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

/// Helper function to show the AppAlertDialog easily.
Future<T?> showAppAlertDialog<T>(
  BuildContext context, {
  required String title,
  String? description,
  Widget? content,
  required String primaryButtonLabel,
  required VoidCallback onPrimaryPressed,
  String? secondaryButtonLabel,
  VoidCallback? onSecondaryPressed,
  AppAlertDialogButtonLayout buttonLayout = AppAlertDialogButtonLayout.horizontal,
  ButtonVariant primaryButtonVariant = ButtonVariant.primary,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: context.colors.overlaysDefault,
    builder: (context) {
      return AppAlertDialog(
        title: title,
        description: description,
        content: content,
        primaryButtonLabel: primaryButtonLabel,
        onPrimaryPressed: onPrimaryPressed,
        secondaryButtonLabel: secondaryButtonLabel,
        onSecondaryPressed: onSecondaryPressed,
        buttonLayout: buttonLayout,
        primaryButtonVariant: primaryButtonVariant,
      );
    },
  );
}
