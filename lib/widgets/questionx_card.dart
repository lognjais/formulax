import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_colors.dart';
import '../services/analytics_service.dart';

/// Cross-promo for the sibling app Question X (PYQ practice). Free revision here
/// is the funnel; practice/tests live in Question X. Tapping opens its Play
/// listing (installed users see "Open"). Kept low in the home scroll so it never
/// competes with the core revision flow.
class QuestionXCard extends StatelessWidget {
  const QuestionXCard({super.key});

  static const _package = 'com.northmountain.questionx';
  static const _color = Color(0xFF10B981); // distinct "practice" green

  Future<void> _open() async {
    AnalyticsService.logCrossPromoTap('questionx');
    final market = Uri.parse('market://details?id=$_package');
    final web =
        Uri.parse('https://play.google.com/store/apps/details?id=$_package');
    try {
      if (await canLaunchUrl(market)) {
        await launchUrl(market, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(web, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      try {
        await launchUrl(web, mode: LaunchMode.externalApplication);
      } catch (_) {/* offline / no browser — silently ignore */}
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _open,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_color.withOpacity(0.18), AppColors.surface],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _color.withOpacity(0.30)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.quiz_outlined, color: _color),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Padhai CBT Practice',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      SizedBox(width: 6),
                      Icon(Icons.open_in_new, color: AppColors.textMuted, size: 14),
                    ],
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Done revising? Practice real NEET & JEE past year questions on Padhai.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
