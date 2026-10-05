import 'package:flutter/material.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';

class PairDeviceForm extends StatefulWidget {
  final bool isLoading;
  final Future<void> Function(String hardwareId) onSubmit;

  const PairDeviceForm({
    super.key,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  State<PairDeviceForm> createState() => _PairDeviceFormState();
}

class _PairDeviceFormState extends State<PairDeviceForm> {
  final _formKey = GlobalKey<FormState>();
  final _hardwareIdController = TextEditingController();

  @override
  void dispose() {
    _hardwareIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.devices_form_pair_title,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _hardwareIdController,
            enabled: !widget.isLoading,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.devices_form_pair_hardware,
              hintText: AppLocalizations.of(context)!.devices_form_pair_hardware_hint,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return AppLocalizations.of(context)!.devices_form_pair_hardware_required;
              return null;
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: widget.isLoading
                  ? null
                  : () async {
                      if (!(_formKey.currentState?.validate() ?? false)) return;
                      await widget.onSubmit(_hardwareIdController.text);
                    },
              child: widget.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(AppLocalizations.of(context)!.devices_form_pair_button),
            ),
          ),
        ],
      ),
    );
  }
}
