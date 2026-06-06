import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Single source of truth for per-subject color + icon (used by home, syllabus,
/// chapter and subject screens).
class SubjectMeta {
  final Color color;
  final IconData icon;
  const SubjectMeta(this.color, this.icon);
}

const Map<String, SubjectMeta> kSubjectMeta = {
  'Physics': SubjectMeta(AppColors.physics, Icons.bolt),
  'Math': SubjectMeta(AppColors.math, Icons.functions),
  'Chemistry': SubjectMeta(AppColors.chemistry, Icons.science_outlined),
  'Biology': SubjectMeta(AppColors.biology, Icons.spa),
};

Color subjectColor(String name) => kSubjectMeta[name]?.color ?? AppColors.accent;
IconData subjectIcon(String name) => kSubjectMeta[name]?.icon ?? Icons.menu_book_outlined;
