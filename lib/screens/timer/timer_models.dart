enum TimerStage { idle, running, overtime }

class TimerPreset {
  const TimerPreset({
    required this.name,
    required this.greenSec,
    required this.yellowSec,
    required this.redSec,
    required this.overtimeSec,
  });

  final String name;
  final int greenSec;
  final int yellowSec;
  final int redSec;
  final int overtimeSec;
  bool get isCustom => name == 'Custom';

  static const TimerPreset preset57 = TimerPreset(
    name: '5–7',
    greenSec: 300,
    yellowSec: 360,
    redSec: 420,
    overtimeSec: 450,
  );

  static const TimerPreset preset46 = TimerPreset(
    name: '4–6',
    greenSec: 240,
    yellowSec: 300,
    redSec: 360,
    overtimeSec: 390,
  );

  static const TimerPreset preset23 = TimerPreset(
    name: '2–3',
    greenSec: 120,
    yellowSec: 150,
    redSec: 180,
    overtimeSec: 210,
  );

  static const TimerPreset custom = TimerPreset(
    name: 'Custom',
    greenSec: 300,
    yellowSec: 360,
    redSec: 420,
    overtimeSec: 450,
  );

  static const List<TimerPreset> defaults = <TimerPreset>[
    preset57,
    preset46,
    preset23,
    custom,
  ];
}
