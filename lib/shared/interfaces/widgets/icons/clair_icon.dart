import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ClairIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const ClairIcon({
    super.key,
    this.size = 24.0,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      '''<svg width="492" height="286" viewBox="0 0 492 286" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M417.538 26.2055C204.038 -16.2946 -54.4615 163.706 57.038 271.706C-144.273 164.971 232.035 -58.2942 491.038 14.2061L417.538 26.2055Z" fill="white"/>
<path d="M373.473 26.0002C38.4731 65.5002 19.973 307.772 317.473 233.272L232.471 235.764C325.863 223.017 376.153 209.294 467.475 178.265C360.44 246.172 259.975 285.765 168.975 285.765C77.9749 285.765 23.4746 242.762 54.4748 178.265C117.475 66.2618 261.475 21.4903 373.473 26.0002Z" fill="white"/>
</svg>''',
      width: size,
      height: (size * 286) / 492,
      colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
    );
  }
}
