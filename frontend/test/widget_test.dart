import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pickleball_frontend/main.dart';

void main() {
  testWidgets('app shell renders provided home', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MyApp(
        home: Scaffold(body: Center(child: Text('Plaqora test home'))),
      ),
    );

    expect(find.text('Plaqora test home'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('app shell uses Plaqora title', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(home: SizedBox.shrink()));

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, 'Plaqora');
  });
}
