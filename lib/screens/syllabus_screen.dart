import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/subjects.dart';
import '../core/syllabus.dart';
import '../models/formula.dart';
import '../providers/exam_provider.dart';
import '../providers/formula_provider.dart';
import 'chapter_screen.dart';

/// Standard NEET / JEE(Main) syllabus in canonical order, grouped by class.
/// Tap any chapter to jump straight to its formulas.
class SyllabusScreen extends StatelessWidget {
  const SyllabusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FormulaProvider>();
    final exam = context.watch<ExamProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text('Syllabus',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 50),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 4, 4, 8),
            child: Text(
              'Standard NEET / JEE syllabus in order — tap a chapter to open its formulas.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ),
          for (final subject in exam.visibleSubjects)
            ..._subjectSection(context, provider, subject),
        ],
      ),
    );
  }

  List<Widget> _subjectSection(
      BuildContext context, FormulaProvider provider, String subject) {
    final topicsMap = provider.getTopicsForSubject(subject);
    if (topicsMap.isEmpty) return const [];
    final color = subjectColor(subject);

    final out = <Widget>[
      Padding(
        padding: const EdgeInsets.fromLTRB(2, 22, 2, 4),
        child: Row(children: [
          Icon(subjectIcon(subject), color: color, size: 20),
          const SizedBox(width: 10),
          Text(subject.toUpperCase(),
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: 1.0)),
        ]),
      ),
    ];

    void addRows(String label, Iterable<String> chapters) {
      final list = chapters.where(topicsMap.containsKey).toList();
      if (list.isEmpty) return;
      out.add(Padding(
        padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
        child: Text(label,
            style: const TextStyle(
                color: AppColors.textFaint,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2)),
      ));
      for (final name in list) {
        final formulas = topicsMap[name]!;
        out.add(_ChapterRow(
          color: color,
          title: name,
          count: formulas.length,
          high: provider.metadata.weightageFor(subject, name) ==
              WeightageTier.high,
          revised: provider.revisedCountIn(formulas),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    ChapterScreen(subject: subject, topic: name, color: color)),
          ),
        ));
      }
    }

    final syl = kSyllabus[subject] ?? const <SyllabusChapter>[];
    addRows('CLASS 11', syl.where((c) => c.cls == '11').map((c) => c.name));
    addRows('CLASS 12', syl.where((c) => c.cls == '12').map((c) => c.name));
    // Any data chapters not in the canonical list.
    final listed = syl.map((c) => c.name).toSet();
    addRows('OTHER', topicsMap.keys.where((t) => !listed.contains(t)).toList()..sort());

    return out;
  }
}

class _ChapterRow extends StatelessWidget {
  final Color color;
  final String title;
  final int count;
  final bool high;
  final int revised;
  final VoidCallback onTap;
  const _ChapterRow({
    required this.color,
    required this.title,
    required this.count,
    required this.high,
    required this.revised,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final allRevised = revised >= count && count > 0;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(width: 4, height: 36, color: color),
        title: Text(title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(children: [
            Text('$count formulas',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            if (revised > 0) ...[
              const Text('  •  ',
                  style: TextStyle(color: AppColors.textFaint, fontSize: 12)),
              Text(allRevised ? 'all revised' : '$revised revised',
                  style: TextStyle(
                      color: allRevised ? AppColors.biology : AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ]),
        ),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          if (high) const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.local_fire_department,
                size: 16, color: Color(0xFFEF4444)),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textFaint, size: 18),
        ]),
      ),
    );
  }
}
