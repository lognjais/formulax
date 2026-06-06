import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../models/formula.dart';
import '../providers/formula_provider.dart';
import '../screens/formula_detail_screen.dart';

/// Shared formula row: shows a revised check, the title, and opens the detail
/// screen. Used by the (collapsible) subject screen and the chapter screen.
class FormulaTile extends StatelessWidget {
  final Formula formula;
  const FormulaTile({super.key, required this.formula});

  @override
  Widget build(BuildContext context) {
    final revised =
        context.select<FormulaProvider, bool>((p) => p.isRevised(formula.id));
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        leading: Icon(
          revised ? Icons.check_circle : Icons.circle_outlined,
          color: revised ? AppColors.biology : AppColors.textFaint,
          size: 20,
        ),
        title: Text(
          formula.title,
          style: TextStyle(
            color: revised ? AppColors.textMuted : Colors.white,
            fontWeight: FontWeight.w600,
            decoration: revised ? TextDecoration.lineThrough : null,
            decorationColor: AppColors.textFaint,
          ),
        ),
        trailing:
            const Icon(Icons.chevron_right, color: AppColors.textFaint, size: 18),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FormulaDetailScreen(formula: formula)),
        ),
      ),
    );
  }
}

/// Small "high yield" flame badge for chapter headers/rows.
class HighYieldBadge extends StatelessWidget {
  const HighYieldBadge({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.4)),
      ),
      child: const Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.local_fire_department, size: 11, color: Color(0xFFEF4444)),
        SizedBox(width: 3),
        Text('HIGH',
            style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEF4444),
                letterSpacing: 0.5)),
      ]),
    );
  }
}
