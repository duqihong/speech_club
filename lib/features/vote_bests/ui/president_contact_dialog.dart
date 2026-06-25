import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class PresidentContactInput {
  const PresidentContactInput({
    required this.name,
    required this.phoneNumber,
  });

  final String name;
  final String phoneNumber;
}

class PresidentContactDialog extends StatefulWidget {
  const PresidentContactDialog({
    super.key,
    required this.initialName,
    required this.initialPhoneNumber,
  });

  final String initialName;
  final String initialPhoneNumber;

  @override
  State<PresidentContactDialog> createState() => _PresidentContactDialogState();
}

class _PresidentContactDialogState extends State<PresidentContactDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  String? _nameError;
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _phoneController = TextEditingController(text: widget.initialPhoneNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String name = _nameController.text.trim();
    final String phoneNumber = _phoneController.text.trim();
    if (name.isEmpty || phoneNumber.isEmpty) {
      setState(() {
        _nameError = name.isEmpty ? l10n.voteBestsPresidentNameError : null;
        _phoneError =
            phoneNumber.isEmpty ? l10n.voteBestsPhoneNumberError : null;
      });
      return;
    }
    Navigator.of(context).pop(
      PresidentContactInput(name: name, phoneNumber: phoneNumber),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.voteBestsPresidentContact),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            key: const Key('presidentNameField'),
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: l10n.voteBestsPresidentName,
              errorText: _nameError,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('presidentPhoneField'),
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: l10n.voteBestsPhoneNumber,
              errorText: _phoneError,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.buttonCancel),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(l10n.buttonSave),
        ),
      ],
    );
  }
}
