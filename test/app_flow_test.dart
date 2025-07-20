import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:employee_attendance_tasks/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Attendance Flow', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Name entry and persistence', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.text('Enter your name'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'John Doe');
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();
      expect(find.text('Name: John Doe'), findsOneWidget);
    });

    testWidgets('Check-In and Check-Out flow', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'John Doe');
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Check-In'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Check-In:'), findsOneWidget);
      await tester.tap(find.text('Check-Out'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Check-Out:'), findsOneWidget);
      expect(find.textContaining('Attendance Status: Present'), findsOneWidget);
    });
  });

  group('Tasks Flow', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Empty list on first launch', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();
      expect(find.text('No tasks yet.'), findsOneWidget);
    });

    testWidgets('Add and update task', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Add Task'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Test Task');
      await tester.tap(find.text('Low'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('High'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Not Started'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      expect(find.text('Test Task'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.text('Status: Done'), findsOneWidget);
    });
  });
}
