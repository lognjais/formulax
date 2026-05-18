import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/exam_provider.dart';

class ExamSelectorSheet extends StatelessWidget {
  final bool dismissible;
  const ExamSelectorSheet({super.key, this.dismissible = true});

  static Future<void> show(BuildContext context, {bool dismissible = true}) {
    return showModalBottomSheet(
      context: context,
      isDismissible: dismissible,
      enableDrag: dismissible,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ExamSelectorSheet(dismissible: dismissible),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = context.watch<ExamProvider>().mode;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Which exam are you preparing for?",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "We'll tailor your formula list. You can change this anytime.",
              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 24),
            _ExamOption(
              label: "NEET",
              subtitle: "Physics + Chemistry + Biology",
              selected: current == ExamMode.neet,
              onTap: () => _select(context, ExamMode.neet),
            ),
            const SizedBox(height: 12),
            _ExamOption(
              label: "JEE",
              subtitle: "Physics + Chemistry + Math",
              selected: current == ExamMode.jee,
              onTap: () => _select(context, ExamMode.jee),
            ),
            const SizedBox(height: 12),
            _ExamOption(
              label: "Both / Show everything",
              subtitle: "All four subjects",
              selected: current == ExamMode.both,
              onTap: () => _select(context, ExamMode.both),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _select(BuildContext context, ExamMode mode) async {
    await context.read<ExamProvider>().setMode(mode);
    if (context.mounted) Navigator.pop(context);
  }
}

class _ExamOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ExamOption({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.accent.withOpacity(0.15)
          : AppColors.surfaceAlt,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.accent : Colors.white10,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 13)),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: selected ? AppColors.accent : Colors.white24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
