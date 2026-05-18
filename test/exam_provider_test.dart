import 'package:flutter_test/flutter_test.dart';
import 'package:formulax/providers/exam_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ExamProvider.visibleSubjects', () {
    test('NEET shows Physics, Chemistry, Biology — no Math', () async {
      SharedPreferences.setMockInitialValues({'exam_mode': 'neet'});
      final provider = ExamProvider();
      await Future.delayed(Duration.zero);
      expect(provider.visibleSubjects, ['Physics', 'Chemistry', 'Biology']);
    });

    test('JEE shows Physics, Chemistry, Math — no Biology', () async {
      SharedPreferences.setMockInitialValues({'exam_mode': 'jee'});
      final provider = ExamProvider();
      await Future.delayed(Duration.zero);
      expect(provider.visibleSubjects, ['Physics', 'Chemistry', 'Math']);
    });

    test('Both shows all four subjects', () async {
      SharedPreferences.setMockInitialValues({'exam_mode': 'both'});
      final provider = ExamProvider();
      await Future.delayed(Duration.zero);
      expect(provider.visibleSubjects,
          ['Physics', 'Math', 'Chemistry', 'Biology']);
    });

    test('Unselected (null) defaults to all four', () async {
      final provider = ExamProvider();
      await Future.delayed(Duration.zero);
      expect(provider.hasChosen, isFalse);
      expect(provider.visibleSubjects,
          ['Physics', 'Math', 'Chemistry', 'Biology']);
    });

    test('setMode persists and updates visibleSubjects', () async {
      final provider = ExamProvider();
      await Future.delayed(Duration.zero);

      await provider.setMode(ExamMode.neet);
      expect(provider.mode, ExamMode.neet);
      expect(provider.visibleSubjects.contains('Math'), isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('exam_mode'), 'neet');
    });
  });
}
