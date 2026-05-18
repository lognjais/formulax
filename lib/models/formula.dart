class FormulaConcept {
  final String name;
  final String definition;

  FormulaConcept({required this.name, required this.definition});

  factory FormulaConcept.fromJson(Map<String, dynamic> json) {
    return FormulaConcept(
      name: json['name'] ?? '',
      definition: json['definition'] ?? '',
    );
  }
}

enum WeightageTier { high, medium, low, unknown }

WeightageTier weightageFromString(String? raw) {
  switch (raw?.toLowerCase()) {
    case 'high':
      return WeightageTier.high;
    case 'medium':
    case 'med':
      return WeightageTier.medium;
    case 'low':
      return WeightageTier.low;
    default:
      return WeightageTier.unknown;
  }
}

class Mnemonic {
  final String phrase;
  final String explanation;
  const Mnemonic({required this.phrase, required this.explanation});

  factory Mnemonic.fromJson(Map<String, dynamic> json) {
    return Mnemonic(
      phrase: json['phrase'] ?? '',
      explanation: json['explanation'] ?? '',
    );
  }
}

class Formula {
  final String id;
  final String subject;
  final String topic;
  final String title;
  final String description;
  final String? imagePath;
  final String visualType;
  final String visualData;

  final String? derivation;
  final List<FormulaConcept> relatedConcepts;
  final Mnemonic? mnemonic;

  Formula({
    required this.id,
    required this.subject,
    required this.topic,
    required this.title,
    required this.description,
    this.imagePath,
    required this.visualType,
    required this.visualData,
    this.derivation,
    required this.relatedConcepts,
    this.mnemonic,
  });

  factory Formula.fromJson(Map<String, dynamic> json) {
    final mnemonicJson = json['mnemonic'];
    return Formula(
      id: json['id'] ?? '',
      subject: json['subject'] ?? '',
      topic: json['topic'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imagePath: json['image_path'],
      visualType: json['visual_type'] ?? 'latex',
      visualData: json['visual_data'] ?? json['latex'] ?? '',
      derivation: json['derivation'],
      relatedConcepts: (json['related_concepts'] as List<dynamic>?)
              ?.map((e) => FormulaConcept.fromJson(e))
              .toList() ??
          [],
      mnemonic: mnemonicJson is Map<String, dynamic>
          ? Mnemonic.fromJson(mnemonicJson)
          : null,
    );
  }

  String get latex => visualData;
}
