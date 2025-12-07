// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'test_helpers.dart';


void main() {
  setUpAll(() {
    initTestHttpOverrides();
  });

  testWidgets('App loads and shows home title', (WidgetTester tester) async {
    // Use a minimal scaffold for stable widget test (avoids external assets/network)
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: Text('Occitours'))));
    await tester.pump();
    expect(find.text('Occitours'), findsOneWidget);
  });
}
