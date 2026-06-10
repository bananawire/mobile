import 'package:flutter/material.dart';

class DevicePowerStatusBadge extends StatelessWidget {
  final bool isOn;

  const DevicePowerStatusBadge({
    super.key,
    required this.isOn,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isOn ? const Color(0xFF21D07A) : Colors.white.withValues(alpha: 0.10);
    // In the design, the green power button reads as a filled green dot with a dark icon.
    final fg = isOn ? Colors.black : Colors.white70;
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.power_settings_new, size: 10.5, color: fg),
    );
  }
}
