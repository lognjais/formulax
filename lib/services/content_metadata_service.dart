import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/formula.dart';

/// Loads per-topic metadata: mnemonics (keyed by formula id or topic),
/// and weightage tiers (keyed by "<subject>::<topic>").
class ContentMetadataService {
  Map<String, Mnemonic> _mnemonicsByFormulaId = const {};
  Map<String, Mnemonic> _mnemonicsByTopic = const {};
  Map<String, WeightageTier> _topicWeightage = const {};

  Future<void> load() async {
    await Future.wait([_loadMnemonics(), _loadWeightage()]);
  }

  Future<void> _loadMnemonics() async {
    try {
      final raw = await rootBundle.loadString('assets/data/mnemonics.json');
      final decoded = json.decode(raw) as Map<String, dynamic>;
      _mnemonicsByFormulaId = ((decoded['by_formula_id'] as Map?) ?? {})
          .map((k, v) =>
              MapEntry(k as String, Mnemonic.fromJson(v as Map<String, dynamic>)));
      _mnemonicsByTopic = ((decoded['by_topic'] as Map?) ?? {})
          .map((k, v) =>
              MapEntry(k as String, Mnemonic.fromJson(v as Map<String, dynamic>)));
    } catch (e) {
      debugPrint("Failed to load mnemonics: $e");
    }
  }

  Future<void> _loadWeightage() async {
    try {
      final raw =
          await rootBundle.loadString('assets/data/topic_weightage.json');
      final decoded = json.decode(raw) as Map<String, dynamic>;
      _topicWeightage = decoded.map(
        (k, v) => MapEntry(k, weightageFromString(v as String?)),
      );
    } catch (e) {
      debugPrint("Failed to load weightage: $e");
    }
  }

  Mnemonic? mnemonicFor(Formula f) {
    if (f.mnemonic != null) return f.mnemonic;
    final byId = _mnemonicsByFormulaId[f.id];
    if (byId != null) return byId;
    return _mnemonicsByTopic['${f.subject}::${f.topic}'];
  }

  WeightageTier weightageFor(String subject, String topic) {
    return _topicWeightage['$subject::$topic'] ?? WeightageTier.unknown;
  }
}
