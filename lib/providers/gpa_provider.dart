import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/course.dart';

class GPAProvider extends ChangeNotifier {
  List<Course> _courses = [];
  late SharedPreferences _prefs;

  List<Course> get courses => _courses;

  double get gpa {
    if (_courses.isEmpty) return 0.0;
    double totalPoints = 0.0;
    double totalCredits = 0.0;

    for (var course in _courses) {
      totalPoints += course.gradePoints * course.credits;
      totalCredits += course.credits;
    }

    return totalPoints / totalCredits;
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadCourses();
  }

  void _loadCourses() {
    final coursesJson = _prefs.getStringList('courses') ?? [];
    _courses =
        coursesJson.map((json) => Course.fromJson(jsonDecode(json))).toList();
    notifyListeners();
  }

  Future<void> addCourse(Course course) async {
    _courses.add(course);
    await _saveCourses();
    notifyListeners();
  }

  Future<void> removeCourse(Course course) async {
    _courses.removeWhere((c) => c.id == course.id);
    await _saveCourses();
    notifyListeners();
  }

  Future<void> updateCourse(Course oldCourse, Course newCourse) async {
    final index = _courses.indexWhere((c) => c.id == oldCourse.id);
    if (index != -1) {
      _courses[index] = newCourse;
      await _saveCourses();
      notifyListeners();
    }
  }

  Future<void> _saveCourses() async {
    final coursesJson =
        _courses.map((course) => jsonEncode(course.toJson())).toList();
    await _prefs.setStringList('courses', coursesJson);
  }
}
