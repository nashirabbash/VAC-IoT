import 'package:flutter/material.dart';
import 'package:vac_dashboard_app/component/text.dart';
import 'package:vac_dashboard_app/asset/color_tokens.dart';

enum ButtonSize { small, medium, large, iconOnly }
enum ButtonVariant { primary, secondary, tertiary, destructive, primaryDestructive, ghost, elevated }

class AppButton extends StatelessWidget {
  final String? label;
  final IconData? icon; // Digunakan sebagai leading icon atau icon utama jika iconOnly
  final IconData? trailingIcon;
  final ButtonSize size;
  final ButtonVariant variant;
  final VoidCallback? onPressed;
  final double? customIconSize;
  final bool isGhost;

  const AppButton({
    super.key,
    this.label,
    this.icon,
    this.trailingIcon,
    this.size = ButtonSize.medium,
    this.variant = ButtonVariant.tertiary,
    this.onPressed,
    this.customIconSize,
    this.isGhost = false,
  });

  double get _height {
    switch (size) {
      case ButtonSize.large:
        return 50.0;
      case ButtonSize.iconOnly:
        return 44.0;
      case ButtonSize.medium:
        return 34.0;
      case ButtonSize.small:
        return 28.0;
    }
  }

  double get _defaultIconSize {
    switch (size) {
      case ButtonSize.large:
        return 22.0;
      case ButtonSize.iconOnly:
        return 20.0;
      case ButtonSize.medium:
        return 16.0;
      case ButtonSize.small:
        return 14.0;
    }
  }

  AppTextType get _textType {
    switch (size) {
      case ButtonSize.large:
        return AppTextType.callout; // 16px
      case ButtonSize.medium:
        return AppTextType.subheadline; // 15px
      case ButtonSize.small:
      case ButtonSize.iconOnly: // tidak digunakan jika iconOnly
        return AppTextType.caption1; // 12px
    }
  }

  double get _paddingHorizontal {
    switch (size) {
      case ButtonSize.large:
        return 24.0;
      case ButtonSize.iconOnly:
        return 0.0;
      case ButtonSize.medium:
        return 16.0;
      case ButtonSize.small:
        return 12.0;
    }
  }

  Color _backgroundColor(BuildContext context) {
    if (isGhost || variant == ButtonVariant.ghost) {
      return Colors.transparent;
    }
    switch (variant) {
      case ButtonVariant.primary:
        return context.colors.accentsBlue; // Accents-Blue
      case ButtonVariant.secondary:
        return context.colors.fillsSecondary; // Fills-Secondary
      case ButtonVariant.tertiary:
        return context.colors.fillsTertiary; // Fills-Tertiary
      case ButtonVariant.destructive:
        return context.colors.miscellaneousButtonsBGDestructive; // Destructive Background
      case ButtonVariant.primaryDestructive:
        return context.colors.accentsRed; // Accents-Red background
      case ButtonVariant.ghost:
        return Colors.transparent;
      case ButtonVariant.elevated:
        return context.colors.backgroundsPrimary;
    }
  }

  Color _foregroundColor(BuildContext context) {
    final effectiveVariant = variant == ButtonVariant.ghost ? ButtonVariant.tertiary : variant;
    final effectiveIsGhost = isGhost || variant == ButtonVariant.ghost;

    switch (effectiveVariant) {
      case ButtonVariant.primary:
        return effectiveIsGhost ? context.colors.accentsBlue : context.colors.graysWhite;
      case ButtonVariant.secondary:
        return context.colors.labelsPrimary;
      case ButtonVariant.tertiary:
        return context.colors.labelsTertiary; // Labels-Tertiary
      case ButtonVariant.destructive:
        return context.colors.accentsRed; // Accents-Red
      case ButtonVariant.primaryDestructive:
        return effectiveIsGhost ? context.colors.accentsRed : context.colors.graysWhite;
      case ButtonVariant.elevated:
        return context.colors.labelsPrimary;
      case ButtonVariant.ghost:
        return context.colors.labelsTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Memaksa jadi icon button bulat jika size == iconOnly
    // atau jika label & trailingIcon kosong.
    final bool isIconButtonOnly = size == ButtonSize.iconOnly || (label == null && trailingIcon == null && icon != null);
    final Color bgColor = _backgroundColor(context);
    final Color fgColor = _foregroundColor(context);

    final buttonContent = Material(
      color: bgColor,
      shape: isIconButtonOnly 
          ? const CircleBorder() 
          : RoundedRectangleBorder(borderRadius: BorderRadius.circular(500)), // Bentuk Pill
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        splashColor: fgColor.withValues(alpha: 0.2),
        highlightColor: fgColor.withValues(alpha: 0.1),
        child: Container(
          height: _height,
          width: isIconButtonOnly ? _height : null,
          padding: EdgeInsets.symmetric(horizontal: isIconButtonOnly ? 0 : _paddingHorizontal),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                Icon(
                  icon,
                  size: customIconSize ?? _defaultIconSize,
                  color: fgColor,
                ),
              if (icon != null && label != null) 
                const SizedBox(width: 8),
              if (label != null)
                Flexible(
                  child: AppText(
                    label!,
                    type: _textType,
                    customColor: fgColor,
                    fontWeight: FontWeight.w600,
                    customLetterSpacing: 0.10,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (trailingIcon != null && label != null) 
                const SizedBox(width: 8),
              if (trailingIcon != null)
                Icon(
                  trailingIcon,
                  size: customIconSize ?? _defaultIconSize,
                  color: fgColor,
                ),
            ],
          ),
        ),
      ),
    );

    if (variant == ButtonVariant.elevated) {
      return Container(
        decoration: BoxDecoration(
          shape: isIconButtonOnly ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isIconButtonOnly ? null : BorderRadius.circular(500),
          boxShadow: [
            BoxShadow(
              color: const Color(0x1E000000).withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.4 : 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: buttonContent,
      );
    }

    return buttonContent;
  }
}
