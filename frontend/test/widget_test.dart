import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:pickleball_frontend/features/auth/pages/login_page.dart';
import 'package:pickleball_frontend/features/auth/pages/onboarding_page.dart';
import 'package:pickleball_frontend/main.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      publishableKey: 'test-publishable-key',
      authOptions: FlutterAuthClientOptions(
        localStorage: _EmptyLocalStorage(),
        pkceAsyncStorage: _MemoryAsyncStorage(),
      ),
    );
  });

  testWidgets('app shell renders provided home', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MyApp(
        home: Scaffold(body: Center(child: Text('RallyHub test home'))),
      ),
    );

    expect(find.text('RallyHub test home'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('app shell uses RallyHub title', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(home: SizedBox.shrink()));

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, 'RallyHub');
  });

  testWidgets('onboarding continues to login on desktop', (
    WidgetTester tester,
  ) async {
    await _setSurfaceSize(tester, const Size(1280, 900));

    await tester.pumpWidget(const MaterialApp(home: OnboardingPage()));
    await tester.pump();

    expect(find.text('RallyHub'), findsOneWidget);
    expect(find.text('Play beyond the game'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('login form remains usable on phone width', (
    WidgetTester tester,
  ) async {
    await _setSurfaceSize(tester, const Size(390, 844));

    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    await tester.pump();

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Continue  ->'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _setSurfaceSize(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

class _EmptyLocalStorage extends LocalStorage {
  @override
  Future<void> initialize() async {}

  @override
  Future<String?> accessToken() async => null;

  @override
  Future<bool> hasAccessToken() async => false;

  @override
  Future<void> persistSession(String persistSessionString) async {}

  @override
  Future<void> removePersistedSession() async {}
}

class _MemoryAsyncStorage extends GotrueAsyncStorage {
  final Map<String, String> _items = {};

  @override
  Future<String?> getItem({required String key}) async => _items[key];

  @override
  Future<void> removeItem({required String key}) async {
    _items.remove(key);
  }

  @override
  Future<void> setItem({required String key, required String value}) async {
    _items[key] = value;
  }
}
