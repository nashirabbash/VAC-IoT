import 'package:flutter/material.dart';
import 'package:vac_dashboard_app/asset/color_tokens.dart';

enum AppTextType {
  largeTitle,
  title1,
  title2,
  title3,
  headline,
  body,
  callout,
  subheadline,
  footnote,
  caption1,
  caption2,
}

enum AppTextColor {
  primary,
  secondary,
  tertiary,
  quaternary,
}

class AppText extends StatelessWidget {
  final String text;
  final AppTextType type;
  final AppTextColor color;
  final bool isItalic;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Color? customColor;
  final double? customLetterSpacing;

  const AppText(
    this.text, {
    super.key,
    this.type = AppTextType.body,
    this.color = AppTextColor.primary,
    this.isItalic = false,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.customColor,
    this.customLetterSpacing,
  });

  double get _fontSize {
    switch (type) {
      case AppTextType.largeTitle:
        return 34.0;
      case AppTextType.title1:
        return 28.0;
      case AppTextType.title2:
        return 22.0;
      case AppTextType.title3:
        return 20.0;
      case AppTextType.headline:
      case AppTextType.body:
        return 17.0;
      case AppTextType.callout:
        return 16.0;
      case AppTextType.subheadline:
        return 15.0;
      case AppTextType.footnote:
        return 13.0;
      case AppTextType.caption1:
        return 12.0;
      case AppTextType.caption2:
        return 11.0;
    }
  }

  FontWeight get _defaultFontWeight {
    switch (type) {
      case AppTextType.largeTitle:
      case AppTextType.title1:
      case AppTextType.title2:
        return FontWeight.w700;
      case AppTextType.title3:
      case AppTextType.headline:
        return FontWeight.w600; // Often used as w600 in typical flutter unless custom font is used
      case AppTextType.body:
      case AppTextType.callout:
      case AppTextType.subheadline:
      case AppTextType.footnote:
      case AppTextType.caption1:
      case AppTextType.caption2:
        return FontWeight.w400;
    }
  }

  double get _height {
    switch (type) {
      case AppTextType.largeTitle:
      case AppTextType.title1:
        return 1.21;
      case AppTextType.title2:
        return 1.27;
      case AppTextType.title3:
        return 1.25;
      case AppTextType.headline:
      case AppTextType.body:
        return 1.29;
      case AppTextType.callout:
        return 1.31;
      case AppTextType.subheadline:
      case AppTextType.caption1:
        return 1.33;
      case AppTextType.footnote:
        return 1.38;
      case AppTextType.caption2:
        return 1.18;
    }
  }

  double get _letterSpacing {
    switch (type) {
      case AppTextType.largeTitle:
        return 0.40;
      case AppTextType.title1:
        return 0.38;
      case AppTextType.title2:
        return -0.26;
      case AppTextType.title3:
        return -0.45;
      case AppTextType.headline:
      case AppTextType.body:
        return -0.43;
      case AppTextType.callout:
        return -0.31;
      case AppTextType.subheadline:
        return -0.23;
      case AppTextType.footnote:
        return -0.08;
      case AppTextType.caption1:
        return 0.0;
      case AppTextType.caption2:
        return 0.06;
    }
  }

  Color _resolvedColor(BuildContext context) {
    switch (color) {
      case AppTextColor.primary:
        return context.colors.labelsPrimary;
      case AppTextColor.secondary:
        return context.colors.labelsSecondary;
      case AppTextColor.tertiary:
        return context.colors.labelsTertiary;
      case AppTextColor.quaternary:
        return context.colors.labelsQuaternary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        fontFamily: 'SF Pro', // Pastikan font ini sudah ditambahkan ke pubspec.yaml jika ingin tampil akurat
        fontSize: _fontSize,
        fontWeight: fontWeight ?? _defaultFontWeight,
        fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
        height: _height,
        letterSpacing: customLetterSpacing ?? _letterSpacing,
        color: customColor ?? _resolvedColor(context),
      ),
    );
  }
}
