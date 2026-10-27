import 'package:flutter/material.dart';

import 'account_model.dart';
import 'database_helper.dart';

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({
    super.key,
    required this.account,
    required this.onAccountUpdated,
    required this.onSignOut,
  });

  final AccountModel account;
  final ValueChanged<AccountModel> onAccountUpdated;
  final VoidCallback onSignOut;

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  late AccountModel _account;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _account = widget.account;
  }

  Future<void> _updateNotifications({
    bool? transactionNotifications,
    bool? monthlySummaryNotifications,
  }) async {
    setState(() {
      _isSaving = true;
    });
    try {
      final updated = await DatabaseHelper.instance.updateNotificationSettings(
        userId: _account.id,
        transactionNotifications:
            transactionNotifications ?? _account.transactionNotifications,
        monthlySummaryNotifications:
            monthlySummaryNotifications ?? _account.monthlySummaryNotifications,
      );
      if (!mounted) return;
      setState(() {
        _account = updated;
        _isSaving = false;
      });
      widget.onAccountUpdated(updated);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pengaturan gagal disimpan: $error')),
      );
    }
  }

  Future<void> _signOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ganti akun?'),
        content: const Text(
          'Kamu akan keluar dari akun ini sebelum masuk dengan akun lain.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    );
    if (shouldSignOut != true || !mounted) return;

    try {
      await DatabaseHelper.instance.logout();
      if (mounted) widget.onSignOut();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak bisa keluar dari akun: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: const Color(0xFF245B4A),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              'NOTIFIKASI',
              style: TextStyle(
                color: Color(0xFF245B4A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Card(
            color: Colors.white,
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.receipt_long_outlined),
                  title: const Text('Notifikasi transaksi'),
                  subtitle: const Text('Pengingat untuk mencatat transaksi.'),
                  value: _account.transactionNotifications,
                  onChanged: _isSaving
                      ? null
                      : (value) => _updateNotifications(
                          transactionNotifications: value,
                        ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.calendar_month_outlined),
                  title: const Text('Ringkasan bulanan'),
                  subtitle: const Text(
                    'Pengingat untuk melihat ringkasan keuangan.',
                  ),
                  value: _account.monthlySummaryNotifications,
                  onChanged: _isSaving
                      ? null
                      : (value) => _updateNotifications(
                          monthlySummaryNotifications: value,
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              'AKUN',
              style: TextStyle(
                color: Color(0xFF245B4A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Card(
            color: Colors.white,
            child: ListTile(
              leading: const Icon(Icons.swap_horiz, color: Color(0xFF245B4A)),
              title: const Text('Ganti akun'),
              subtitle: Text('Keluar dari ${_account.email}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _signOut,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            label: const Text('Keluar dari akun'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFD95C5C),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
