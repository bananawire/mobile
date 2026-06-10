import 'package:flutter/material.dart';

class EditDeviceNameForm extends StatefulWidget {
  final bool isLoading;
  final String initialName;
  final void Function(String name) onSubmit;

  const EditDeviceNameForm({
    super.key,
    required this.isLoading,
    required this.initialName,
    required this.onSubmit,
  });

  @override
  State<EditDeviceNameForm> createState() => _EditDeviceNameFormState();
}

class _EditDeviceNameFormState extends State<EditDeviceNameForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;
    widget.onSubmit(_nameController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Edit device',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            enabled: !widget.isLoading,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Device name',
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              final value = (v ?? '').trim();
              if (value.isEmpty) return 'Name is required';
              if (value.length < 2) return 'Name is too short';
              if (value.length > 64) return 'Name is too long';
              return null;
            },
            onFieldSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: widget.isLoading ? null : _submit,
            child: widget.isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
    );
  }
}
