import 'package:flutter/material.dart';
import 'text.dart';
import 'button.dart';
import 'package:vac_dashboard_app/asset/color_tokens.dart';

enum BottomSheetHeaderVariant {
  standard, // 'default'
  title2Line, // 'title 2 line'
  title2LineLeft, // 'title 2 line left'
  largeTitle, // 'Large title'
  compactLarge, // 'compact large'
}

class BottomSheetHeader extends StatelessWidget {
  final BottomSheetHeaderVariant variant;
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final VoidCallback? onLeadingPressed;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingPressed;
  final ButtonVariant trailingVariant;
  final bool showGrabber;

  const BottomSheetHeader({
    super.key,
    this.variant = BottomSheetHeaderVariant.standard,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.onLeadingPressed,
    this.trailingIcon,
    this.onTrailingPressed,
    this.trailingVariant = ButtonVariant.primary,
    this.showGrabber = true,
  });

  Widget _buildGrabber(BuildContext context) {
    return Container(
      height: 16,
      padding: const EdgeInsets.only(top: 5),
      alignment: Alignment.topLeft,
      child: Container(
        width: 36,
        height: 5,
        decoration: ShapeDecoration(
          color: context.colors.fillsVibrantPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }

  Widget _buildAction(
    IconData? icon,
    VoidCallback? onPressed, {
    ButtonVariant variant = ButtonVariant.secondary,
  }) {
    if (icon == null) {
      // Invisible placeholder to keep center alignment balanced if needed,
      // or simply a SizedBox. We use 44x44 as the standard hit area.
      return const SizedBox(width: 44, height: 44);
    }
    return AppButton(
      icon: icon,
      size: ButtonSize.iconOnly,
      variant: variant,
      onPressed: onPressed,
    );
  }

  Widget _buildStandardVariant() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildAction(leadingIcon, onLeadingPressed),
            _buildAction(
              trailingIcon,
              onTrailingPressed,
              variant: trailingVariant,
            ),
          ],
        ),
        if (title.isNotEmpty)
          AppText(
            title,
            type: AppTextType.body,
            fontWeight: FontWeight.w600,
            color: AppTextColor.primary,
          ),
      ],
    );
  }

  Widget _buildTitle2LineVariant() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildAction(leadingIcon, onLeadingPressed),
            _buildAction(
              trailingIcon,
              onTrailingPressed,
              variant: trailingVariant,
            ),
          ],
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              title,
              type: AppTextType.subheadline,
              fontWeight: FontWeight.w600,
              color: AppTextColor.primary,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              AppText(
                subtitle!,
                type: AppTextType.caption1,
                color: AppTextColor.secondary,
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildTitle2LineLeftVariant() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingIcon != null) ...[
              _buildAction(leadingIcon, onLeadingPressed),
              const SizedBox(width: 16),
            ],
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  type: AppTextType.subheadline,
                  fontWeight: FontWeight.w600,
                  color: AppTextColor.primary,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  AppText(
                    subtitle!,
                    type: AppTextType.caption1,
                    color: AppTextColor.secondary,
                  ),
                ],
              ],
            ),
          ],
        ),
        _buildAction(trailingIcon, onTrailingPressed, variant: trailingVariant),
      ],
    );
  }

  Widget _buildLargeTitleVariant() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildAction(leadingIcon, onLeadingPressed),
            _buildAction(
              trailingIcon,
              onTrailingPressed,
              variant: trailingVariant,
            ),
          ],
        ),
        const SizedBox(height: 5),
        AppText(
          title,
          type: AppTextType.largeTitle,
          fontWeight: FontWeight.w700,
          color: AppTextColor.primary,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          AppText(
            subtitle!,
            type: AppTextType.subheadline,
            color: AppTextColor.secondary,
          ),
        ],
      ],
    );
  }

  Widget _buildCompactLargeVariant() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AppText(
            title,
            type: AppTextType.largeTitle,
            fontWeight: FontWeight.w700,
            color: AppTextColor.primary,
          ),
        ),
        _buildAction(trailingIcon, onTrailingPressed, variant: trailingVariant),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    switch (variant) {
      case BottomSheetHeaderVariant.standard:
        content = _buildStandardVariant();
        break;
      case BottomSheetHeaderVariant.title2Line:
        content = _buildTitle2LineVariant();
        break;
      case BottomSheetHeaderVariant.title2LineLeft:
        content = _buildTitle2LineLeftVariant();
        break;
      case BottomSheetHeaderVariant.largeTitle:
        content = _buildLargeTitleVariant();
        break;
      case BottomSheetHeaderVariant.compactLarge:
        content = _buildCompactLargeVariant();
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showGrabber) ...[
            _buildGrabber(context),
            const SizedBox(height: 10),
          ],
          content,
        ],
      ),
    );
  }
}
