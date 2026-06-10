import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GoogleIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const GoogleIcon({
    super.key,
    this.size = 24.0,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      '''<svg width="17" height="17" viewBox="0 0 17 17" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M16.4504 7.61088C16.6564 9.45235 16.2167 11.3082 15.2065 12.8615C14.1963 14.4149 12.6782 15.5694 10.9114 16.1279C9.14464 16.6864 7.23878 16.6144 5.51926 15.924C3.79973 15.2336 2.37319 13.9677 1.48321 12.3425C0.593225 10.7172 0.295002 8.83347 0.639461 7.01282C0.983919 5.19217 1.9497 3.54755 3.37188 2.35978C4.79407 1.17201 6.58446 0.514757 8.43735 0.500246C10.2902 0.485734 12.0907 1.11487 13.5313 2.28021L11.1713 4.40644C10.3255 3.85466 9.32956 3.57836 8.32035 3.6155C7.31115 3.65265 6.33821 4.00141 5.53524 4.61388C4.73226 5.22634 4.13866 6.07244 3.83601 7.03591C3.53335 7.99938 3.53648 9.03294 3.84499 9.99455C4.15349 10.9562 4.75222 11.7986 5.55889 12.4062C6.36557 13.0138 7.34061 13.3566 8.35002 13.3877C9.35943 13.4187 10.3537 13.1363 11.1961 12.5794C12.0386 12.0225 12.6879 11.2184 13.0549 10.2775H9.38821V7.61088H16.4504Z" stroke="white" stroke-linecap="round" stroke-linejoin="round"/>
</svg>''',
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
    );
  }
}
