import 'package:flutter/material.dart';

class ClaimDeviceForm extends StatefulWidget {
  final bool isLoading;
  final Future<void> Function(String claimToken) onSubmit;

  const ClaimDeviceForm({
    super.key,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  State<ClaimDeviceForm> createState() => _ClaimDeviceFormState();
}

class _ClaimDeviceFormState extends State<ClaimDeviceForm> {
  final _formKey = GlobalKey<FormState>();
  final _claimTokenController = TextEditingController();

  @override
  void dispose() {
    _claimTokenController.dispose();
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
          const Text(
            'Add device',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _claimTokenController,
            enabled: !widget.isLoading,
            decoration: const InputDecoration(
              labelText: 'Claim token',
              hintText: 'Enter the one-time token',
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Claim token is required';
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
                      await widget.onSubmit(_claimTokenController.text);
                    },
              child: widget.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add'),
            ),
          ),
        ],
      ),
    );
  }
}
