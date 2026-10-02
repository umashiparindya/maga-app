# Maga Agent Quick Rules

`AGENTS.md` is the authoritative rulebook. This file is the short checklist an
agent should keep visible while working.

## Before coding

1. Read `AGENTS.md`, `PROJECT_CONTRACT.md`, and the assigned step in
   `BUILD_ROADMAP.md`.
2. Inspect the current files and tests before changing anything.
3. Confirm the exact scope, allowed files, acceptance criteria, and required
   commands for the assigned step.
4. Do not start a later roadmap step early.

## Product rules

5. Build a deterministic rule-based domestic travel recommendation prototype for
   Sri Lankan youth aged 18 to 30.
6. Keep the app aligned with the approved research variables: content
   credibility, visual appeal, influencer trust, social media usage intensity,
   and travel intention.
7. Do not add AI, machine learning, LLM calls, embeddings, scraping, live
   social-media analytics, booking, payments, chat, or unrelated features.
8. Treat destination content values as research-informed ordinal proxies, never
   as verified platform analytics.
9. Do not describe usage intensity as a statistically proven moderator. It is a
   documented application design rule for adjusting content influence.
10. Do not invent data, ratings, reviews, sources, user testing, accuracy,
    usability results, or thesis claims.

## Engineering rules

11. Keep models, repositories, scoring, and explanations outside widgets.
12. Keep scoring rules centralized and pure Dart.
13. Keep identical inputs deterministic and ties stable.
14. Validate all destination data and user input.
15. Do not add a dependency without a concrete requirement.
16. Use a local repository before Firebase. Firebase is optional until the local
    flow works and the configured backend is actually tested.
17. Never commit credentials, secrets, personal survey data, or unlicensed
    images.

## Design rules

18. No default Flutter purple theme as the final identity.
19. No gradients, glassmorphism, neon colors, random color palettes, decorative
    blobs, excessive cards, pill-everything controls, or oversized AI-generated
    hero sections.
20. Use system typography unless an approved brand font exists.
21. Use real, concise copy. Do not use filler travel marketing language.
22. Use icons consistently. Do not use emojis as interface icons.
23. Prioritize hierarchy, spacing, readability, accessibility, and explanation
    clarity over novelty.

## Validation rules

24. Run the relevant tests for every step.
25. Before completion, run:

~~~bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test
flutter test integration_test
flutter build apk --debug
~~~

26. Do not report a command as passing unless it was run.
27. Record screenshots and test output under `docs/test-evidence/`.
28. Report files changed, commands run, results, limitations, and whether the
    next step is unblocked.
29. Stop and ask when a change would alter the research model, scoring formula,
    destination provenance, backend scope, or thesis claim.
