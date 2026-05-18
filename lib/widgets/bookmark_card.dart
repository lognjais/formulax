import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../core/app_colors.dart';
import '../models/formula.dart';
import '../screens/formula_detail_screen.dart';

class BookmarkCard extends StatelessWidget {
  final Formula formula;
  const BookmarkCard({super.key, required this.formula});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => FormulaDetailScreen(formula: formula))),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Hero(
              tag: 'math_${formula.id}',
              child: DefaultTextStyle(
                style: const TextStyle(color: AppColors.accent, fontSize: 14),
                child: SizedBox(
                  height: 30,
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Math.tex(formula.latex,
                        textStyle: const TextStyle(
                            color: AppColors.accent, fontSize: 20)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formula.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                const SizedBox(height: 4),
                Text(formula.topic,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.textFaint, fontSize: 12)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
