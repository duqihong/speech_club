import 'package:flutter/material.dart';

import 'timer_models.dart';

class CustomPresetSheet extends StatefulWidget {
  const CustomPresetSheet({
    super.key,
    required this.initialPreset,
  });

  final TimerPreset initialPreset;

  @override
  State<CustomPresetSheet> createState() => _CustomPresetSheetState();
}

class _CustomPresetSheetState extends State<CustomPresetSheet> {
  late final TextEditingController _greenMinController;
  late final TextEditingController _greenSecController;
  late final TextEditingController _yellowMinController;
  late final TextEditingController _yellowSecController;
  late final TextEditingController _redMinController;
  late final TextEditingController _redSecController;
  late final TextEditingController _overtimeMinController;
  late final TextEditingController _overtimeSecController;

  String? _errorText;

  @override
  void initState() {
    super.initState();
    _greenMinController = TextEditingController(
      text: (widget.initialPreset.greenSec ~/ 60).toString(),
    );
    _greenSecController = TextEditingController(
      text: (widget.initialPreset.greenSec % 60).toString().padLeft(2, '0'),
    );
    _yellowMinController = TextEditingController(
      text: (widget.initialPreset.yellowSec ~/ 60).toString(),
    );
    _yellowSecController = TextEditingController(
      text: (widget.initialPreset.yellowSec % 60).toString().padLeft(2, '0'),
    );
    _redMinController = TextEditingController(
      text: (widget.initialPreset.redSec ~/ 60).toString(),
    );
    _redSecController = TextEditingController(
      text: (widget.initialPreset.redSec % 60).toString().padLeft(2, '0'),
    );
    _overtimeMinController = TextEditingController(
      text: (widget.initialPreset.overtimeSec ~/ 60).toString(),
    );
    _overtimeSecController = TextEditingController(
      text: (widget.initialPreset.overtimeSec % 60).toString().padLeft(2, '0'),
    );
  }

  @override
  void dispose() {
    _greenMinController.dispose();
    _greenSecController.dispose();
    _yellowMinController.dispose();
    _yellowSecController.dispose();
    _redMinController.dispose();
    _redSecController.dispose();
    _overtimeMinController.dispose();
    _overtimeSecController.dispose();
    super.dispose();
  }

  int _parseField(TextEditingController controller) {
    return int.tryParse(controller.text.trim()) ?? 0;
  }

  int _toSeconds(TextEditingController minController,
      TextEditingController secController) {
    final int min = _parseField(minController).clamp(0, 9999);
    final int sec = _parseField(secController).clamp(0, 59);
    return (min * 60) + sec;
  }

  void _save() {
    final int green = _toSeconds(_greenMinController, _greenSecController);
    final int yellow = _toSeconds(_yellowMinController, _yellowSecController);
    final int red = _toSeconds(_redMinController, _redSecController);
    final int overtime =
        _toSeconds(_overtimeMinController, _overtimeSecController);

    final bool valid =
        green > 0 && green < yellow && yellow < red && red < overtime;
    if (!valid) {
      setState(() {
        _errorText = 'Must be Green < Yellow < Red < Overtime';
      });
      return;
    }

    Navigator.of(context).pop(
      TimerPreset(
        name: 'Custom',
        greenSec: green,
        yellowSec: yellow,
        redSec: red,
        overtimeSec: overtime,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'Custom Preset',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            _TimeRow(
              label: 'Green',
              minController: _greenMinController,
              secController: _greenSecController,
            ),
            const SizedBox(height: 8),
            _TimeRow(
              label: 'Yellow',
              minController: _yellowMinController,
              secController: _yellowSecController,
            ),
            const SizedBox(height: 8),
            _TimeRow(
              label: 'Red',
              minController: _redMinController,
              secController: _redSecController,
            ),
            const SizedBox(height: 8),
            _TimeRow(
              label: 'Overtime',
              minController: _overtimeMinController,
              secController: _overtimeSecController,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _errorText ?? '',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _save,
                      child: const Text('Save'),
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

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.label,
    required this.minController,
    required this.secController,
  });

  final String label;
  final TextEditingController minController;
  final TextEditingController secController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 90,
          child: Text(
            '$label (mm:ss)',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: minController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Min',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            ':',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: TextField(
            controller: secController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Sec',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}
