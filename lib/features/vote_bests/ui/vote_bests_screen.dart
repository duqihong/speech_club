import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';
import '../data/vote_bests_repository.dart';
import '../data/vote_models.dart';
import '../data/vote_results_recipient.dart';
import '../data/vote_results_recipient_repository.dart';
import '../data/vote_results_share_helper.dart';
import '../data/vote_results_summary_builder.dart';
import '../data/whatsapp_phone_normalizer.dart';
import 'president_contact_dialog.dart';
import 'vote_award_detail_screen.dart';

class VoteBestsScreen extends StatefulWidget {
  VoteBestsScreen({
    super.key,
    VoteBestsRepository? repository,
    VoteResultsRecipientRepository? recipientRepository,
    this.summaryBuilder = const VoteResultsSummaryBuilder(),
    LaunchPresidentWhatsApp? launchWhatsAppToPresident,
  })  : repository = repository ?? VoteBestsRepository(),
        recipientRepository =
            recipientRepository ?? VoteResultsRecipientRepository(),
        launchWhatsAppToPresident =
            launchWhatsAppToPresident ?? launchWhatsAppToPresidentDefault;

  final VoteBestsRepository repository;
  final VoteResultsRecipientRepository recipientRepository;
  final VoteResultsSummaryBuilder summaryBuilder;
  final LaunchPresidentWhatsApp launchWhatsAppToPresident;

  @override
  State<VoteBestsScreen> createState() => _VoteBestsScreenState();
}

class _VoteBestsScreenState extends State<VoteBestsScreen> {
  late Future<VoteBestsState> _stateFuture;
  late Future<VoteResultsRecipient?> _recipientFuture;

  @override
  void initState() {
    super.initState();
    _stateFuture = widget.repository.loadState();
    _recipientFuture = widget.recipientRepository.load();
  }

  void _reload() {
    setState(() {
      _stateFuture = widget.repository.loadState();
    });
  }

  Future<void> _openAward(VoteAwardCategory category) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => VoteAwardDetailScreen(
          categoryId: category.id,
          repository: widget.repository,
        ),
      ),
    );
    if (mounted) {
      _reload();
    }
  }

  Future<void> _confirmReset() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool? shouldReset = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(l10n.voteBestsResetConfirmMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.buttonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.buttonConfirm),
            ),
          ],
        );
      },
    );

    if (shouldReset != true) {
      return;
    }
    await widget.repository.resetAll();
    if (mounted) {
      _reload();
    }
  }

  Future<void> _showContactDialog() async {
    final VoteResultsRecipient? currentRecipient =
        await widget.recipientRepository.load();
    if (!mounted) {
      return;
    }

    final PresidentContactInput? input =
        await showDialog<PresidentContactInput>(
      context: context,
      builder: (_) => PresidentContactDialog(
        initialName: currentRecipient?.name ?? '',
        initialPhoneNumber: currentRecipient?.phoneNumber ?? '',
      ),
    );

    if (input == null) {
      return;
    }
    final VoteResultsRecipient recipient =
        await widget.recipientRepository.save(
      name: input.name,
      phoneNumber: input.phoneNumber,
    );
    if (mounted) {
      setState(() {
        _recipientFuture = Future<VoteResultsRecipient?>.value(recipient);
      });
    }
  }

  Future<void> _sendResults() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final VoteResultsRecipient? recipient =
        await widget.recipientRepository.load();
    if (!mounted) {
      return;
    }
    if (recipient == null ||
        normalizeWhatsAppPhone(recipient.phoneNumber) == null) {
      _showSnackBar(l10n.voteBestsMissingPresidentPhoneNumber);
      return;
    }

    final Locale locale = Localizations.localeOf(context);
    final VoteBestsState state = await _stateFuture;
    final String summary = widget.summaryBuilder.build(
      state: state,
      locale: locale,
    );
    final bool opened = await widget.launchWhatsAppToPresident(
      rawPhone: recipient.phoneNumber,
      message: summary,
    );
    if (!mounted) {
      return;
    }
    if (opened) {
      _showSnackBar(l10n.voteBestsWhatsAppOpened);
    } else {
      _copySummaryToClipboard(summary);
      if (mounted) {
        _showSnackBar(l10n.voteBestsWhatsAppOpenFailedCopied);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _copySummaryToClipboard(String summary) {
    unawaited(
      Clipboard.setData(ClipboardData(text: summary)).catchError((_) {}),
    );
  }

  Future<void> _copyResults() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final Locale locale = Localizations.localeOf(context);
    final VoteBestsState state = await _stateFuture;
    final String summary = widget.summaryBuilder.build(
      state: state,
      locale: locale,
    );
    _copySummaryToClipboard(summary);
    if (mounted) {
      _showSnackBar(l10n.voteBestsResultsCopied);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.voteBestsManualCount),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FutureBuilder<VoteBestsState>(
          future: _stateFuture,
          builder: (
            BuildContext context,
            AsyncSnapshot<VoteBestsState> snapshot,
          ) {
            final VoteBestsState? state = snapshot.data;

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              children: <Widget>[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      l10n.voteBestsIntro,
                      style: const TextStyle(fontSize: 18, height: 1.35),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  for (final VoteAwardCategory category in state?.categories ??
                      <VoteAwardCategory>[]) ...<Widget>[
                    _AwardCard(
                      category: category,
                      onTap: () => _openAward(category),
                    ),
                    const SizedBox(height: 12),
                  ],
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: _sendResults,
                    icon: const Icon(Icons.send_outlined),
                    label: Text(l10n.voteBestsSendResultsToPresident),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: _copyResults,
                    icon: const Icon(Icons.copy_outlined),
                    label: Text(l10n.voteBestsCopyResults),
                  ),
                ),
                const SizedBox(height: 12),
                FutureBuilder<VoteResultsRecipient?>(
                  future: _recipientFuture,
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<VoteResultsRecipient?> snapshot,
                  ) {
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        minVerticalPadding: 14,
                        leading: const Icon(Icons.contact_phone_outlined),
                        title: Text(
                          l10n.voteBestsPresidentContact,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          snapshot.connectionState == ConnectionState.waiting
                              ? '…'
                              : snapshot.data == null
                                  ? l10n.voteBestsContactNotSet
                                  : '${snapshot.data!.name} · ${snapshot.data!.phoneNumber}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _showContactDialog,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: _confirmReset,
                    icon: const Icon(Icons.restart_alt),
                    label: Text(l10n.voteBestsResetMeetingVotes),
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

class _AwardCard extends StatelessWidget {
  const _AwardCard({
    required this.category,
    required this.onTap,
  });

  final VoteAwardCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final Locale locale = Localizations.localeOf(context);

    return Material(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              Text(category.icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      category.titleForLocale(locale),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.voteBestsAwardSummary(
                        category.candidates.length,
                        category.totalVotes,
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
