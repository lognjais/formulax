import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../models/formula.dart';
import '../providers/exam_provider.dart';
import '../providers/formula_provider.dart';
import '../services/formula_search_service.dart';
import '../widgets/bookmark_card.dart';
import '../widgets/exam_selector_sheet.dart';
import '../widgets/formula_search_delegate.dart';
import '../widgets/subject_card.dart';
import 'syllabus_screen.dart';

const Map<String, _SubjectMeta> _subjectMeta = {
  "Physics": _SubjectMeta(AppColors.physics, Icons.bolt),
  "Math": _SubjectMeta(AppColors.math, Icons.functions),
  "Chemistry": _SubjectMeta(AppColors.chemistry, Icons.science_outlined),
  "Biology": _SubjectMeta(AppColors.biology, Icons.spa),
};

class _SubjectMeta {
  final Color color;
  final IconData icon;
  const _SubjectMeta(this.color, this.icon);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _promptedForExam = false;

  @override
  Widget build(BuildContext context) {
    final formulaProvider = context.watch<FormulaProvider>();
    final examProvider = context.watch<ExamProvider>();

    if (examProvider.isLoaded && !examProvider.hasChosen && !_promptedForExam) {
      _promptedForExam = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ExamSelectorSheet.show(context, dismissible: false);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildBody(formulaProvider, examProvider),
    );
  }

  Widget _buildBody(FormulaProvider provider, ExamProvider examProvider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }
    if (provider.hasError) {
      return _ErrorView(
        message: provider.errorMessage!,
        onRetry: provider.load,
      );
    }
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _HomeHeader(
                  examMode: examProvider.mode,
                  onTapExamChip: () => ExamSelectorSheet.show(context),
                ),
                const SizedBox(height: 32),
                _SearchBar(
                  formulas: provider.allFormulas,
                  service: provider.searchService,
                ),
                const SizedBox(height: 20),
                const _SyllabusCard(),
                const SizedBox(height: 32),
                const SectionTitle(title: "BROWSE BY SUBJECT"),
                const SizedBox(height: 16),
              ]),
            ),
          ),
          _SubjectListSliver(
            subjectNames: examProvider.visibleSubjects,
            counts: {
              for (final name in examProvider.visibleSubjects)
                name: provider.getFormulasBySubject(name).length,
            },
          ),
          if (provider.bookmarkedFormulas.isNotEmpty) ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 16),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SectionTitle(title: "QUICK ACCESS"),
                    Text(
                      "${provider.bookmarkedFormulas.length} Saved",
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.5), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 150,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  scrollDirection: Axis.horizontal,
                  itemCount: provider.bookmarkedFormulas.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    return BookmarkCard(
                            formula: provider.bookmarkedFormulas[index])
                        .animate()
                        .scale(delay: (50 * index).ms);
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final ExamMode? examMode;
  final VoidCallback onTapExamChip;

  const _HomeHeader({required this.examMode, required this.onTapExamChip});

  String get _examLabel {
    switch (examMode) {
      case ExamMode.neet:
        return "NEET";
      case ExamMode.jee:
        return "JEE";
      case ExamMode.both:
        return "NEET + JEE";
      case null:
        return "Choose exam";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Welcome back,",
                  style: TextStyle(color: AppColors.textMuted, fontSize: 15)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.accent, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.45),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.functions,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.white, AppColors.accentSoft],
                    ).createShader(bounds),
                    child: const Text(
                      "Formula X",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        InkWell(
          onTap: onTapExamChip,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.school_outlined,
                    color: AppColors.accent, size: 18),
                const SizedBox(width: 6),
                Text(_examLabel,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  final List<Formula> formulas;
  final FormulaSearchService? service;
  const _SearchBar({required this.formulas, this.service});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showSearch(
          context: context,
          delegate: FormulaSearchDelegate(formulas, service: service)),
      child: Hero(
        tag: 'searchBar',
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: AppColors.textMuted),
                const SizedBox(width: 14),
                Text("Search formulas, topics...",
                    style: TextStyle(
                        color: AppColors.textMuted.withOpacity(0.7),
                        fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SubjectListSliver extends StatelessWidget {
  final List<String> subjectNames;
  final Map<String, int> counts;

  const _SubjectListSliver({
    required this.subjectNames,
    required this.counts,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final name = subjectNames[index];
            final meta = _subjectMeta[name];
            if (meta == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SubjectCard(
                name: name,
                color: meta.color,
                icon: meta.icon,
                count: counts[name] ?? 0,
              ).animate().fadeIn(delay: (100 * index).ms).slideX(),
            );
          },
          childCount: subjectNames.length,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off,
                color: AppColors.textMuted, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SyllabusCard extends StatelessWidget {
  const _SyllabusCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SyllabusScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.secondary.withOpacity(0.18), AppColors.surface],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu_book_rounded,
                  color: AppColors.secondary),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Syllabus',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  SizedBox(height: 2),
                  Text('NEET / JEE chapters in order → jump to formulas',
                      style:
                          TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textFaint,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }
}
