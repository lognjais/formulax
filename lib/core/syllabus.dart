/// Canonical NEET / JEE (Main) syllabus order. Chapter names match the `topic`
/// strings in the data exactly. Used to order chapters everywhere and to power
/// the Syllabus browser. Any data topic not listed here sorts to the end.
class SyllabusChapter {
  final String name;
  final String cls; // '11' or '12'
  const SyllabusChapter(this.name, this.cls);
}

const Map<String, List<SyllabusChapter>> kSyllabus = {
  'Physics': [
    SyllabusChapter('Units, Dimensions & Errors', '11'),
    SyllabusChapter('Kinematics', '11'),
    SyllabusChapter('Laws of Motion & Friction', '11'),
    SyllabusChapter('Work, Energy & Power', '11'),
    SyllabusChapter('Centre of Mass & Collisions', '11'),
    SyllabusChapter('Rotational Motion', '11'),
    SyllabusChapter('Gravitation', '11'),
    SyllabusChapter('Elasticity', '11'),
    SyllabusChapter('Mechanical Properties of Fluids', '11'),
    SyllabusChapter('Thermal Properties of Matter', '11'),
    SyllabusChapter('Kinetic Theory of Gases', '11'),
    SyllabusChapter('Thermodynamics', '11'),
    SyllabusChapter('Oscillations (SHM)', '11'),
    SyllabusChapter('Waves & Sound', '11'),
    SyllabusChapter('Electrostatics', '12'),
    SyllabusChapter('Capacitance', '12'),
    SyllabusChapter('Current Electricity', '12'),
    SyllabusChapter('Moving Charges & Magnetism', '12'),
    SyllabusChapter('Magnetism & Matter', '12'),
    SyllabusChapter('Electromagnetic Induction', '12'),
    SyllabusChapter('Alternating Current', '12'),
    SyllabusChapter('Electromagnetic Waves', '12'),
    SyllabusChapter('Ray Optics & Optical Instruments', '12'),
    SyllabusChapter('Wave Optics', '12'),
    SyllabusChapter('Dual Nature of Radiation & Matter', '12'),
    SyllabusChapter('Atoms & Bohr Model', '12'),
    SyllabusChapter('Nuclei', '12'),
    SyllabusChapter('Semiconductor Electronics', '12'),
    SyllabusChapter('Communication Systems', '12'),
    SyllabusChapter('Experimental Skills', '12'),
  ],
  'Chemistry': [
    SyllabusChapter('Mole Concept & Stoichiometry', '11'),
    SyllabusChapter('Structure of Atom', '11'),
    SyllabusChapter('Periodicity & Periodic Properties', '11'),
    SyllabusChapter('Chemical Bonding', '11'),
    SyllabusChapter('States of Matter: Gases', '11'),
    SyllabusChapter('Chemical Thermodynamics', '11'),
    SyllabusChapter('Chemical Equilibrium', '11'),
    SyllabusChapter('Ionic Equilibrium', '11'),
    SyllabusChapter('Redox Reactions', '11'),
    SyllabusChapter('s-Block Elements', '11'),
    SyllabusChapter('p-Block Elements', '11'),
    SyllabusChapter('Organic Chemistry: Basic Principles (GOC)', '11'),
    SyllabusChapter('Hydrocarbons', '11'),
    SyllabusChapter('Environmental Chemistry', '11'),
    SyllabusChapter('Solid State', '12'),
    SyllabusChapter('Solutions', '12'),
    SyllabusChapter('Electrochemistry', '12'),
    SyllabusChapter('Chemical Kinetics', '12'),
    SyllabusChapter('Surface Chemistry', '12'),
    SyllabusChapter('Metallurgy', '12'),
    SyllabusChapter('d- & f-Block Elements', '12'),
    SyllabusChapter('Coordination Compounds', '12'),
    SyllabusChapter('Haloalkanes & Haloarenes', '12'),
    SyllabusChapter('Alcohols, Phenols & Ethers', '12'),
    SyllabusChapter('Aldehydes, Ketones & Carboxylic Acids', '12'),
    SyllabusChapter('Amines & Diazonium Salts', '12'),
    SyllabusChapter('Biomolecules', '12'),
    SyllabusChapter('Polymers', '12'),
    SyllabusChapter('Chemistry in Everyday Life', '12'),
    SyllabusChapter('Nuclear Chemistry', '12'),
    SyllabusChapter('Salt Analysis & Qualitative Tests', '12'),
  ],
  'Math': [
    SyllabusChapter('Sets, Relations & Functions', '11'),
    SyllabusChapter('Trigonometric Ratios & Identities', '11'),
    SyllabusChapter('Solution of Triangles & Heights/Distances', '11'),
    SyllabusChapter('Complex Numbers', '11'),
    SyllabusChapter('Quadratic Equations', '11'),
    SyllabusChapter('Permutations & Combinations', '11'),
    SyllabusChapter('Binomial Theorem', '11'),
    SyllabusChapter('Sequences & Series', '11'),
    SyllabusChapter('Straight Lines', '11'),
    SyllabusChapter('Pair of Straight Lines', '11'),
    SyllabusChapter('Circles', '11'),
    SyllabusChapter('Parabola', '11'),
    SyllabusChapter('Ellipse', '11'),
    SyllabusChapter('Hyperbola', '11'),
    SyllabusChapter('Limits', '11'),
    SyllabusChapter('Mathematical Induction & Logarithms', '11'),
    SyllabusChapter('Statistics', '11'),
    SyllabusChapter('Mathematical Reasoning', '11'),
    SyllabusChapter('Inverse Trigonometric Functions', '12'),
    SyllabusChapter('Matrices', '12'),
    SyllabusChapter('Determinants', '12'),
    SyllabusChapter('Continuity & Differentiability', '12'),
    SyllabusChapter('Applications of Derivatives', '12'),
    SyllabusChapter('Indefinite Integration', '12'),
    SyllabusChapter('Definite Integration & Areas', '12'),
    SyllabusChapter('Differential Equations', '12'),
    SyllabusChapter('Vector Algebra', '12'),
    SyllabusChapter('3D Geometry', '12'),
    SyllabusChapter('Probability', '12'),
    SyllabusChapter('Linear Programming', '12'),
  ],
  'Biology': [
    SyllabusChapter('The Living World', '11'),
    SyllabusChapter('Biological Classification', '11'),
    SyllabusChapter('Plant Kingdom', '11'),
    SyllabusChapter('Animal Kingdom', '11'),
    SyllabusChapter('Morphology of Flowering Plants', '11'),
    SyllabusChapter('Anatomy of Flowering Plants', '11'),
    SyllabusChapter('Structural Organisation in Animals', '11'),
    SyllabusChapter('Cell: The Unit of Life', '11'),
    SyllabusChapter('Biomolecules', '11'),
    SyllabusChapter('Cell Cycle & Cell Division', '11'),
    SyllabusChapter('Transport in Plants', '11'),
    SyllabusChapter('Mineral Nutrition', '11'),
    SyllabusChapter('Photosynthesis in Higher Plants', '11'),
    SyllabusChapter('Respiration in Plants', '11'),
    SyllabusChapter('Plant Growth & Development', '11'),
    SyllabusChapter('Digestion & Absorption', '11'),
    SyllabusChapter('Breathing & Exchange of Gases', '11'),
    SyllabusChapter('Body Fluids & Circulation', '11'),
    SyllabusChapter('Excretory Products & Elimination', '11'),
    SyllabusChapter('Locomotion & Movement', '11'),
    SyllabusChapter('Neural Control & Coordination', '11'),
    SyllabusChapter('Chemical Coordination & Integration', '11'),
    SyllabusChapter('Sexual Reproduction in Flowering Plants', '12'),
    SyllabusChapter('Human Reproduction', '12'),
    SyllabusChapter('Reproductive Health', '12'),
    SyllabusChapter('Principles of Inheritance & Variation', '12'),
    SyllabusChapter('Molecular Basis of Inheritance', '12'),
    SyllabusChapter('Evolution', '12'),
    SyllabusChapter('Human Health & Disease', '12'),
    SyllabusChapter('Microbes in Human Welfare', '12'),
    SyllabusChapter('Biotechnology: Principles & Processes', '12'),
    SyllabusChapter('Biotechnology & its Applications', '12'),
    SyllabusChapter('Organisms & Populations', '12'),
    SyllabusChapter('Ecosystem', '12'),
    SyllabusChapter('Biodiversity & Conservation', '12'),
    SyllabusChapter('Environmental Issues', '12'),
    SyllabusChapter('Strategies for Enhancement in Food Production', '12'),
  ],
};

/// Orders `available` topics by canonical syllabus order; unknown topics go last (alphabetical).
List<String> orderedTopics(String subject, Iterable<String> available) {
  final syl = kSyllabus[subject] ?? const [];
  final order = <String, int>{for (var i = 0; i < syl.length; i++) syl[i].name: i};
  final list = available.toList();
  list.sort((a, b) {
    final ia = order[a] ?? 1 << 20;
    final ib = order[b] ?? 1 << 20;
    return ia != ib ? ia.compareTo(ib) : a.compareTo(b);
  });
  return list;
}

/// NCERT class ('11'/'12') for a chapter, or null if not in the syllabus list.
String? classOf(String subject, String chapter) {
  for (final c in kSyllabus[subject] ?? const <SyllabusChapter>[]) {
    if (c.name == chapter) return c.cls;
  }
  return null;
}
