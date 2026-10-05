import 'package:flutter/material.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';

class AddOrganizationButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddOrganizationButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.domain_outlined, size: 18),
        label: Text(AppLocalizations.of(context)!.org_btn_add),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.22)),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
