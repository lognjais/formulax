import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:share_plus/share_plus.dart';
import '../core/inline_math_parser.dart';
import '../models/formula.dart';
import '../providers/formula_provider.dart';
import '../services/analytics_service.dart';

class FormulaDetailScreen extends StatefulWidget {
  final Formula formula;

  const FormulaDetailScreen({super.key, required this.formula});

  @override
  State<FormulaDetailScreen> createState() => _FormulaDetailScreenState();
}

class _FormulaDetailScreenState extends State<FormulaDetailScreen> {
  Formula get formula => widget.formula;

  @override
  void initState() {
    super.initState();
    AnalyticsService.logFormulaViewed(
      id: formula.id,
      subject: formula.subject,
      topic: formula.topic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FormulaProvider>();
    final isBookmarked = provider.isBookmarked(formula.id);
    final mnemonic = provider.metadata.mnemonicFor(formula);
    final weightage =
        provider.metadata.weightageFor(formula.subject, formula.topic);

    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1120),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white70),
            onPressed: () => Share.share(
                "Check this formula: ${formula.title} - ${formula.latex}"),
          ),
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? const Color(0xFF38BDF8) : Colors.white70,
            ),
            onPressed: () =>
                context.read<FormulaProvider>().toggleBookmark(formula.id),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text(
                    formula.topic.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF94A3B8)),
                  ),
                ),
                if (weightage != WeightageTier.unknown)
                  _WeightageChip(tier: weightage),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              formula.title,
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.1),
            ),
            const SizedBox(height: 40),
            _buildVisualContent(context),
            const SizedBox(height: 48),
            _buildSectionHeader(
                Icons.auto_awesome, "INSIGHT", const Color(0xFFFFD700)),
            const SizedBox(height: 16),
            _renderRichText(formula.description,
                textColor: const Color(0xFFCBD5E1),
                mathColor: const Color(0xFF38BDF8)),
            const SizedBox(height: 40),
            if (mnemonic != null) ...[
              _MnemonicCard(mnemonic: mnemonic),
              const SizedBox(height: 40),
            ],
            if (formula.relatedConcepts.isNotEmpty) ...[
              _buildSectionHeader(
                  Icons.hub, "KEY CONCEPTS", const Color(0xFFC084FC)),
              const SizedBox(height: 16),
              _buildRelatedConceptsList(),
              const SizedBox(height: 40),
            ],
            if (formula.derivation != null &&
                formula.derivation!.isNotEmpty) ...[
              _buildDerivationSection(),
              const SizedBox(height: 50),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Text(title,
            style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5)),
      ],
    );
  }

  Widget _buildRelatedConceptsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: formula.relatedConcepts.length,
      separatorBuilder: (ctx, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final concept = formula.relatedConcepts[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                concept.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              _renderRichText(
                concept.definition,
                textColor: const Color(0xFF94A3B8),
                mathColor: const Color(0xFF38BDF8),
                fontSize: 14,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDerivationSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.3)),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          collapsedIconColor: Colors.white70,
          iconColor: const Color(0xFF38BDF8),
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: const Row(
            children: [
              Icon(Icons.calculate_outlined,
                  color: Color(0xFF38BDF8), size: 20),
              SizedBox(width: 12),
              Text(
                "View Derivation",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF232D3F),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: _renderDerivationContent(formula.derivation!),
            )
          ],
        ),
      ),
    );
  }

  Widget _renderDerivationContent(String derivation) {
    List<String> steps = derivation.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: steps.map((step) {
        if (step.trim().isEmpty) return const SizedBox(height: 12);

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 6.0, right: 12.0),
                child: Icon(Icons.circle, size: 6, color: Colors.white30),
              ),
              Expanded(
                child: _renderRichText(
                  step,
                  fontSize: 16,
                  textColor: Colors.white.withOpacity(0.9),
                  mathColor: const Color(0xFF7DD3FC),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVisualContent(BuildContext context) {
    if (formula.visualData.isEmpty) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16)),
        child: const Center(
            child: Text("No visual data available",
                style: TextStyle(color: Colors.grey))),
      );
    }

    if (formula.visualType == 'svg') {
      return Hero(
        tag: 'visual_${formula.id}',
        child: Container(
          width: double.infinity,
          height: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF10B981), width: 2),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10)),
            ],
          ),
          child: SvgPicture.string(
            formula.visualData,
            fit: BoxFit.contain,
            placeholderBuilder: (context) => const Center(
                child: CircularProgressIndicator(color: Color(0xFF10B981))),
          ),
        ),
      );
    }

    String latexData = formula.visualData;

    if (latexData.contains(r'\\') && !latexData.contains(r'\begin')) {
      latexData = r'\begin{array}{l}' + latexData + r'\end{array}';
    }

    return Hero(
      tag: 'math_${formula.id}',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: const Color(0xFF38BDF8).withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF38BDF8).withOpacity(0.1),
                blurRadius: 40,
                offset: const Offset(0, 10)),
          ],
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Math.tex(
              latexData,
              textStyle: const TextStyle(fontSize: 20, color: Colors.white),
              onErrorFallback: (err) {
                String errorMessage = "Unknown Error";
                try {
                  errorMessage = (err as dynamic).message;
                } catch (e) {
                  errorMessage = err.toString();
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(height: 8),
                    Text("LaTeX Error:",
                        style: const TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold)),
                    Text(errorMessage,
                        style: const TextStyle(
                            color: Colors.redAccent, fontSize: 12),
                        textAlign: TextAlign.center),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _renderRichText(String text,
      {required Color textColor,
      required Color mathColor,
      double fontSize = 18}) {
    final segments = InlineMathParser.parse(text);
    final List<Widget> spans = segments.map((seg) {
      if (seg.isMath) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Math.tex(
            seg.content,
            textStyle: TextStyle(fontSize: fontSize, color: mathColor),
            onErrorFallback: (err) => Text("Error",
                style: TextStyle(color: Colors.red, fontSize: fontSize)),
          ),
        );
      }
      return Text(
        seg.content,
        style: TextStyle(fontSize: fontSize, height: 1.6, color: textColor),
      );
    }).toList();

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: spans,
    );
  }
}

class _WeightageChip extends StatelessWidget {
  final WeightageTier tier;
  const _WeightageChip({required this.tier});

  @override
  Widget build(BuildContext context) {
    final (label, icon, color) = switch (tier) {
      WeightageTier.high => ("HIGH YIELD", Icons.local_fire_department,
          const Color(0xFFEF4444)),
      WeightageTier.medium =>
        ("MEDIUM YIELD", Icons.flash_on, const Color(0xFFF59E0B)),
      WeightageTier.low =>
        ("LOW YIELD", Icons.remove_circle_outline, const Color(0xFF64748B)),
      WeightageTier.unknown =>
        ("", Icons.help_outline, const Color(0xFF64748B)),
    };
    if (tier == WeightageTier.unknown) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MnemonicCard extends StatelessWidget {
  final Mnemonic mnemonic;
  const _MnemonicCard({required this.mnemonic});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700).withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.lightbulb, color: Color(0xFFFFD700), size: 18),
              SizedBox(width: 10),
              Text(
                "MEMORY TRICK",
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            mnemonic.phrase,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            mnemonic.explanation,
            style: const TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
