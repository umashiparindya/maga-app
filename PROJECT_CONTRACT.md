# Project Contract

This document freezes the research-to-application contract for the Maga mobile application. It prevents agents from drifting away from the approved thesis project while implementing features.

## Project identity

- Research title: **The Influence of Social Media Content on Travel Destination Choice among Sri Lankan Youth**
- Application working name: **Maga**
- Current Flutter package: mashi_smoke
- Platform: Android-primary Flutter application
- Target users: Sri Lankan youth aged 18 to 30
- Travel scope: domestic travel destinations in Sri Lanka
- Application type: deterministic, rule-based destination recommendation
- Current environment: Pixel 7 API 34 emulator, device ID emulator-5554
- Current baseline: Flutter smoke application builds, installs, and launches

The package name remains mashi_smoke until an explicit migration is approved. Do not rename it casually because the thesis and emulator evidence depend on the working package identity.

## Research foundation

The research uses the Stimulus-Organism-Response framework:

- Stimulus: social-media content characteristics
- Organism: perceptions and travel-related evaluation
- Response: travel intention or destination choice intention

The four independent variables are:

1. Content credibility (CC)
2. Visual appeal (VA)
3. Influencer trust (IT)
4. Social media usage intensity (UI)

The dependent variable is travel intention (TI).

The latest approved workbook contains 233 raw records and 232 eligible responses after excluding one respondent outside the 18 to 30 screening range. The current research analysis reported:

- CC: standardised beta approximately 0.3895, statistically significant
- VA: standardised beta approximately 0.2293, statistically significant
- IT: standardised beta approximately 0.0560, not statistically significant as a unique predictor
- UI: standardised beta approximately 0.2469, statistically significant
- Regression R-squared approximately 0.4983

These values must be reproduced in the approved statistical package before they are called final in the thesis. Until then, the application treats the weights below as the locked prototype specification, not as a new statistical result.

## Application purpose

The app translates the research findings into a transparent recommendation prototype. It helps a user enter travel preferences and returns a ranked list of domestic destinations with explanations.

The app does not claim to predict actual travel behavior or guarantee a user's best destination. It provides research-informed prototype recommendations.

## Approved user journey

1. User opens the app.
2. User reads the purpose and starts the recommendation flow.
3. User enters or selects preferences.
4. The app validates the selections.
5. The app does not apply an undocumented hard filter; it computes a
   deterministic score for every validated destination in the controlled local
   repository.
6. The app ranks the scored destinations deterministically.
7. The app explains the main matching factors.
8. The user opens a destination detail screen.
9. The user can start again without stale state.

## Required user inputs

The minimum preference form must capture:

- budget level;
- preferred activities or travel styles;
- travel group;
- preferred trip duration;
- social media usage intensity.

The form must not collect unnecessary personal information. Authentication is not required for the academic MVP.

## Domain models

### Destination

Every destination record must contain typed fields equivalent to:

~~~text
id: stable unique string
name: string
province: string
description: short factual description
activities: set of supported activity categories
budgetLevel: low | medium | high
suitableGroups: set of solo | friends | family | partner
durationOptions: set of short | medium | long
bestSeason: factual or carefully qualified text
socialMediaAppealLevel: low | medium | high | veryHigh
socialMediaAppealScore: number from 0 to 1, normalized from the level
imageReference: optional licensed or local asset reference
sourceNote: provenance note for the record
~~~

Do not add prices, travel times, safety claims, opening hours, or other facts unless their source and freshness are documented.

### UserPreferences

~~~text
budgetLevel
activities
travelGroup
tripDuration
socialMediaUsageIntensity
~~~

### Recommendation

~~~text
destination
fitScore
socialMediaAppealScore
lambda
finalScore
matchedFactors
explanation
~~~

All scores must be finite, bounded, and explainable.

## Scoring contract

### Fit score

FitScore represents compatibility between user preferences and destination attributes. It must be normalized to the range 0.0 to 1.0.

The initial fit components are:

- budget compatibility;
- activity overlap;
- group suitability;
- trip-duration compatibility.

The following component weights are locked prototype design weights. They must live in one scoring-rules file and be covered by unit tests; do not scatter them across widgets:

~~~text
budget compatibility:       0.25
activity overlap:           0.35
travel-group suitability:   0.20
trip-duration compatibility: 0.20
~~~

These weights are transparent application design decisions. They are not regression coefficients and must not be described as survey findings.

### Combined social-media-appeal proxy

Each destination has one Appendix A Social Media Appeal label. The application
normalizes that label using this locked ordinal mapping:

~~~text
Low:       0.000
Medium:    0.333
High:      0.667
Very High: 1.000
~~~

`socialMediaAppealScore` is an application proxy normalization only. It is not
a survey measurement, real social-media analytics, an influencer-trust score,
or a destination-choice accuracy measure. Appendix A does not provide separate
destination-level CC, VA, and IT evidence, so the app must not duplicate one
combined label into those constructs. The survey findings remain research
context in the thesis and are not injected as regression coefficients into the
application. In particular, the research coefficients 0.5824, 0.3428, and
0.0748 are not application inputs.

### Usage adjustment

The application adjusts the balance between preference fit and the combined
social-media-appeal proxy using the user-declared usage intensity:

~~~text
FinalScore(d, u) =
    (1 - lambda(u)) * FitScore(d, u)
  + lambda(u) * socialMediaAppealScore(d)
~~~

lambda is the following locked, deterministic mapping:

~~~text
less than 1 hour per day: 0.25
1 to 2 hours:             0.35
2 to 4 hours:             0.45
more than 4 hours:        0.55
~~~

This is a locked application design rule. It is not a tested moderation effect or a statistically validated finding. If the mapping changes, update this contract, tests, and thesis wording together.

### Ranking and ties

- Rank by descending finalScore.
- Use a stable deterministic tie-breaker, preferably destination name or stable ID.
- Never use random numbers, current time, or network response order.
- Display a rounded score only if the explanation or methodology screen makes its meaning clear. Internal calculations should retain sufficient precision.

## Destination data policy

Use a controlled, bundled dataset first. Firebase is optional after the local flow works.

The approved source for the initial destination set is Appendix A, “Sri Lankan Domestic Travel Destinations,” in the approved thesis documents in the parent project folder. Appendix A contains 33 approved destinations. Step 4 must select 10 to 15 of those destinations only, with reasonable coverage of activities, budget levels, travel groups, and trip durations. It must not invent a separate destination list.

Destination facts must come from the relevant Appendix A record or a documented authoritative source. Every record must later include a `sourceNote` identifying the source actually used.

Destination proxy scores are **research-informed ordinal prototype values**. They are not verified social-media engagement metrics. The app and thesis must use that wording or an equally accurate equivalent.

For the combined Social Media Appeal label available in Appendix A, the locked
prototype encoding is:

~~~text
Low:       0.000
Medium:    0.333
High:      0.667
Very High: 1.000
~~~

This encoding applies only where Appendix A supplies exactly one combined label.
It must not be represented as survey measurement, live analytics, measured
engagement, reach, views, sentiment, influencer trust, or a validated
destination-performance measure.

Locked application normalization rules are:

- Budget: Low -> `low`; Low-Mid -> `medium`; Mid -> `medium`; Mid-High ->
  `high`; High -> `high`.
- Groups: All groups -> `solo`, `friends`, `family`, `partner`; Couples ->
  `partner`; Friends -> `friends`; Solo -> `solo`; Friends / Couples ->
  `friends`, `partner`; Friends / Solo -> `friends`, `solo`. Cultural
  travellers is not mapped automatically and is excluded from the MVP unless
  another supported group label exists.
- Durations use the midpoint of a stated range: up to 2 days -> `short`,
  greater than 2 and up to 4 days -> `medium`, and greater than 4 days ->
  `long`. Therefore half day, 1 day, and 1-2 days are short; 2-3 days, 2-4
  days, and 3-5 days are medium; and 3-7 days is long.

These are application normalization rules, not empirical survey findings.

Known Appendix A data gaps must be preserved rather than filled by inference:

- Appendix A provides one overall social-media-appeal label, not separate content-credibility, visual-appeal, and influencer-trust values. It must populate only the combined appeal fields.
- Cultural travellers remains unsupported by the controlled group enum and is excluded from the MVP unless another supported group label exists.
- Any destination record lacking a supported source label, required fact, or sourceNote remains a data gap and is excluded rather than fabricated.
- If a required value is absent from Appendix A and cannot be supported by a documented authoritative source, record it as a data gap. Do not fabricate it, silently substitute a value, or include an incomplete record in scoring.

Do not use live scraping or social-media APIs for the academic MVP. Do not copy images without permission or a documented open licence. If no reliable image is available, use a restrained text-first detail screen rather than an unlicensed image.

## Required screens

1. Welcome and project purpose
2. Preference collection
3. Validation or empty-state feedback
4. Ranked recommendation results
5. Destination details
6. About and methodology summary

The about screen should explain that the app uses a transparent rule-based prototype informed by survey-derived factors. It must not imply live analytics or artificial intelligence.

## Explicitly out of scope

- machine learning or generative AI inside the app;
- social-media scraping;
- live social-media metrics;
- travel booking or payment;
- user authentication;
- chat or messaging;
- admin dashboard;
- push notifications;
- commercial advertising;
- claims of production recommendation accuracy;
- claims of causal prediction;
- unsupported claims about the Sri Lankan population.

## Thesis evidence contract

The final thesis may claim only what is supported by:

- the approved workbook and reproducible statistical output;
- source code in this repository;
- passing unit, widget, and integration tests;
- a successful Android build and emulator run;
- documented manual test results;
- real screenshots taken from the working app.

The app validates the artifact and its flow. It does not independently validate the statistical model or prove destination choice accuracy.
