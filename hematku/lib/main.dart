import 'package:flutter/material.dart';

import 'account_model.dart';
import 'add_transaction_page.dart';
import 'app_settings_page.dart';
import 'category_page.dart';
import 'chart_page.dart';
import 'database_helper.dart';
import 'edit_transaction_page.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'profile_info_page.dart';
import 'profile_page.dart';
import 'transaction_page.dart';

void main() {
  runApp(const HematKuApp());
}

class HematKuApp extends StatefulWidget {
  const HematKuApp({super.key});

  @override
  State<HematKuApp> createState() => _HematKuAppState();
}

class _HematKuAppState extends State<HematKuApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  AccountModel? _account;
  Object? _startupError;
  bool _isCheckingSession = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    setState(() {
      _isCheckingSession = true;
      _startupError = null;
    });
    try {
      final account = await DatabaseHelper.instance.getActiveAccount();
      if (!mounted) return;
      setState(() {
        _account = account;
        _isCheckingSession = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _startupError = error;
        _isCheckingSession = false;
      });
    }
  }

  void _onAuthenticated(AccountModel account) {
    setState(() {
      _account = account;
    });
  }

  void _onAuthenticatedFromLoginRoute(AccountModel account) {
    _onAuthenticated(account);
    _navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
  }

  void _onAccountUpdated(AccountModel account) {
    setState(() {
      _account = account;
    });
  }

  void _onSignOut() {
    setState(() {
      _account = null;
    });
    _navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }

  Widget _startupScreen() {
    if (_isCheckingSession) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_startupError != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Data akun gagal dimuat.'),
                const SizedBox(height: 8),
                Text(_startupError.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _restoreSession,
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (_account == null) {
      return LoginPage(onAuthenticated: _onAuthenticatedFromLoginRoute);
    }
    return const HomePage();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'HematKu',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF245B4A)),
      ),
      home: _startupScreen(),
      routes: {
        '/transaction': (context) => const TransactionPage(),
        '/chart': (context) => const ChartPage(),
        '/add-transaction': (context) => const AddTransactionPage(),
        '/category': (context) => const CategoryPage(),
        '/edit-transaction': (context) => const EditTransactionPage(),
        '/profile': (context) => ProfilePage(
          account: _account!,
          onAccountUpdated: _onAccountUpdated,
        ),
        '/profile-info': (context) => ProfileInfoPage(account: _account!),
        '/settings': (context) => AppSettingsPage(
          account: _account!,
          onAccountUpdated: _onAccountUpdated,
          onSignOut: _onSignOut,
        ),
        '/login': (context) =>
            LoginPage(onAuthenticated: _onAuthenticatedFromLoginRoute),
      },
    );
  }
}
