import 'package:flutter/material.dart';

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
                            const Expanded(
                              child: Text(
                                'Test Panel',
                                textAlign: TextAlign.center,
                                style: TextStyle(
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
                                  label: 'Green',
                                  onPressed: () => onPreviewColor(Colors.green),
                                ),
                                const SizedBox(height: 10),
                                _PanelButton(
                                  label: 'Yellow',
                                  onPressed: () =>
                                      onPreviewColor(Colors.yellow),
                                ),
                                const SizedBox(height: 10),
                                _PanelButton(
                                  label: 'Red',
                                  onPressed: () => onPreviewColor(Colors.red),
                                ),
                                const SizedBox(height: 10),
                                _PanelButton(
                                  label: 'Ding',
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
