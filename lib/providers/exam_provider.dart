import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/analytics_service.dart';

enum ExamMode { neet, jee, both }

class ExamProvider with ChangeNotifier {
  static const String _key = 'exam_mode';

  ExamMode? _mode;
  bool _isLoaded = false;

  ExamMode? get mode => _mode;
  bool get isLoaded => _isLoaded;
  bool get hasChosen => _mode != null;

  ExamProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    if (stored != null) {
      _mode = ExamMode.values.firstWhere(
        (e) => e.name == stored,
        orElse: () => ExamMode.both,
      );
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setMode(ExamMode mode) async {
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
    unawaited(AnalyticsService.logExamModeSelected(mode.name));
  }

  List<String> get visibleSubjects {
    switch (_mode) {
      case ExamMode.neet:
        return const ['Physics', 'Chemistry', 'Biology'];
      case ExamMode.jee:
        return const ['Physics', 'Chemistry', 'Math'];
      case ExamMode.both:
      case null:
        return const ['Physics', 'Math', 'Chemistry', 'Biology'];
    }
  }
}
