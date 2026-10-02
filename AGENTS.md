# AGENTS.md

## Purpose

This file is the mandatory operating contract for every AI agent working in this Flutter project. Read it completely before inspecting or changing code.

The application is the software artifact for the academic research project:

**The Influence of Social Media Content on Travel Destination Choice among Sri Lankan Youth**

The application is an Android-primary, rule-based domestic travel destination recommendation prototype for Sri Lankan youth aged 18 to 30. It is not an AI application, machine-learning system, booking platform, social network, or commercial travel marketplace.

## Non-negotiable project rules

1. **Research integrity comes before visual polish.** Do not invent findings, weights, destinations, user ratings, engagement numbers, test participants, usability results, or implementation evidence.

2. **The application must remain rule-based.** Do not add machine learning, generative AI, recommendation APIs, embeddings, LLM calls, or opaque ranking logic. AI agents may write code, but the application must not depend on AI.

3. **Use the project contract as the source of truth.** Read PROJECT_CONTRACT.md before changing models, scoring, screens, data, or terminology. If the contract conflicts with a later explicit user instruction, follow the later instruction and update the contract before coding.

4. **Do not silently change the research model.** The research variables are content credibility, visual appeal, influencer trust, social media usage intensity, and travel intention. Do not rename them casually or replace them with fashionable product terms.

5. **Do not claim moderation.** The survey tested social media usage intensity as a direct predictor of travel intention. The application may use usage intensity as a documented product-design rule for the content-versus-fit balance, but that does not prove statistical moderation.

6. **Do not treat proxy scores as real social-media analytics.** Destination content scores are research-informed ordinal proxy values for the prototype. They must never be described as live engagement, reach, views, sentiment, or platform analytics unless those data are genuinely collected and documented.

7. **Do not add features outside the academic MVP.** Authentication, payments, bookings, chat, scraping, live APIs, push notifications, admin tools, social-media login, and complex profiles are out of scope unless the user explicitly changes the scope.

8. **Do not write thesis claims from intention.** Only describe behavior that is present in the code and verified by a test, build, emulator run, or recorded evidence. A planned feature is not an implemented feature.

9. **Preserve traceability.** Every recommendation score must be explainable from user preferences, destination fields, and the documented formula. Avoid hidden constants and magic conditions.

10. **Keep the app deterministic.** Identical destination data and identical user preferences must produce identical ranking and explanations.

11. **Do not overwrite working behavior without evidence.** Inspect the current code and tests first. Make the smallest coherent change. Never use destructive commands to discard work.

12. **Do not create fake completion.** Never mark a roadmap step complete when its tests have not passed. Never report a command as successful without running it.

13. **Stop on ambiguity.** If a requested change affects the research model, scoring weights, destination data provenance, thesis claims, Firebase architecture, or scope, stop and report the conflict instead of guessing.

## Anti-AI-slop design rules

The interface must feel like a considered travel research prototype, not an AI-generated template.

- Do not use the default Flutter purple theme as the final visual identity.
- Do not use random gradients, glassmorphism, neon colors, excessive rounded cards, floating blobs, or oversized hero typography.
- Do not use arbitrary font combinations. Use the platform/system font unless a real, approved brand font is supplied.
- Do not use a random five-color palette. Use neutrals, one restrained primary accent, and only necessary semantic colors. Record the rationale before adding colors.
- Do not use emojis as icons. Use consistent Material icons or another documented icon set.
- Do not put every piece of content in a separate card. Use hierarchy, spacing, typography, dividers, and meaningful grouping.
- Do not make every control a pill. Use shape to communicate function.
- Do not use fake statistics, fake reviews, fake user counts, fake ratings, fake social-media badges, or fake testimonials.
- Do not use generic filler copy such as “unforgettable adventures await” when a precise description is possible.
- Do not add decorative UI that competes with the recommendation explanation.
- Do not copy a popular travel app's interface. The design must serve this project's user flow and evidence.
- Prefer a calm, readable, mobile-first layout with clear touch targets and accessible contrast over visual novelty.

## Engineering rules

- Keep domain logic independent from Flutter widgets.
- Put all scoring logic in pure Dart classes or functions that can be unit tested without a device.
- Keep models explicit and typed. Avoid Map<String, dynamic> in domain logic.
- Avoid global mutable state.
- Do not introduce a state-management framework before the core flow works.
- Do not introduce a dependency without a concrete requirement and a maintenance justification.
- Keep one clear source of truth for destinations.
- Keep user-facing strings centralized where practical.
- Validate all user input and handle empty states deliberately.
- Handle errors without exposing stack traces or internal implementation text.
- Keep files focused. Do not create giant widgets containing models, scoring, navigation, and data access together.
- Use meaningful names. Avoid names such as data1, temp, dummy, magic, finalList, or newThing.
- Comments should explain a decision or constraint, not narrate obvious Dart.
- Keep formatting and linting clean.

## Required workflow for every agent

1. Read this file, PROJECT_CONTRACT.md, and the current roadmap step.
2. Inspect the current repository state, including relevant tests.
3. State the exact step being implemented and its acceptance criteria.
4. Change only the files necessary for that step.
5. Run the required tests and validation commands.
6. Review the diff for scope creep, invented data, and accidental boilerplate.
7. Report:
   - files changed;
   - behavior implemented;
   - commands run and their results;
   - tests passed or failed;
   - known limitations;
   - whether the next roadmap step is unblocked.
8. Stop. Do not continue into the next roadmap step unless explicitly instructed.

## Required validation commands

Run the commands relevant to the step. Before calling the app complete, all of the following must pass:

~~~bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test
flutter build apk --debug
~~~

If integration_test/ does not exist, do not invent a failing command for it. Add integration tests before the final validation phase.

For emulator validation, confirm the actual package and activity launch rather than relying only on a successful build:

~~~bash
flutter devices
flutter run -d emulator-5554
adb shell am start -n com.example.mashi_smoke/.MainActivity
~~~

The package name may change only through an explicit, documented migration.

## AI-agent delegation rules

Multiple agents may be used, but they must not independently invent competing architectures. The lead agent owns the contract and integrates changes.

- Analyst agent: may inspect data and produce evidence, but may not change app behavior or invent scores.
- Domain agent: may implement models and scoring, but may not redesign screens.
- UI agent: may implement screens using existing models and services, but may not change scoring or research terms.
- Test agent: may add tests and report failures, but may not weaken acceptance criteria to make tests pass.
- Thesis agent: may use verified app evidence, but may not claim unverified features or results.

Every delegated agent must receive the exact roadmap step, allowed files, and acceptance criteria. Do not give an agent the vague instruction “build the app”.

## Definition of done for the application

The app is complete only when:

- a clean checkout can install dependencies;
- the app builds and launches on the Pixel 7 API 34 emulator;
- a user can complete the intended flow from welcome to destination details;
- the score is deterministic and covered by unit tests;
- results are ranked and explainable;
- invalid and empty inputs are handled;
- the destination data source is documented;
- the app has no fake analytics or unsupported claims;
- widget and integration tests pass;
- a debug APK is produced;
- screenshots and test evidence are stored for the thesis;
- the thesis describes only the behavior that was actually verified.

