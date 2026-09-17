
import 'package:flutter_test/flutter_test.dart';
import 'package:taskkeeper/main.dart';

void main() {
  testWidgets('Taskkeeper app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskFlowApp());

    await tester.pump();

    expect(find.byType(TaskFlowApp), findsOneWidget);
  });
}

