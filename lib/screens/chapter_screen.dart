import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/formula_provider.dart';
import '../widgets/formula_tile.dart';

/// A single chapter's formulas — the direct-navigation target from the Syllabus
/// browser ("open a topic and go straight to its formulas").
class ChapterScreen extends StatelessWidget {
  final String subject;
  final String topic;
  final Color color;
  const ChapterScreen({
    super.key,
    required this.subject,
    required this.topic,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FormulaProvider>();
    final formulas = provider.getTopicsForSubject(subject)[topic] ?? const [];
    final revised = provider.revisedCountIn(formulas);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(topic,
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 3, color: color),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Row(
              children: [
                Text('${formulas.length} formulas',
                    style:
                        const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                const Spacer(),
                if (revised > 0)
                  Text('$revised / ${formulas.length} revised',
                      style: TextStyle(
                          color: color,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
              itemCount: formulas.length,
              itemBuilder: (_, i) => FormulaTile(formula: formulas[i]),
            ),
          ),
        ],
      ),
    );
  }
}
