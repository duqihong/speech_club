import 'package:shared_preferences/shared_preferences.dart';

import '../screens/timer/timer_models.dart';

class TimerPrefs {
  static const String timerCustomGreenKey = 'timer_custom_green';
  static const String timerCustomYellowKey = 'timer_custom_yellow';
  static const String timerCustomRedKey = 'timer_custom_red';
  static const String timerCustomOvertimeKey = 'timer_custom_overtime';

  static Future<TimerPreset> loadCustomPreset() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? green = prefs.getInt(timerCustomGreenKey);
    final int? yellow = prefs.getInt(timerCustomYellowKey);
    final int? red = prefs.getInt(timerCustomRedKey);
    final int? overtime = prefs.getInt(timerCustomOvertimeKey);

    if (green == null || yellow == null || red == null || overtime == null) {
      return TimerPreset.custom;
    }

    return TimerPreset(
      name: 'Custom',
      greenSec: green,
      yellowSec: yellow,
      redSec: red,
      overtimeSec: overtime,
    );
  }

  static Future<void> saveCustomPreset(TimerPreset preset) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(timerCustomGreenKey, preset.greenSec);
    await prefs.setInt(timerCustomYellowKey, preset.yellowSec);
    await prefs.setInt(timerCustomRedKey, preset.redSec);
    await prefs.setInt(timerCustomOvertimeKey, preset.overtimeSec);
  }
}
