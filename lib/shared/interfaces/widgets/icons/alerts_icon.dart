import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AlertsIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const AlertsIcon({
    super.key,
    this.size = 24.0,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      '''<svg width="20" height="16" viewBox="0 0 20 16" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M10 3.77L16.39 14H3.61L10 3.77ZM10 0L0 16H20L10 0Z" fill="#A9AAAA"/>
</svg>''',
      width: size,
      height: size * 16 / 20,
      colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
    );
  }
}
