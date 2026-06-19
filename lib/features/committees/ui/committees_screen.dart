import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/app_sizes.dart';
import '../data/committee_repository.dart';
import '../data/models/committee_member.dart';

class CommitteesScreen extends StatefulWidget {
  CommitteesScreen({
    super.key,
    CommitteeRepository? repository,
  }) : repository = repository ?? CommitteeRepository();

  final CommitteeRepository repository;

  @override
  State<CommitteesScreen> createState() => _CommitteesScreenState();
}

class _CommitteesScreenState extends State<CommitteesScreen> {
  late Future<List<CommitteeMember>> _membersFuture;

  @override
  void initState() {
    super.initState();
    _membersFuture = widget.repository.loadMembers();
  }

  void _reload() {
    setState(() {
      _membersFuture = widget.repository.loadMembers();
    });
  }

  Future<void> _editMember(CommitteeMember member, {bool isNew = false}) async {
    final bool? saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => _CommitteeMemberEditScreen(
          member: member,
          repository: widget.repository,
          isNew: isNew,
        ),
      ),
    );

    if (saved == true && mounted) {
      _reload();
    }
  }

  Future<void> _addRole() async {
    final CommitteeMember member = await widget.repository.createCustomRole();
    if (!mounted) {
      return;
    }
    await _editMember(member, isNew: true);
  }

  Future<void> _confirmReset() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool? shouldReset = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.committeesResetDialogTitle),
          content: Text(l10n.committeesResetDialogMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.buttonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.committeesResetDefaultRoles),
            ),
          ],
        );
      },
    );

    if (shouldReset != true) {
      return;
    }

    await widget.repository.resetDefaultRoles();
    if (!mounted) {
      return;
    }
    _reload();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.committeesDefaultsRestored)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.committeesTitle)),
      body: SafeArea(
        child: FutureBuilder<List<CommitteeMember>>(
          future: _membersFuture,
          builder: (
            BuildContext context,
            AsyncSnapshot<List<CommitteeMember>> snapshot,
          ) {
            final List<CommitteeMember> members =
                snapshot.data ?? <CommitteeMember>[];

            return ListView(
              padding: const EdgeInsets.all(AppSizes.pagePadding),
              children: <Widget>[
                Text(
                  l10n.committeesHelpText,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else ...<Widget>[
                  for (final CommitteeMember member in members) ...<Widget>[
                    _CommitteeMemberCard(
                      member: member,
                      onEdit: () => _editMember(member),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (members.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: Text(l10n.labelNoData)),
                    ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: _addRole,
                    icon: const Icon(Icons.add),
                    label: Text(l10n.committeesAddRole),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: _confirmReset,
                    icon: const Icon(Icons.restart_alt),
                    label: Text(l10n.committeesResetDefaultRoles),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CommitteeMemberCard extends StatelessWidget {
  const _CommitteeMemberCard({
    required this.member,
    required this.onEdit,
  });

  final CommitteeMember member;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String memberName = member.memberName.trim().isEmpty
        ? l10n.committeesNotAssigned
        : member.memberName.trim();

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Text(
                    member.roleTitle,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: l10n.buttonEdit,
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              memberName,
              style: textTheme.titleMedium?.copyWith(
                color: member.memberName.trim().isEmpty
                    ? Colors.black54
                    : Colors.black87,
              ),
            ),
            if (member.phoneOrEmail != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(member.phoneOrEmail!, style: textTheme.bodyLarge),
            ],
            if (member.note != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(member.note!, style: textTheme.bodyLarge),
            ],
          ],
        ),
      ),
    );
  }
}

class _CommitteeMemberEditScreen extends StatefulWidget {
  const _CommitteeMemberEditScreen({
    required this.member,
    required this.repository,
    required this.isNew,
  });

  final CommitteeMember member;
  final CommitteeRepository repository;
  final bool isNew;

  @override
  State<_CommitteeMemberEditScreen> createState() =>
      _CommitteeMemberEditScreenState();
}

class _CommitteeMemberEditScreenState
    extends State<_CommitteeMemberEditScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _roleTitleController;
  late final TextEditingController _memberNameController;
  late final TextEditingController _phoneOrEmailController;
  late final TextEditingController _noteController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _roleTitleController = TextEditingController(text: widget.member.roleTitle);
    _memberNameController =
        TextEditingController(text: widget.member.memberName);
    _phoneOrEmailController =
        TextEditingController(text: widget.member.phoneOrEmail ?? '');
    _noteController = TextEditingController(text: widget.member.note ?? '');
  }

  @override
  void dispose() {
    _roleTitleController.dispose();
    _memberNameController.dispose();
    _phoneOrEmailController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    setState(() => _saving = true);
    final CommitteeMember updated = widget.member.copyWith(
      roleTitle: _roleTitleController.text.trim(),
      memberName: _memberNameController.text.trim(),
      phoneOrEmail: _optionalText(_phoneOrEmailController.text),
      note: _optionalText(_noteController.text),
    );
    await widget.repository.saveMember(updated);
    if (!mounted) {
      return;
    }

    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.committeesSaved)),
    );
    Navigator.of(context).pop(true);
  }

  String? _optionalText(String value) {
    final String text = value.trim();
    return text.isEmpty ? null : text;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isNew ? l10n.committeesAddTitle : l10n.committeesEditTitle,
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSizes.pagePadding),
            children: <Widget>[
              TextFormField(
                controller: _roleTitleController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: l10n.committeesRoleTitle,
                ),
                validator: (String? value) {
                  if ((value ?? '').trim().isEmpty) {
                    return l10n.committeesRoleTitleRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _memberNameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: l10n.committeesMemberName,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _phoneOrEmailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: l10n.committeesPhoneOrEmail,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _noteController,
                minLines: 3,
                maxLines: 5,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: l10n.committeesNote,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Text(l10n.buttonSave),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
