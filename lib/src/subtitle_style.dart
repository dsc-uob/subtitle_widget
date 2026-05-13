import 'package:flutter/widgets.dart';

class SubtitleStyle {
  final TextStyle textStyle;
  final Color? backgroundColor;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final Alignment alignment;
  final EdgeInsets margin;

  const SubtitleStyle({
    this.textStyle = const TextStyle(
      color: Color(0xFFFFFFFF),
      fontSize: 16,
      shadows: [
        Shadow(
          offset: Offset(0, 1),
          blurRadius: 2,
          color: Color(0x99000000),
        ),
      ],
    ),
    this.backgroundColor = const Color(0x8A000000),
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
    this.alignment = Alignment.bottomCenter,
    this.margin = const EdgeInsets.only(bottom: 24),
  });

  SubtitleStyle copyWith({
    TextStyle? textStyle,
    Color? backgroundColor,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
    Alignment? alignment,
    EdgeInsets? margin,
  }) {
    return SubtitleStyle(
      textStyle: textStyle ?? this.textStyle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      padding: padding ?? this.padding,
      borderRadius: borderRadius ?? this.borderRadius,
      alignment: alignment ?? this.alignment,
      margin: margin ?? this.margin,
    );
  }
}
