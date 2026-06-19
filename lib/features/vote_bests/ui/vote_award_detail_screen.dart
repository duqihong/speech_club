import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../data/vote_bests_repository.dart';
import '../data/vote_models.dart';

class VoteAwardDetailScreen extends StatefulWidget {
  VoteAwardDetailScreen({
    super.key,
    required this.categoryId,
    VoteBestsRepository? repository,
  }) : repository = repository ?? VoteBestsRepository();

  final String categoryId;
  final VoteBestsRepository repository;

  @override
  State<VoteAwardDetailScreen> createState() => _VoteAwardDetailScreenState();
}

class _VoteAwardDetailScreenState extends State<VoteAwardDetailScreen> {
  late Future<VoteBestsState> _stateFuture;

  @override
  void initState() {
    super.initState();
    _stateFuture = widget.repository.loadState();
  }

  void _reloadWithState(VoteBestsState state) {
    setState(() {
      _stateFuture = Future<VoteBestsState>.value(state);
    });
  }

  Future<void> _addCandidate(VoteAwardCategory category) async {
    final String? name = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return _AddCandidateDialog(category: category);
      },
    );

    if (name == null || name.trim().isEmpty) {
      return;
    }
    final VoteBestsState updated = await widget.repository.addCandidate(
      categoryId: category.id,
      name: name,
    );
    if (mounted) {
      _reloadWithState(updated);
    }
  }

  Future<void> _deleteCandidate(
    VoteAwardCategory category,
    VoteCandidate candidate,
  ) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(l10n.voteBestsRemoveCandidateMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.buttonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.buttonDelete),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }
    final VoteBestsState updated = await widget.repository.deleteCandidate(
      categoryId: category.id,
      candidateId: candidate.id,
    );
    if (mounted) {
      _reloadWithState(updated);
    }
  }

  Future<void> _increment(
      VoteAwardCategory category, VoteCandidate candidate) async {
    final VoteBestsState updated = await widget.repository.incrementVote(
      categoryId: category.id,
      candidateId: candidate.id,
    );
    if (mounted) {
      _reloadWithState(updated);
    }
  }

  Future<void> _decrement(
      VoteAwardCategory category, VoteCandidate candidate) async {
    final VoteBestsState updated = await widget.repository.decrementVote(
      categoryId: category.id,
      candidateId: candidate.id,
    );
    if (mounted) {
      _reloadWithState(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final Locale locale = Localizations.localeOf(context);

    return FutureBuilder<VoteBestsState>(
      future: _stateFuture,
      builder: (BuildContext context, AsyncSnapshot<VoteBestsState> snapshot) {
        final VoteBestsState state = snapshot.data ??
            VoteBestsState(categories: VoteBestsRepository.defaultCategories);
        final VoteAwardCategory category =
            state.categoryById(widget.categoryId);

        return Scaffold(
          appBar: AppBar(
            title: Text('${category.icon} ${category.titleForLocale(locale)}'),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              children: <Widget>[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      l10n.voteBestsDetailHelp,
                      style: const TextStyle(fontSize: 18, height: 1.35),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  title: l10n.voteBestsCandidates,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      if (category.candidates.isEmpty)
                        Text(
                          l10n.voteBestsNoCandidatesYet,
                          style: const TextStyle(fontSize: 17),
                        )
                      else
                        for (final VoteCandidate candidate
                            in category.candidates) ...<Widget>[
                          _CandidateCard(
                            candidate: candidate,
                            onIncrement: () => _increment(category, candidate),
                            onDecrement: () => _decrement(category, candidate),
                            onDelete: () =>
                                _deleteCandidate(category, candidate),
                          ),
                          const SizedBox(height: 10),
                        ],
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 56,
                        child: FilledButton.icon(
                          onPressed: () => _addCandidate(category),
                          icon: const Icon(Icons.add),
                          label: Text(l10n.voteBestsAddCandidate),
                        ),
                      ),
                    ],
                  ),
                ),
                _SectionCard(
                  title: l10n.voteBestsResults,
                  child: _ResultsView(category: category),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _AddCandidateDialog extends StatefulWidget {
  const _AddCandidateDialog({required this.category});

  final VoteAwardCategory category;

  @override
  State<_AddCandidateDialog> createState() => _AddCandidateDialogState();
}

class _AddCandidateDialogState extends State<_AddCandidateDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateAndClose() {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() {
        _errorText = l10n.voteBestsPleaseEnterName;
      });
      return;
    }
    final bool duplicate = widget.category.candidates.any(
      (VoteCandidate candidate) =>
          candidate.name.trim().toLowerCase() == name.toLowerCase(),
    );
    if (duplicate) {
      setState(() {
        _errorText = l10n.voteBestsDuplicateName;
      });
      return;
    }
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.voteBestsAddCandidate),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: l10n.voteBestsCandidateName,
          errorText: _errorText,
        ),
        onSubmitted: (_) => _validateAndClose(),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.buttonCancel),
        ),
        FilledButton(
          onPressed: _validateAndClose,
          child: Text(l10n.buttonSave),
        ),
      ],
    );
  }
}

class _CandidateCard extends StatelessWidget {
  const _CandidateCard({
    required this.candidate,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
  });

  final VoteCandidate candidate;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Material(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Text(
                    candidate.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l10n.buttonDelete,
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l10n.voteBestsVotesLabel(candidate.votes),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: OutlinedButton(
                      onPressed: onDecrement,
                      child: const Text('-1', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: FilledButton(
                      onPressed: onIncrement,
                      child: const Text('+1', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultsView extends StatelessWidget {
  const _ResultsView({
    required this.category,
  });

  final VoteAwardCategory category;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final List<VoteCandidate> sorted = List<VoteCandidate>.of(
      category.candidates,
    )..sort((VoteCandidate a, VoteCandidate b) {
        final int voteCompare = b.votes.compareTo(a.votes);
        if (voteCompare != 0) {
          return voteCompare;
        }
        return a.createdAt.compareTo(b.createdAt);
      });

    if (sorted.isEmpty) {
      return Text(
        l10n.voteBestsNoCandidatesYet,
        style: const TextStyle(fontSize: 17),
      );
    }

    final int topVotes = sorted.first.votes;
    final String statusText;
    if (topVotes == 0) {
      statusText = l10n.voteBestsNoVotesYet;
    } else if (sorted.where((VoteCandidate c) => c.votes == topVotes).length >
        1) {
      statusText = l10n.voteBestsCurrentTie;
    } else {
      statusText = l10n.voteBestsCurrentLeader(sorted.first.name);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          statusText,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        for (final VoteCandidate candidate in sorted)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              '${candidate.name}: ${candidate.votes}',
              style: const TextStyle(fontSize: 17),
            ),
          ),
      ],
    );
  }
}
