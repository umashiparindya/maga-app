import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mashi_smoke/application/recommendation_controller.dart';
import 'package:mashi_smoke/core/app_theme.dart';
import 'package:mashi_smoke/models/enums.dart';
import 'package:mashi_smoke/presentation/screens/preferences_screen.dart';

void main() {
  testWidgets('all selections update the controller and can be changed', (
    tester,
  ) async {
    final controller = RecommendationController();
    addTearDown(controller.dispose);
    await _pumpPreferences(tester, controller);

    final budgetField = find.byType(DropdownButtonFormField<BudgetLevel>);
    await _selectDropdown(tester, budgetField, 'Low');
    expect(controller.budgetLevel, BudgetLevel.low);
    await _selectDropdown(tester, budgetField, 'High');
    expect(controller.budgetLevel, BudgetLevel.high);

    final beach = find.widgetWithText(CheckboxListTile, 'Beach');
    await tester.tap(beach);
    await tester.pumpAndSettle();
    expect(controller.activities, contains(ActivityCategory.beach));
    expect(tester.widget<CheckboxListTile>(beach).value, isTrue);
    await tester.tap(beach);
    await tester.pumpAndSettle();
    expect(controller.activities, isNot(contains(ActivityCategory.beach)));
    final adventure = find.widgetWithText(CheckboxListTile, 'Adventure');
    await tester.tap(adventure);
    await tester.pumpAndSettle();
    expect(controller.activities, contains(ActivityCategory.adventure));

    final groupField = find.byType(DropdownButtonFormField<TravelGroup>);
    await _selectDropdown(tester, groupField, 'Solo');
    expect(controller.travelGroup, TravelGroup.solo);
    await _selectDropdown(tester, groupField, 'Friends');
    expect(controller.travelGroup, TravelGroup.friends);

    final durationField = find.byType(DropdownButtonFormField<TripDuration>);
    await _selectDropdown(tester, durationField, 'Short');
    expect(controller.tripDuration, TripDuration.short);
    await _selectDropdown(tester, durationField, 'Long');
    expect(controller.tripDuration, TripDuration.long);

    final usageField = find.byType(
      DropdownButtonFormField<SocialMediaUsageIntensity>,
    );
    await _selectDropdown(tester, usageField, 'Less than 1 hour per day');
    expect(
      controller.socialMediaUsageIntensity,
      SocialMediaUsageIntensity.lessThanOneHour,
    );
    await _selectDropdown(tester, usageField, 'More than 4 hours');
    expect(
      controller.socialMediaUsageIntensity,
      SocialMediaUsageIntensity.moreThanFourHours,
    );
  });

  testWidgets('incomplete form shows clear validation and does not submit', (
    tester,
  ) async {
    final controller = RecommendationController();
    addTearDown(controller.dispose);
    await _pumpPreferences(tester, controller);

    await _scrollToSubmit(tester);
    await tester.tap(find.text('Get recommendations'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Choose a budget, at least one activity, a travel group, a trip duration, and your daily social media use.',
      ),
      findsOneWidget,
    );
    expect(controller.hasSubmitted, isTrue);
    expect(controller.recommendations, isEmpty);
  });

  testWidgets('preference form scrolls on a Pixel 7-sized viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = RecommendationController();
    addTearDown(controller.dispose);
    await _pumpPreferences(tester, controller);

    final logicalHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
    expect(scrollable.position.maxScrollExtent, greaterThan(0));

    await _scrollToSubmit(tester);
    expect(
      tester.getBottomRight(find.text('Get recommendations')).dy,
      lessThanOrEqualTo(logicalHeight),
    );
  });
}

Future<void> _pumpPreferences(
  WidgetTester tester,
  RecommendationController controller,
) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: MashiTheme.light,
      home: PreferencesScreen(controller: controller),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _selectDropdown(
  WidgetTester tester,
  Finder field,
  String option,
) async {
  await tester.scrollUntilVisible(
    field,
    300,
    scrollable: find.byType(Scrollable),
  );
  await tester.tap(field);
  await tester.pumpAndSettle();
  await tester.tap(find.text(option).last);
  await tester.pumpAndSettle();
}

Future<void> _scrollToSubmit(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.text('Get recommendations'),
    500,
    scrollable: find.byType(Scrollable),
  );
}
