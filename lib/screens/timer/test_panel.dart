import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class TimerTestPanel extends StatelessWidget {
  const TimerTestPanel({
    super.key,
    required this.onPreviewColor,
    required this.onPreviewDing,
    required this.onClose,
  });

  final ValueChanged<Color?> onPreviewColor;
  final VoidCallback onPreviewDing;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          onPreviewColor(null);
          onClose();
        },
        child: ColoredBox(
          color: Colors.black54,
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: Dialog(
                insetPadding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                l10n.timerTestPanel,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
                              ),
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                onPreviewColor(null);
                                onClose();
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Flexible(
                          child: SingleChildScrollView(
                            child: Column(
                              children: <Widget>[
                                _PanelButton(
                                  label: l10n.timerStageGreen,
                                  onPressed: () => onPreviewColor(Colors.green),
                                ),
                                const SizedBox(height: 10),
                                _PanelButton(
                                  label: l10n.timerStageYellow,
                                  onPressed: () =>
                                      onPreviewColor(Colors.yellow),
                                ),
                                const SizedBox(height: 10),
                                _PanelButton(
                                  label: l10n.timerStageRed,
                                  onPressed: () => onPreviewColor(Colors.red),
                                ),
                                const SizedBox(height: 10),
                                _PanelButton(
                                  label: l10n.timerDing,
                                  onPressed: onPreviewDing,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PanelButton extends StatelessWidget {
  const _PanelButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
