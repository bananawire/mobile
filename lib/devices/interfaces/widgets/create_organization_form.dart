import 'package:flutter/material.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';

class CreateOrganizationForm extends StatefulWidget {
  final bool isLoading;
  final void Function(String name) onSubmit;

  const CreateOrganizationForm({
    super.key,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  State<CreateOrganizationForm> createState() => _CreateOrganizationFormState();
}

class _CreateOrganizationFormState extends State<CreateOrganizationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

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
            AppLocalizations.of(context)!.org_form_create_title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            enabled: !widget.isLoading,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.org_form_name_label,
              border: const OutlineInputBorder(),
            ),
            validator: (v) {
              final value = (v ?? '').trim();
              if (value.isEmpty) return AppLocalizations.of(context)!.org_form_name_required;
              if (value.length < 2) return AppLocalizations.of(context)!.org_form_name_short;
              if (value.length > 64) return AppLocalizations.of(context)!.org_form_name_long;
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
                : Text(AppLocalizations.of(context)!.common_create),
          ),
        ],
      ),
    );
  }
}
