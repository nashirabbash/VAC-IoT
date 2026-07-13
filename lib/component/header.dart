import 'package:flutter/material.dart';
import 'package:vac_dashboard_app/component/text.dart';
import 'package:vac_dashboard_app/asset/color_tokens.dart';

enum AppHeaderVariant {
  compactLarge, // Judul besar sebaris dengan trailing (contoh: History Header)
  large, // Leading/Trailing di atas, Judul besar di bawah
  inline, // Judul kecil di tengah sebaris dengan leading/trailing
  compactTitle3, // Judul sedang (20px) sebaris dengan trailing (contoh: Home Header)
}

/// Reusable Header Component
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final AppHeaderVariant variant;
  final Color? backgroundColor;
  final Color? titleColor;
  final TextAlign? titleTextAlign;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.variant = AppHeaderVariant.compactLarge,
    this.backgroundColor,
    this.titleColor,
    this.titleTextAlign,
  });

  @override
  Size get preferredSize {
    switch (variant) {
      case AppHeaderVariant.compactLarge:
        return Size.fromHeight(subtitle != null ? 85.0 : 70.0);
      case AppHeaderVariant.large:
        return Size.fromHeight(subtitle != null ? 135.0 : 115.0);
      case AppHeaderVariant.inline:
        return const Size.fromHeight(60.0);
      case AppHeaderVariant.compactTitle3:
        return const Size.fromHeight(58.0);
    }
  }

  Widget _buildCompactLarge() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10, top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppText(title, type: AppTextType.largeTitle),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  AppText(
                    subtitle!,
                    type: AppTextType.subheadline,
                    color: AppTextColor.secondary,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 10), trailing!],
        ],
      ),
    );
  }

  Widget _buildLarge() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10, top: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (leading != null) leading! else const SizedBox(height: 44),
              if (trailing != null) trailing as Widget,
            ],
          ),
          const SizedBox(height: 10),
          AppText(title, type: AppTextType.largeTitle),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            AppText(
              subtitle!,
              type: AppTextType.subheadline,
              color: AppTextColor.secondary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInline() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10, top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) leading! else const SizedBox(width: 44),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  title,
                  type: AppTextType.subheadline,
                  fontWeight: FontWeight.w600,
                  customColor: titleColor,
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
          ),
          if (trailing != null) trailing! else const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildCompactTitle3(BuildContext context) {
    final bool isCentered = titleTextAlign == TextAlign.center;
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10, top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null)
            leading!
          else if (isCentered)
            const SizedBox(width: 48),
          Expanded(
            child: AppText(
              title,
              type: AppTextType.title3,
              fontWeight: FontWeight.w600,
              textAlign: titleTextAlign ?? TextAlign.start,
              customColor: titleColor ?? context.colors.labelsPrimary,
            ),
          ),
          if (trailing != null) ...[
            if (!isCentered) const SizedBox(width: 10),
            trailing!,
          ] else if (isCentered)
            const SizedBox(width: 48),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: preferredSize.height,
        color: backgroundColor,
        child: () {
          switch (variant) {
            case AppHeaderVariant.compactLarge:
              return _buildCompactLarge();
            case AppHeaderVariant.large:
              return _buildLarge();
            case AppHeaderVariant.inline:
              return _buildInline();
            case AppHeaderVariant.compactTitle3:
              return _buildCompactTitle3(context);
          }
        }(),
      ),
    );
  }
}

/// Grup Action Button (misal 2 atau 3 tombol di dalam satu wadah pill)
class AppHeaderActionGroup extends StatelessWidget {
  final List<Widget> children;

  const AppHeaderActionGroup({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: ShapeDecoration(
        color: context.colors.backgroundsGroupedSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(296)),
        shadows: [
          BoxShadow(
            color: const Color(0x1E000000).withValues(
              alpha: Theme.of(context).brightness == Brightness.dark
                  ? 0.4
                  : 0.12,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}
