import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/grade_scale.dart';

class GradeScaleProvider extends ChangeNotifier {
  List<GradeScale> _scales = [];
  late SharedPreferences _prefs;
  static const _key = 'grade_scales';
  bool _isLocked = true; // Default to locked

  List<GradeScale> get scales => List.unmodifiable(_scales);
  bool get isLocked => _isLocked;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadScales();
    if (_scales.isEmpty) {
      _scales = [
        GradeScale(grade: 'A', points: 4.0),
        GradeScale(grade: 'A-', points: 3.7),
        GradeScale(grade: 'B+', points: 3.3),
        GradeScale(grade: 'B', points: 3.0),
        GradeScale(grade: 'B-', points: 2.7),
        GradeScale(grade: 'C+', points: 2.3),
        GradeScale(grade: 'C', points: 2.0),
        GradeScale(grade: 'C-', points: 1.7),
        GradeScale(grade: 'D+', points: 1.3),
        GradeScale(grade: 'D', points: 1.0),
        GradeScale(grade: 'F', points: 0.0),
      ];
      await _saveScales();
    }
  }

  void _loadScales() {
    final json = _prefs.getStringList(_key) ?? [];
    _scales = json.map((e) => GradeScale.fromJson(jsonDecode(e))).toList()
      ..sort((a, b) => b.points.compareTo(a.points));
  }

  Future<void> _saveScales() async {
    final json = _scales.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList(_key, json);
    notifyListeners();
  }

  void setLocked(bool locked) {
    _isLocked = locked;
    notifyListeners();
  }

  Future<void> toggleLock() async {
    _isLocked = !_isLocked;
    notifyListeners();
  }

  Future<void> addScale(String grade, double points) async {
    if (_isLocked) return;
    _scales.add(GradeScale(grade: grade, points: points));
    _scales.sort((a, b) => b.points.compareTo(a.points));
    await _saveScales();
  }

  Future<void> removeScale(GradeScale scale) async {
    if (_isLocked) return;
    _scales.removeWhere((s) => s.grade == scale.grade);
    await _saveScales();
  }

  Future<void> updateScale(
      GradeScale oldScale, String newGrade, double newPoints) async {
    if (_isLocked) return;
    final index = _scales.indexWhere((s) => s.grade == oldScale.grade);
    if (index != -1) {
      _scales[index] = GradeScale(grade: newGrade, points: newPoints);
      _scales.sort((a, b) => b.points.compareTo(a.points));
      await _saveScales();
    }
  }
}
