import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/syllabus.dart';
import '../models/formula.dart';
import '../providers/formula_provider.dart';
import '../widgets/formula_tile.dart';

class SubjectListScreen extends StatefulWidget {
  final String title;
  final Color color;

  const SubjectListScreen({
    super.key,
    required this.title,
    required this.color,
  });

  @override
  State<SubjectListScreen> createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends State<SubjectListScreen> {
  final Set<String> _expanded = {};

  String get title => widget.title;
  Color get color => widget.color;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FormulaProvider>();
    final topicsMap = provider.getTopicsForSubject(title);
    final highOnly = provider.highYieldOnly;

    var topics = orderedTopics(title, topicsMap.keys);
    if (highOnly) {
      topics = topics
          .where((t) =>
              provider.metadata.weightageFor(title, t) == WeightageTier.high)
          .toList();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context, provider, highOnly),
          if (topics.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No high-yield chapters here.\nTurn off the filter to see all chapters.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 50),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final name = topics[index];
                    final formulas = topicsMap[name]!;
                    return _ChapterCard(
                      name: name,
                      formulas: formulas,
                      color: color,
                      index: index,
                      cls: classOf(title, name),
                      high: provider.metadata.weightageFor(title, name) ==
                          WeightageTier.high,
                      revised: provider.revisedCountIn(formulas),
                      expanded: _expanded.contains(name),
                      onToggle: () => setState(() {
                        if (!_expanded.remove(name)) _expanded.add(name);
                      }),
                    );
                  },
                  childCount: topics.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(
      BuildContext context, FormulaProvider provider, bool highOnly) {
    return SliverAppBar(
      backgroundColor: AppColors.background,
      expandedHeight: 120,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          tooltip: highOnly ? 'Showing high-yield only' : 'Show high-yield only',
          icon: Icon(
            Icons.local_fire_department,
            color: highOnly ? const Color(0xFFEF4444) : Colors.white54,
          ),
          onPressed: () => provider.setHighYieldOnly(!highOnly),
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          title,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color.withOpacity(0.2), AppColors.background],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  final String name;
  final List<Formula> formulas;
  final Color color;
  final int index;
  final String? cls;
  final bool high;
  final int revised;
  final bool expanded;
  final VoidCallback onToggle;

  const _ChapterCard({
    required this.name,
    required this.formulas,
    required this.color,
    required this.index,
    required this.cls,
    required this.high,
    required this.revised,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final total = formulas.length;
    final allRevised = revised >= total && total > 0;
    final card = Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: expanded ? color.withOpacity(0.4) : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
              child: Row(
                children: [
                  Container(width: 4, height: 38, color: color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                              ),
                            ),
                            if (high) ...[
                              const SizedBox(width: 8),
                              const HighYieldBadge(),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (cls != null)
                              Text('Class $cls  •  ',
                                  style: const TextStyle(
                                      color: AppColors.textFaint, fontSize: 12)),
                            Text('$total formulas',
                                style: const TextStyle(
                                    color: AppColors.textMuted, fontSize: 12)),
                            if (revised > 0) ...[
                              const Text('  •  ',
                                  style: TextStyle(
                                      color: AppColors.textFaint, fontSize: 12)),
                              Text(
                                allRevised ? 'all revised' : '$revised revised',
                                style: TextStyle(
                                    color: allRevised
                                        ? AppColors.biology
                                        : AppColors.textMuted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
          if (revised > 0 && !allRevised)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: total == 0 ? 0 : revised / total,
                  minHeight: 3,
                  backgroundColor: Colors.white.withOpacity(0.06),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
              child: Column(
                children: formulas.map((f) => FormulaTile(formula: f)).toList(),
              ),
            ),
        ],
      ),
    );

    // Only animate the first screenful to keep scrolling snappy with many chapters.
    if (index < 12) {
      return card.animate().fadeIn(delay: (40 * index).ms).slideX(begin: 0.04);
    }
    return card;
  }
}
