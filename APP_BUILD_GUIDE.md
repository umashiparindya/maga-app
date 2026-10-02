# Maga Application Build Guide

## Read this first

This guide explains how to build the academic application from the existing Flutter smoke project into a working, testable Android prototype. It is written for AI coding agents and human collaborators.

The mandatory rules are in AGENTS.md. The frozen research and product decisions are in PROJECT_CONTRACT.md. The staged implementation order and gates are in BUILD_ROADMAP.md.

Do not treat the existing default counter application as product code. Replace it deliberately, while keeping the currently working Android configuration intact unless there is a real requirement to change it.

## Product outcome

The final MVP must allow a Sri Lankan youth user to enter travel preferences and receive a transparent ranked list of domestic travel destinations. A user must be able to understand why a destination appears in the results.

The final product is judged on:

- end-to-end functionality;
- alignment with the research model;
- transparent scoring;
- clean data boundaries;
- testing quality;
- usability and accessibility;
- honest thesis evidence;
- visual restraint and coherence.

## Engineering approach

Use a small layered architecture:

~~~text
presentation -> application state -> domain scoring -> data repository
~~~

### Presentation layer

Contains screens and small reusable widgets. It may read state and call an application service. It must not calculate recommendation scores directly.

### Application state

Coordinates the user flow, form state, loading state, error state, and results. Keep this simple at first. Flutter core state management is acceptable. Add a state-management package only when the existing flow demonstrates a concrete need.

### Domain layer

Contains pure Dart models and the recommendation engine. This is the most important layer because it connects the research to the application.

Suggested files:

~~~text
lib/domain/recommendation_engine.dart
lib/domain/scoring_rules.dart
lib/domain/score_explanation.dart
~~~

### Data layer

Contains destination seed data and repository abstractions. Start with a local repository. Add Firestore only after the local implementation is tested.

Suggested files:

~~~text
lib/data/destination_repository.dart
lib/data/local_destination_repository.dart
lib/data/destination_seed.dart
~~~

### Core layer

Contains theme, routes, constants, validation helpers, and reusable design tokens. Do not turn this into a dumping ground.

## Recommended folder structure

~~~text
lib/
  main.dart
  app.dart
  core/
    app_theme.dart
    app_routes.dart
    app_strings.dart
    validation.dart
  models/
    destination.dart
    user_preferences.dart
    recommendation.dart
    enums.dart
  data/
    destination_repository.dart
    local_destination_repository.dart
    destination_seed.dart
  domain/
    recommendation_engine.dart
    scoring_rules.dart
    score_explanation.dart
  presentation/
    screens/
      welcome/
      preferences/
      results/
      destination_detail/
      about/
    widgets/
      app_button.dart
      choice_field.dart
      destination_result_tile.dart
      score_explanation_view.dart

test/
  models/
  domain/
  data/
  presentation/

integration_test/
  recommendation_flow_test.dart

docs/
  screenshots/
  test-evidence/
~~~

Do not create every directory in advance. Add a directory when its feature is actually being implemented.

## Data and model guidance

Prefer enums and value objects over unvalidated strings for controlled values. For example:

~~~dart
enum BudgetLevel { low, medium, high }
enum TravelGroup { solo, friends, family, partner }
enum TripDuration { short, medium, long }
enum SocialMediaAppealLevel { low, medium, high, veryHigh }
~~~

For multiple activities, use a typed enum set or an immutable list with validation. A destination must have at least one activity, supported group, and duration option.

Every destination record requires a sourceNote. The source note is not a marketing paragraph. It identifies how the destination description or proxy score was prepared.

The destination appeal fields are `socialMediaAppealLevel` and its locked
ordinal `socialMediaAppealScore`: Low 0.000, Medium 0.333, High 0.667, and
Very High 1.000. This is an application proxy only, not a survey measurement,
live analytics value, influencer-trust score, or destination-choice accuracy
measure.

## Scoring implementation guidance

The scoring engine should expose a small, testable API such as:

~~~dart
List<Recommendation> recommend({
  required UserPreferences preferences,
  required List<Destination> destinations,
});
~~~

Keep the following functions separately testable:

~~~text
calculateFitScore
calculateSocialMediaAppealScore
lambdaForUsageIntensity
calculateFinalScore
rankRecommendations
buildExplanation
~~~

Expected invariants:

- every component score is in [0, 1];
- final score is in [0, 1];
- the social-media-appeal proxy is one normalized value in [0, 1];
- higher matching fit must not reduce the fit score;
- higher social-media-appeal proxy values must not reduce the appeal contribution;
- ranking is deterministic;
- ties are stable;
- explanations use actual matched factors.

Do not silently clamp invalid source data without reporting it. Validate source data at repository loading time and fail with a useful development error.

## Fit score design

The first implementation should use a transparent average of four normalized components:

~~~text
FitScore =
  budgetMatch * 0.25
+ activityMatch * 0.35
+ groupMatch * 0.20
+ durationMatch * 0.20
~~~

These are application design weights, not regression coefficients. Keep them in scoring_rules.dart, name them clearly, and document the reason in the thesis as a prototype design decision.

Suggested matching behavior:

- exact budget match: 1.0;
- adjacent budget level: 0.5;
- incompatible budget: 0.0;
- activity match: proportion of selected activities supported by the destination;
- group match: 1.0 if supported, otherwise 0.0;
- exact duration match: 1.0;
- adjacent duration: 0.5;
- incompatible duration: 0.0.

These values must be tested and may be revised only through an explicit contract change.

## Explanations

Every result should answer:

1. Why did this destination rank here?
2. Which preferences matched?
3. How did content signals contribute?

Example style:

> Ranked highly because it matches your selected budget and activity interests, supports your travel group, and has a strong social-media-appeal proxy score.

Do not expose unexplained decimal coefficients to ordinary users. A methodology section can describe the formula separately.

## UI and visual system

### Design principles

- clear before clever;
- content hierarchy before decoration;
- one obvious primary action per screen;
- comfortable spacing and readable text;
- accessible contrast and touch targets;
- consistent component states;
- restrained use of cards and shadows;
- real destination information over decorative filler.

### Typography

Use the system font unless a real approved brand font exists. Establish a small type scale with clear roles:

- screen title;
- section heading;
- body text;
- supporting text;
- button label.

Do not combine unrelated fonts or use an ornamental font for the travel theme.

### Color

Use explicit semantic design tokens rather than random widget colors. Until an approved brand direction exists, use a neutral base with one restrained accent and semantic status colors. Do not use gradients or a default seed-color theme.

Check contrast for body text, buttons, selected states, error messages, and disabled states. Color must not be the only indication of selection or error.

### Components

Build a small set of reusable components only when repetition exists:

- primary and secondary buttons;
- single-choice selection field;
- multi-choice activity field;
- destination result row or tile;
- score explanation section;
- empty and error states.

Avoid building a design system larger than the product.

### Responsive behavior

The target is a phone, but layouts must not overflow on the Pixel 7 emulator. Use scrolling for long preference forms and destination details. Test keyboard, small text, long destination names, empty values, and long explanations.

## Navigation and state

The primary flow should be understandable without a drawer or complex navigation system:

~~~text
Welcome -> Preferences -> Results -> Destination details
                     ^          |
                     |----------|
~~~

Resetting the flow must clear the previous user preferences and results. Back navigation must not create duplicate screens or stale rankings.

## Firebase guidance

Firebase is a secondary implementation concern. The local repository must remain the reliable testable baseline.

If Firestore is added:

- define the collection shape before coding;
- keep a repository interface so the domain layer is backend-independent;
- validate documents when reading them;
- handle loading, offline, empty, and error states;
- do not store sensitive personal data;
- do not claim Firebase functionality until it is run and tested;
- never commit credentials or secrets.

The app must still be demonstrable with a controlled local dataset if the cloud configuration is unavailable.

## Testing strategy

### Unit tests

Cover models, validation, scoring, ranking, explanation generation, and data validation.

### Widget tests

Cover screen rendering, selection state, validation errors, navigation, empty states, result display, and reset behavior.

### Integration test

Cover the actual primary journey on an emulator:

~~~text
launch -> start -> choose preferences -> submit -> view ranked result -> open destination details -> restart
~~~

### Manual checks

Record the emulator, build variant, date, test case, expected result, actual result, and evidence screenshot. Store evidence under docs/test-evidence/.

## Thesis evidence discipline

When a feature is completed, immediately record:

- what was implemented;
- where it is implemented;
- how it was tested;
- the exact command or manual action used;
- the result;
- the screenshot or output path.

This prevents the final thesis from relying on memory or unsupported claims.

## What agents must report at the end of a step

Use this format:

~~~text
ROADMAP STEP: <ID and title>
STATUS: COMPLETE | BLOCKED | FAILED

IMPLEMENTED:
- ...

FILES CHANGED:
- ...

VALIDATION:
- command: <command>
  result: PASS | FAIL
- manual check: <check>
  result: PASS | FAIL

EVIDENCE:
- ...

KNOWN LIMITATIONS:
- ...

NEXT STEP UNBLOCKED: YES | NO
~~~
