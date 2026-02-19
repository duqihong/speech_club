import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../storage/timer_prefs.dart';
import 'custom_preset_sheet.dart';
import 'ding_service.dart';
import 'test_panel.dart';
import 'timer_models.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with WidgetsBindingObserver {
  final DingService _dingService = DingService.instance;

  TimerPreset _customPreset = TimerPreset.custom;
  TimerPreset _selectedPreset = TimerPreset.defaults.first;
  Timer? _ticker;
  DateTime? _startTime;

  bool _isRunning = false;
  bool _dingPlayed = false;
  bool _showTestPanel = false;
  Completer<void>? _testPanelCompleter;

  int _elapsedSec = 0;
  Color? _previewColor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCustomPreset();
  }

  @override
  void dispose() {
    _closeTestPanel();
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isRunning) {
      _updateElapsed();
    }
  }

  List<TimerPreset> get _presetOptions => <TimerPreset>[
        TimerPreset.preset57,
        TimerPreset.preset46,
        TimerPreset.preset23,
        _customPreset,
      ];

  TimerStage get _stage {
    if (!_isRunning && _elapsedSec == 0) {
      return TimerStage.idle;
    }
    if (_elapsedSec >= _selectedPreset.overtimeSec) {
      return TimerStage.overtime;
    }
    return TimerStage.running;
  }

  Color get _baseColor {
    if (_elapsedSec >= _selectedPreset.redSec) {
      return Colors.red;
    }
    if (_elapsedSec >= _selectedPreset.yellowSec) {
      return Colors.yellow;
    }
    if (_elapsedSec >= _selectedPreset.greenSec) {
      return Colors.green;
    }
    return Colors.black;
  }

  String get _clockText {
    final int min = _elapsedSec ~/ 60;
    final int sec = _elapsedSec % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  void _start() {
    if (_isRunning) {
      return;
    }
    final DateTime now = DateTime.now();
    _startTime = now.subtract(Duration(seconds: _elapsedSec));
    setState(() {
      _isRunning = true;
      if (_elapsedSec == 0) {
        _dingPlayed = false;
      }
      _showTestPanel = false;
      _previewColor = null;
    });
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) {
      _updateElapsed();
    });
  }

  void _stop() {
    _ticker?.cancel();
    _ticker = null;
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _closeTestPanel();
    _ticker?.cancel();
    _ticker = null;
    setState(() {
      _isRunning = false;
      _startTime = null;
      _elapsedSec = 0;
      _dingPlayed = false;
      _previewColor = null;
      _showTestPanel = false;
    });
  }

  Future<void> _openTestPanel() async {
    if (_isRunning || _showTestPanel) {
      return;
    }
    await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    if (!mounted) {
      return;
    }
    final Completer<void> completer = Completer<void>();
    setState(() {
      _showTestPanel = true;
      _testPanelCompleter = completer;
    });
    try {
      await completer.future;
    } finally {
      await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      if (mounted) {
        setState(() {
          _testPanelCompleter = null;
        });
      }
    }
  }

  void _closeTestPanel() {
    if (!_showTestPanel) {
      return;
    }
    setState(() {
      _showTestPanel = false;
    });
    final Completer<void>? completer = _testPanelCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
  }

  Future<void> _handleBackPressed() async {
    if (_isRunning) {
      final bool? ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Exit Timer?'),
          content: const Text('Timer is running. Exit anyway?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Exit'),
            ),
          ],
        ),
      );
      if (ok == true && mounted) {
        Navigator.pop(context);
      }
      return;
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _updateElapsed() async {
    if (!_isRunning || _startTime == null) {
      return;
    }
    final int previous = _elapsedSec;
    final int updated = DateTime.now().difference(_startTime!).inSeconds;

    if (updated == previous) {
      return;
    }

    setState(() {
      _elapsedSec = updated;
    });

    final int overtime = _selectedPreset.overtimeSec;
    if (previous < overtime && updated >= overtime && !_dingPlayed) {
      _dingPlayed = true;
      await _dingService.playDingOnce();
    }
  }

  Future<void> _loadCustomPreset() async {
    final TimerPreset preset = await TimerPrefs.loadCustomPreset();
    if (!mounted) {
      return;
    }
    setState(() {
      _customPreset = preset;
      if (_selectedPreset.isCustom) {
        _selectedPreset = _customPreset;
      }
    });
  }

  Future<void> _openCustomPresetSheet() async {
    if (_isRunning || !_selectedPreset.isCustom) {
      return;
    }
    final TimerPreset? updatedPreset = await showModalBottomSheet<TimerPreset>(
      context: context,
      isScrollControlled: true,
      builder: (_) => CustomPresetSheet(initialPreset: _customPreset),
    );
    if (updatedPreset == null || !mounted) {
      return;
    }
    setState(() {
      _customPreset = updatedPreset;
      _selectedPreset = updatedPreset;
    });
    await TimerPrefs.saveCustomPreset(updatedPreset);
  }

  Widget _buildPresetDropdown() {
    return DropdownButtonFormField<TimerPreset>(
      key: ValueKey<String>(
        '${_selectedPreset.name}:${_selectedPreset.greenSec}:${_selectedPreset.yellowSec}:${_selectedPreset.redSec}:${_selectedPreset.overtimeSec}',
      ),
      initialValue: _selectedPreset,
      isExpanded: true,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: Colors.white.withValues(
          alpha: _isRunning ? 0.75 : 0.95,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: const OutlineInputBorder(),
      ),
      items: _presetOptions
          .map(
            (TimerPreset preset) => DropdownMenuItem<TimerPreset>(
              value: preset,
              child: Text(
                preset.name,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
      selectedItemBuilder: (BuildContext context) {
        return _presetOptions
            .map(
              (TimerPreset preset) => Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  preset.name,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
            .toList();
      },
      onChanged: _isRunning
          ? null
          : (TimerPreset? value) {
              if (value == null) {
                return;
              }
              setState(() {
                _selectedPreset = value;
              });
            },
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required String label,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 128),
      child: SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            textStyle: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18),
          ),
          child: Text(label),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = _previewColor ?? _baseColor;
    final bool canReset = _stage == TimerStage.overtime;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: canReset ? _resetTimer : null,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Positioned.fill(
              child: ColoredBox(
                color: backgroundColor,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Stack(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                const SizedBox(width: 48),
                                Expanded(child: _buildPresetDropdown()),
                                if (_selectedPreset.isCustom &&
                                    !_isRunning) ...<Widget>[
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: _openCustomPresetSheet,
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                    tooltip: 'Edit custom preset',
                                  ),
                                ],
                                const SizedBox(width: 8),
                                if (!_isRunning)
                                  IconButton(
                                    onPressed: _openTestPanel,
                                    icon: const Icon(
                                      Icons.science_outlined,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                    tooltip: 'Test panel',
                                  )
                                else
                                  const SizedBox(width: 48),
                              ],
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  _clockText,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 96,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ),
                            if (canReset)
                              const Padding(
                                padding: EdgeInsets.fromLTRB(16, 0, 16, 88),
                                child: Text(
                                  'Overtime reached. Tap anywhere to reset.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            else
                              const SizedBox(height: 88),
                          ],
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: SafeArea(
                            top: false,
                            minimum: const EdgeInsets.only(bottom: 8),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 16,
                              runSpacing: 8,
                              children: <Widget>[
                                _buildActionButton(
                                  onPressed: _isRunning ? _stop : _start,
                                  label: _isRunning ? 'Stop' : 'Start',
                                ),
                                _buildActionButton(
                                  onPressed: _resetTimer,
                                  label: 'Reset',
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: SafeArea(
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              iconSize: 28,
                              onPressed: _handleBackPressed,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_showTestPanel && !_isRunning)
              TimerTestPanel(
                onPreviewColor: (Color? color) {
                  setState(() {
                    _previewColor = color;
                  });
                },
                onPreviewDing: () {
                  _dingService.playDingOnce();
                },
                onClose: () {
                  _closeTestPanel();
                },
              ),
          ],
        ),
      ),
    );
  }
}
