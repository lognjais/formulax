import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../models/formula.dart';
import '../providers/formula_provider.dart';
import 'formula_detail_screen.dart';

class SubjectListScreen extends StatelessWidget {
  final String title;
  final Color color;

  const SubjectListScreen({
    super.key,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final topicsMap =
        context.read<FormulaProvider>().getTopicsForSubject(title);
    final topics = topicsMap.keys.toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 50),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final topicName = topics[index];
                  final formulas = topicsMap[topicName]!;
                  return _TopicGroup(
                    topicName: topicName,
                    formulas: formulas,
                    color: color,
                    index: index,
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

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.background,
      expandedHeight: 120,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          title,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
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

class _TopicGroup extends StatelessWidget {
  final String topicName;
  final List<Formula> formulas;
  final Color color;
  final int index;

  const _TopicGroup({
    required this.topicName,
    required this.formulas,
    required this.color,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          color: AppColors.background,
          child: Row(
            children: [
              Container(width: 4, height: 16, color: color),
              const SizedBox(width: 8),
              Text(
                topicName.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        ...formulas.map((f) => _FormulaTile(formula: f)),
        const SizedBox(height: 16),
      ],
    ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.05);
  }
}

class _FormulaTile extends StatelessWidget {
  final Formula formula;
  const _FormulaTile({required this.formula});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        title: Text(formula.title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right,
            color: AppColors.textFaint, size: 18),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => FormulaDetailScreen(formula: formula))),
      ),
    );
  }
}
