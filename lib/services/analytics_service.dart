import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  AnalyticsService._();

  static bool get _firebaseReady => Firebase.apps.isNotEmpty;

  static Future<void> _log(
    String name, [
    Map<String, Object?>? params,
  ]) async {
    if (!_firebaseReady) return;
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: name,
        parameters: params?.cast<String, Object>(),
      );
    } catch (e) {
      debugPrint("Analytics log failed for $name: $e");
    }
  }

  static Future<void> logExamModeSelected(String mode) =>
      _log('exam_mode_selected', {'mode': mode});

  static Future<void> logFormulaViewed({
    required String id,
    required String subject,
    required String topic,
  }) =>
      _log('formula_viewed', {
        'formula_id': id,
        'subject': subject,
        'topic': topic,
      });

  static Future<void> logSearch(String query, int resultCount) =>
      _log('search', {
        'search_term': query,
        'result_count': resultCount,
      });

  static Future<void> logBookmarkToggled(String id, bool added) =>
      _log(added ? 'bookmark_added' : 'bookmark_removed', {'formula_id': id});

  static void recordError(Object error, StackTrace stack, {String? reason}) {
    if (kDebugMode || !_firebaseReady) return;
    FirebaseCrashlytics.instance
        .recordError(error, stack, reason: reason, fatal: false);
  }
}
