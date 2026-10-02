# Maga Application Build Roadmap

## How to use this roadmap

Give an AI agent one step at a time. The agent must read AGENTS.md and PROJECT_CONTRACT.md before starting. It must not continue to the next step until the current step's gate passes and the agent has reported the required evidence.

The roadmap is deliberately sequential. The scoring engine must exist before the UI depends on it, and the thesis must describe the tested application rather than the intended application.

## Global completion gates

No step is complete if:

- relevant tests fail;
- the agent did not run required validation;
- requirements were invented;
- data provenance is unknown;
- code only compiles in the agent's explanation but was not built;
- a visual change adds AI-slop patterns prohibited by AGENTS.md;
- a thesis claim is based on planned behavior rather than verified behavior.

## Step 0: Read, audit, and establish the baseline

### Objective

Understand the existing Flutter project before changing it.

### Agent instructions

- Read AGENTS.md, PROJECT_CONTRACT.md, and this roadmap.
- Inspect pubspec.yaml, lib/main.dart, test/, and Android configuration.
- Confirm the current package name and emulator target.
- Do not redesign or add dependencies in this step.

### Required commands

~~~bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
flutter devices
~~~

### Deliverables

- baseline report;
- list of current files;
- current build APK path;
- current test result;
- identified constraints or blockers.

### Gate

The existing smoke app builds, tests, and produces a debug APK. If it does not, fix only the baseline problem and stop.

## Step 1: Freeze the implementation contract

### Objective

Confirm that implementation decisions match PROJECT_CONTRACT.md.

### Agent instructions

- Verify the research variables and prototype weights.
- Verify the user journey and minimum screens.
- Verify that the app is rule-based and uses no AI or machine learning.
- Identify any unresolved data or naming issue.
- Do not write product code yet.

### Deliverables

- short implementation checklist;
- list of ambiguities, if any;
- confirmation that the contract is internally consistent.

### Gate

No unresolved ambiguity affects models, scoring, destination data, or required screens. If there is one, stop and ask for a decision.

## Step 2: Replace the smoke app with a minimal application shell

### Objective

Create a clean root application and navigation skeleton without implementing business logic.

### Scope

- app root;
- explicit theme tokens;
- named routes or a simple route mechanism;
- placeholder screens for Welcome, Preferences, Results, Details, and About;
- no fake destination data in the final UI;
- no scoring yet.

### Tests

- app starts;
- each placeholder route can be reached;
- back navigation works;
- no overflow appears on the Pixel 7 emulator.

### Gate

flutter analyze, flutter test, and flutter build apk --debug pass. The agent must provide an emulator screenshot showing the app shell.

## Step 3: Implement typed domain models

### Objective

Create Destination, UserPreferences, Recommendation, and controlled enum types.

### Scope

- typed fields;
- equality or stable identity where needed;
- validation for required destination data;
- serialization only if a current requirement needs it.

### Tests

- valid records are accepted;
- missing IDs, empty names, invalid score ranges, and empty required sets are rejected or reported clearly;
- enum values map predictably to display labels.

### Gate

Domain model tests pass. No screen performs scoring or parses raw maps.

## Step 4: Create the controlled destination dataset

### Objective

Create the first local destination repository using documented prototype data.

### Scope

- begin with 10 to 15 destinations;
- use destinations already approved for this project where possible;
- include factual descriptions and source notes;
- include the combined `socialMediaAppealLevel` and normalized `socialMediaAppealScore` from 0.0 to 1.0;
- keep all data in one repository or seed file.

### Prohibited behavior

- no invented social-media analytics;
- no fake ratings or reviews;
- no unlicensed images;
- no live scraping;
- no destination records duplicated inside widgets.

### Tests

- seed data loads;
- every record passes validation;
- IDs are unique;
- proxy scores are bounded;
- every record has an explanation-ready field set.

### Gate

The repository returns a stable list and a data-validation test passes.

## Step 5: Implement the scoring rules

### Objective

Implement the research-informed deterministic recommendation engine in pure Dart.

### Scope

Implement and separately test:

- budget matching;
- activity overlap;
- group suitability;
- duration compatibility;
- FitScore;
- the combined `socialMediaAppealScore` proxy;
- lambdaForUsageIntensity;
- FinalScore;
- stable ranking;
- explanations.

### Required invariants

- all scores remain in [0, 1];
- weights are centralized;
- same input produces same output;
- ranking is descending by final score;
- ties use a stable tie-breaker;
- explanations reflect real matches.

### Tests

- exact preference matches score higher than incompatible preferences;
- activity overlap behaves proportionally;
- usage categories map to intended lambda values;
- social-media-appeal normalization matches hand-calculated examples;
- final score matches hand-calculated examples using the combined appeal proxy;
- ranking order is correct;
- ties are stable;
- empty destination list returns a safe result;
- invalid inputs fail clearly.

### Gate

All domain tests pass. The scoring engine is usable without importing Flutter widgets.

## Step 6: Connect application state to the engine

### Objective

Connect preferences, repository data, and recommendations without adding visual polish.

### Scope

- form state;
- validation state;
- loading state, even for local data;
- empty results state;
- error state;
- reset behavior;
- result state.

### Tests

- incomplete preferences cannot submit;
- valid preferences call the engine once per submission;
- reset clears selections and results;
- empty repository produces an intentional empty state;
- errors are shown without stack traces.

### Gate

Widget tests prove that the preference flow produces the expected result state.

## Step 7: Implement the preference screen

### Objective

Build a clear, accessible preference collection flow.

### Scope

- budget selection;
- activity selection;
- group selection;
- duration selection;
- usage intensity selection;
- validation and submit action;
- scroll support.

### Design requirements

- no giant form inside one decorative card;
- selected state is visible without relying on color alone;
- labels are understandable to the target user;
- buttons have accessible touch targets;
- no unexplained technical terms.

### Tests

- each selection can be made and changed;
- required fields show clear validation;
- long content scrolls;
- submit is disabled or rejected until valid;
- selected values reach application state correctly.

### Gate

Widget tests and emulator manual test pass. Capture a screenshot for the thesis.

## Step 8: Implement ranked results and explanations

### Objective

Show useful recommendations rather than a generic list.

### Scope

- result count and heading;
- ranked destination results;
- visible but understandable match summary;
- score explanation;
- empty state;
- reset or edit-preferences action.

### Prohibited behavior

- no fake “98% match” claims unless the score meaning is clearly documented;
- no unsupported popularity labels;
- no random ordering;
- no decorative metrics with no evidence.

### Tests

- results appear in engine order;
- each result has a meaningful name and explanation;
- empty result state is intentional;
- edit preferences returns without stale state;
- result list handles long names and descriptions.

### Gate

Widget tests pass and a manual emulator run confirms ranking and explanation.

## Step 9: Implement destination details and About screen

### Objective

Provide enough context for a user to understand a recommendation and the project's limitations.

### Scope

- destination description;
- province or location text;
- activities;
- budget and group suitability;
- duration guidance;
- source note or carefully worded provenance label where appropriate;
- methodology summary;
- clear limitation that this is a research-informed prototype.

### Tests

- tapping a result opens the correct destination;
- back navigation returns to the same result state;
- long details scroll;
- missing optional image does not break layout;
- About text does not claim AI, live analytics, or accuracy validation.

### Gate

Widget tests pass and screenshots are captured.

## Step 10: Add Firebase only if it is ready

### Objective

Add Firestore persistence without making the app fragile.

### Preconditions

- local repository and full flow already work;
- Firebase project and credentials are available;
- no secrets will be committed;
- Firestore schema is documented.

### Scope

- repository interface remains stable;
- Firestore implementation is replaceable;
- loading, offline, empty, and failure states are handled;
- local fallback remains available for demo and tests.

### Tests

- local repository tests remain passing;
- Firestore mapping tests validate representative documents;
- failure state is safe;
- no credentials appear in source control;
- app works when backend data is unavailable if fallback is intended.

### Gate

Only mark this step complete if the configured app has been run against the intended backend. Otherwise record Firebase as deferred and continue with the tested local repository.

## Step 11: Visual QA and accessibility pass

### Objective

Remove boilerplate and improve clarity without adding decorative complexity.

### Checks

- no default Flutter counter artifacts remain;
- no default purple theme remains unless explicitly justified;
- typography is consistent;
- contrast is readable;
- touch targets are usable;
- keyboard and scrolling do not obscure controls;
- long names and descriptions do not overflow;
- loading, empty, selected, disabled, and error states are all designed;
- the interface does not resemble an AI-generated collection of cards.

### Gate

Manual Pixel 7 review passes and no new analyzer or widget-test failures appear.

## Step 12: Add full integration testing

### Objective

Prove the real user journey on the Android emulator.

### Required flow

~~~text
launch app
open recommendation flow
select valid preferences
submit
verify ranked results
open first result
verify destination details
return to results
reset or edit preferences
verify stale state is cleared
~~~

### Required evidence

- integration-test output;
- emulator identifier;
- debug APK path;
- screenshots of the primary flow;
- manual test matrix for edge cases.

### Gate

Integration test passes on emulator-5554 or the documented replacement.

## Step 13: Release validation and thesis evidence capture

### Objective

Create the evidence package needed for the final thesis.

### Commands

~~~bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test
flutter test integration_test
flutter build apk --debug
~~~

### Evidence package

Store under docs/test-evidence/:

- build details;
- test output summary;
- screenshots;
- manual test results;
- known limitations;
- final feature list;
- final data-source description.

### Gate

The application build and evidence package are complete enough for the thesis to describe the implemented artifact honestly.

## Step 14: Final thesis consistency audit

### Objective

Ensure the app, analysis, and final thesis do not contradict one another.

### Audit questions

- Does the thesis use the approved sample size n = 232 where required?
- Do reported variables match application terminology?
- Are app weights and formula documented accurately?
- Is the usage adjustment described as a design rule rather than proven moderation?
- Are proxy destination values described as proxies?
- Are app features claimed only if implemented and tested?
- Are screenshots from this build?
- Are limitations explicit?
- Are no fake usability participants or accuracy metrics included?

### Gate

The thesis evidence matrix is complete and every implementation claim points to actual code, test output, or a screenshot.

## Final completion command set

The final agent must run all relevant commands and report the actual output:

~~~bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test
flutter test integration_test
flutter build apk --debug
~~~

The final agent must also perform a manual emulator run and provide the APK location. A passing build alone is not proof that the intended user journey works.
