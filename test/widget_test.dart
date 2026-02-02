import 'package:attendance/services/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:attendance/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    final fakeStorage = FakeLocalStorageService();

    await tester.pumpWidget(MyApp(localStorageService: fakeStorage));

    await tester.pumpAndSettle();

    // Basic sanity check
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

class FakeLocalStorageService extends LocalStorageService {
  @override
  Future<void> init() async {
    // Do nothing for tests
  }
}
