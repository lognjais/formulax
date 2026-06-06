# Changelog

## v1.1.0+5 (2026-06)
Largest content + correctness release. Driven by JEE-aspirant reviewer feedback.

### Content — 1,222 → 3,518 formulas (+2,358 verified)
Every new formula passed an adversarial 3-verifier correctness gate (default-reject) and a
render-validation gate; each carries a variable legend and an authoritative source citation
(NCERT Class 11/12 + standard JEE/NEET references). Per subject:
- Physics  311 → 906
- Chemistry 353 → 1160
- Maths    294 → 854
- Biology  264 → 598

### ★ Reviewer-flagged chapters closed
- Chemistry · Mole Concept & Stoichiometry: 1 → 25
- Chemistry · Chemical Equilibrium: 2 → 24
- Physics · Elasticity: 1 → 20
- Physics · Thermal Properties (incl. expansion of solids/liquids/gases): → 32
- Maths · Limits: 10 → 27
- Maths · Continuity & Differentiability: → 25

### Correctness & structure
- Consolidated fragmented chapters into canonical NCERT chapters (e.g. conics split into
  Parabola/Ellipse/Hyperbola; Integration into Indefinite/Definite; merged duplicate-named topics).
- Fixed 14 Physics + 14 Maths duplicate/ID-collision cards (IDs were colliding — corrupting
  bookmarks); removed 62 duplicate cards.
- Fixed 12 pre-existing "LaTeX Error" cards that failed to render in the live app
  (\AA, gathered environment, a stray typo).

### Tests
- New `test/formula_render_test.dart` parses every shipped LaTeX string (block + inline) through
  the exact app render path; full suite green.
