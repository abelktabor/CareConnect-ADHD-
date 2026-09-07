import 'package:careconnect_mobile/core/theme/app_colors.dart';
import 'package:careconnect_mobile/core/theme/app_theme.dart';
import 'package:careconnect_mobile/core/widgets/alert_card.dart';
import 'package:careconnect_mobile/core/widgets/autosave_indicator.dart';
import 'package:careconnect_mobile/core/widgets/cc_app_bar.dart';
import 'package:careconnect_mobile/core/widgets/cc_list_item.dart';
import 'package:careconnect_mobile/core/widgets/dose_status.dart';
import 'package:careconnect_mobile/core/widgets/empty_state.dart';
import 'package:careconnect_mobile/core/widgets/responsive.dart';
import 'package:careconnect_mobile/core/widgets/section_heading.dart';
import 'package:careconnect_mobile/core/widgets/status_chip.dart';
import 'package:careconnect_mobile/core/widgets/step_indicator.dart';
import 'package:careconnect_mobile/models/user_role.dart';
import 'package:careconnect_mobile/state/draft_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(
  Widget child, {
  Size size = const Size(412, 915),
  UserRole role = UserRole.careRecipient,
}) {
  return MediaQuery(
    data: MediaQueryData(size: size),
    child: MaterialApp(
      theme: AppTheme.build(brightness: Brightness.light, role: role),
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  testWidgets('StepIndicator fills the bar to the step fraction', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const StepIndicator(
          step: 2,
          totalSteps: 3,
          title: 'Schedule',
          subtitle: 'When',
        ),
      ),
    );
    expect(find.text('Step 2 of 3 — Schedule'), findsOneWidget);
    expect(find.text('When'), findsOneWidget);
    final bar = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(bar.value, closeTo(2 / 3, 0.001));
    expect(
      () => StepIndicator(step: 4, totalSteps: 3, title: 'x'),
      throwsAssertionError,
    );
  });

  testWidgets('AutosaveIndicator states', (tester) async {
    await tester.pumpWidget(
      host(const AutosaveIndicator(status: AutosaveStatus.idle)),
    );
    expect(find.text('Saving…'), findsNothing);
    await tester.pumpWidget(
      host(const AutosaveIndicator(status: AutosaveStatus.saving)),
    );
    expect(find.text('Saving…'), findsOneWidget);
    await tester.pumpWidget(
      host(const AutosaveIndicator(status: AutosaveStatus.saved)),
    );
    expect(find.text('Saved'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('StatusChip always pairs an icon with text', (tester) async {
    await tester.pumpWidget(
      host(
        const StatusChip(
          tone: StatusTone.overdue,
          text: 'Overdue · 45 min late',
        ),
      ),
    );
    expect(find.byIcon(Icons.warning), findsOneWidget);
    expect(find.text('Overdue · 45 min late'), findsOneWidget);
  });

  testWidgets('AlertCard is a labelled button when tappable', (tester) async {
    final handle = tester.ensureSemantics();
    var taps = 0;
    await tester.pumpWidget(
      host(
        AlertCard(
          text: 'Overdue — 9 AM Lisinopril',
          onTap: () => taps++,
          actionHint: 'Opens',
        ),
      ),
    );
    await tester.tap(find.byType(AlertCard));
    expect(taps, 1);
    expect(
      tester.getSemantics(find.byType(AlertCard)),
      matchesSemantics(
        label: 'Alert: Overdue — 9 AM Lisinopril',
        hint: 'Opens',
        isButton: true,
        hasTapAction: true,
        isFocusable: true,
        hasFocusAction: true,
      ),
    );
    await tester.pumpWidget(host(const AlertCard(text: 'Static')));
    expect(find.byIcon(Icons.chevron_right), findsNothing);
    handle.dispose();
  });

  testWidgets('CcListItem shows a trailing widget or a chevron', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(CcListItem(title: 'Row', subtitle: 'Sub', onTap: () {})),
    );
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    await tester.pumpWidget(
      host(const CcListItem(title: 'Row', trailing: Icon(Icons.star))),
    );
    expect(find.byIcon(Icons.star), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsNothing);
    expect(
      tester.getSize(find.byType(CcListItem)).height,
      greaterThanOrEqualTo(48),
    );
  });

  testWidgets('SectionHeading levels map to the type scale', (tester) async {
    await tester.pumpWidget(
      host(
        const Column(
          children: [
            SectionHeading('One', level: HeadingLevel.h1),
            SectionHeading('Two', level: HeadingLevel.h2),
            SectionHeading('Three'),
            SectionHeading('Four', level: HeadingLevel.h4),
          ],
        ),
      ),
    );
    expect(tester.widget<Text>(find.text('One')).style?.fontSize, 32);
    expect(tester.widget<Text>(find.text('Two')).style?.fontSize, 24);
    expect(tester.widget<Text>(find.text('Three')).style?.fontSize, 20);
    expect(tester.widget<Text>(find.text('Four')).style?.fontSize, 18);
  });

  testWidgets('ResponsiveBody and ResponsiveCardGrid switch at 600px', (
    tester,
  ) async {
    Widget body() =>
        const ResponsiveBody(primary: [Text('P')], secondary: [Text('S')]);
    await tester.pumpWidget(host(body()));
    expect(
      tester.getTopLeft(find.text('S')).dy,
      greaterThan(tester.getTopLeft(find.text('P')).dy),
    );
    tester.view.physicalSize = const Size(900, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(host(body(), size: const Size(900, 600)));
    expect(
      tester.getTopLeft(find.text('S')).dx,
      greaterThan(tester.getTopLeft(find.text('P')).dx),
    );

    await tester.pumpWidget(
      host(
        const ResponsiveCardGrid(children: [Text('A'), Text('B')]),
        size: const Size(900, 600),
      ),
    );
    expect(
      tester.getTopLeft(find.text('B')).dx,
      greaterThan(tester.getTopLeft(find.text('A')).dx),
    );
    tester.view.physicalSize = const Size(412, 915);
    await tester.pumpWidget(
      host(const ResponsiveCardGrid(children: [Text('A'), Text('B')])),
    );
    expect(
      tester.getTopLeft(find.text('B')).dy,
      greaterThan(tester.getTopLeft(find.text('A')).dy),
    );
  });

  testWidgets('CcAppBar shows subtitle and a back button that pops', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.light,
          role: UserRole.caregiver,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const Scaffold(
                      appBar: CcAppBar(
                        title: 'Detail',
                        subtitle: 'Sub',
                        showBack: true,
                      ),
                    ),
                  ),
                ),
                child: const Text('Go'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Go'));
    await tester.pumpAndSettle();
    expect(find.text('Detail'), findsOneWidget);
    expect(find.text('Sub'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Detail'), findsNothing);
  });

  testWidgets('EmptyState renders message and detail', (tester) async {
    await tester.pumpWidget(
      host(
        const EmptyState(
          icon: Icons.check,
          message: 'Done',
          detail: 'Nothing left',
        ),
      ),
    );
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Nothing left'), findsOneWidget);
  });

  test('the role accent never leaks across experiences', () {
    // Dusk Violet is the caregiver cue (SC 3.2.4 Consistent Identification).
    // Material derives SegmentedButton and chip fills from colorScheme
    // .secondary, so a violet control on a care-recipient screen would tell
    // the user they are looking at someone else's care. Both schemes must
    // therefore stay in role.
    for (final brightness in Brightness.values) {
      final patient = AppTheme.build(
        brightness: brightness,
        role: UserRole.careRecipient,
      ).colorScheme;
      final caregiver = AppTheme.build(
        brightness: brightness,
        role: UserRole.caregiver,
      ).colorScheme;

      expect(patient.secondary, patient.primary, reason: 'care recipient');
      expect(caregiver.secondary, caregiver.primary, reason: 'caregiver');
      expect(patient.primary, isNot(caregiver.primary));

      final violet = brightness == Brightness.dark
          ? AppColors.darkSecondary
          : AppColors.secondary;
      for (final role in [
        patient.primary,
        patient.secondary,
        patient.tertiary,
      ]) {
        expect(
          role,
          isNot(violet),
          reason: 'violet on a care-recipient screen',
        );
      }
    }
  });

  testWidgets('the Appearance control uses the role accent, not violet', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 0, label: Text('System')),
            ButtonSegment(value: 1, label: Text('Light')),
          ],
          selected: const {0},
          onSelectionChanged: (_) {},
        ),
      ),
    );
    final context = tester.element(find.text('System'));
    expect(Theme.of(context).colorScheme.secondary, AppColors.primary);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dark theme builds for both roles', (tester) async {
    for (final role in UserRole.values) {
      final theme = AppTheme.build(brightness: Brightness.dark, role: role);
      expect(theme.brightness, Brightness.dark);
      expect(
        theme.colorScheme.primary,
        isNot(
          AppTheme.build(
            brightness: Brightness.light,
            role: role,
          ).colorScheme.primary,
        ),
      );
    }
  });
}
