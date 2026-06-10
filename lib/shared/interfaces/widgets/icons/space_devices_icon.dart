import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SpaceDevicesIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const SpaceDevicesIcon({
    super.key,
    this.size = 24.0,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      '''<svg width="28" height="26" viewBox="0 0 28 26" fill="none" xmlns="http://www.w3.org/2000/svg">
<g filter="url(#filter0_d_859_1447)">
<path d="M8 12C9.1 12 10 12.9 10 14C10 15.1 9.1 16 8 16C6.9 16 6 15.1 6 14C6 12.9 6.9 12 8 12ZM8 10C5.8 10 4 11.8 4 14C4 16.2 5.8 18 8 18C10.2 18 12 16.2 12 14C12 11.8 10.2 10 8 10ZM14 2C15.1 2 16 2.9 16 4C16 5.1 15.1 6 14 6C12.9 6 12 5.1 12 4C12 2.9 12.9 2 14 2ZM14 0C11.8 0 10 1.8 10 4C10 6.2 11.8 8 14 8C16.2 8 18 6.2 18 4C18 1.8 16.2 0 14 0ZM20 12C21.1 12 22 12.9 22 14C22 15.1 21.1 16 20 16C18.9 16 18 15.1 18 14C18 12.9 18.9 12 20 12ZM20 10C17.8 10 16 11.8 16 14C16 16.2 17.8 18 20 18C22.2 18 24 16.2 24 14C24 11.8 22.2 10 20 10Z" fill="white"/>
</g>
<defs>
<filter id="filter0_d_859_1447" x="0" y="0" width="28" height="26" filterUnits="userSpaceOnUse" color-interpolation-filters="sRGB">
<feFlood flood-opacity="0" result="BackgroundImageFix"/>
<feColorMatrix in="SourceAlpha" type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0" result="hardAlpha"/>
<feOffset dy="4"/>
<feGaussianBlur stdDeviation="2"/>
<feComposite in2="hardAlpha" operator="out"/>
<feColorMatrix type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.25 0"/>
<feBlend mode="normal" in2="BackgroundImageFix" result="effect1_dropShadow_859_1447"/>
<feBlend mode="normal" in="SourceGraphic" in2="effect1_dropShadow_859_1447" result="shape"/>
</filter>
</defs>
</svg>''',
      width: size,
      height: size * 26 / 28,
      colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
    );
  }
}
