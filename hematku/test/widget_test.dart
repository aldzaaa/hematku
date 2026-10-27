import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hematku/account_model.dart';
import 'package:hematku/app_settings_page.dart';
import 'package:hematku/login_page.dart';

void main() {
  testWidgets('Login page can switch to account registration', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: LoginPage(onAuthenticated: (_) {})),
    );

    expect(find.text('Masuk ke HematKu'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));

    await tester.tap(find.text('Belum punya akun? Daftar'));
    await tester.pumpAndSettle();

    expect(find.text('Buat Akun HematKu'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));
    expect(find.text('Daftar'), findsOneWidget);
  });

  testWidgets('Settings page shows per-account notification controls', (
    WidgetTester tester,
  ) async {
    final account = AccountModel(
      id: 1,
      name: 'Pengguna',
      email: 'pengguna@example.com',
      transactionNotifications: true,
      monthlySummaryNotifications: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AppSettingsPage(
          account: account,
          onAccountUpdated: (_) {},
          onSignOut: () {},
        ),
      ),
    );

    expect(find.byType(SwitchListTile), findsNWidgets(2));
    expect(find.text('Notifikasi transaksi'), findsOneWidget);
    expect(find.text('Ringkasan bulanan'), findsOneWidget);
    expect(find.text('Ganti akun'), findsOneWidget);
  });
}
