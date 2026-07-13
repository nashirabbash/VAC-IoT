import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vac_dashboard_app/component/text.dart';
import 'package:vac_dashboard_app/asset/color_tokens.dart';

/// Komponen utama pembungkus Context Menu
class AppContextMenu extends StatelessWidget {
  final List<Widget> children;
  final double width;

  const AppContextMenu({super.key, required this.children, this.width = 238.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1E000000).withValues(
              alpha: Theme.of(context).brightness == Brightness.dark
                  ? 0.4
                  : 0.12,
            ),
            blurRadius: 40,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: Theme.of(context).brightness == Brightness.dark
              ? context.colors.miscellaneousAlertOverlay
              : const Color(0x99F5F5F5),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }
}

/// Baris horizontal untuk Quick Actions (contoh: Copy, Share)
class AppMenuActionRow extends StatelessWidget {
  final List<AppMenuHorizontalItem> items;

  const AppMenuActionRow({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: items.map((item) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3), // Spacing
              child: item,
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Item aksi horizontal (tombol kotak kecil)
class AppMenuHorizontalItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDestructive;
  final VoidCallback? onPressed;

  const AppMenuHorizontalItem({
    super.key,
    required this.icon,
    required this.label,
    this.isDestructive = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? context.colors.accentsRed
        : context.colors.labelsPrimary;

    return Material(
      color: Colors.transparent, // Background default transparan
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        highlightColor:
            context.colors.fillsVibrantTertiary, // Warna saat ditekan/hover
        splashColor: context.colors.fillsVibrantTertiary.withValues(alpha: 0.5),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 4),
              AppText(
                label,
                type: AppTextType.caption1, // 12px
                customColor: color,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Garis pemisah antar section di menu
class AppMenuSeparator extends StatelessWidget {
  const AppMenuSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 21,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Center(
        child: Container(
          width: double.infinity,
          height: 1,
          color: context.colors.separatorsVibrant, // Separators-Vibrant
        ),
      ),
    );
  }
}

/// Judul kecil untuk section
class AppMenuSectionTitle extends StatelessWidget {
  final String title;

  const AppMenuSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 8),
      child: AppText(
        title,
        type: AppTextType.footnote, // 13px
        color: AppTextColor.tertiary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// Item list standar ke bawah
class AppMenuItem extends StatelessWidget {
  final String label;
  final IconData? leadingIcon;
  final String? trailingText;
  final bool hasSubmenu;
  final bool isDestructive;
  final bool isDisabled;
  final VoidCallback? onPressed;

  const AppMenuItem({
    super.key,
    required this.label,
    this.leadingIcon,
    this.trailingText,
    this.hasSubmenu = false,
    this.isDestructive = false,
    this.isDisabled = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Penentuan warna berdasarkan state
    Color primaryColor = context.colors.labelsPrimary;
    Color secondaryColor =
        context.colors.labelsSecondary; // Trailing text / Icon

    if (isDisabled) {
      primaryColor = context.colors.labelsVibrantTertiary;
      secondaryColor = context.colors.labelsVibrantQuaternary;
    } else if (isDestructive) {
      primaryColor = context.colors.accentsRed;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        highlightColor: context.colors.fillsVibrantTertiary.withValues(
          alpha: 0.5,
        ),
        splashColor: context.colors.fillsVibrantTertiary.withValues(alpha: 0.5),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 14,
            right: 16,
            top: 10,
            bottom: 10,
          ),
          child: Row(
            children: [
              // Area Leading Icon (dengan ukuran tetap agar teks selalu rata kiri)
              if (leadingIcon != null) ...[
                SizedBox(
                  width: 28,
                  child: Icon(leadingIcon, size: 20, color: primaryColor),
                ),
                const SizedBox(width: 8),
              ],

              // Area Label
              Expanded(
                child: AppText(
                  label,
                  type: AppTextType.body, // 17px
                  customColor: primaryColor,
                ),
              ),

              // Area Trailing (Submenu Chevron atau Teks Shortcut)
              if (trailingText != null || hasSubmenu) ...[
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (trailingText != null)
                      AppText(
                        trailingText!,
                        type: AppTextType.subheadline,
                        customColor: secondaryColor,
                      ),
                    if (hasSubmenu) ...[
                      if (trailingText != null) const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: secondaryColor,
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
