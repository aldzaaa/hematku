import 'package:flutter/material.dart';

import 'account_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.account,
    required this.onAccountUpdated,
  });

  final AccountModel account;
  final ValueChanged<AccountModel> onAccountUpdated;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late AccountModel _account;

  @override
  void initState() {
    super.initState();
    _account = widget.account;
  }

  Future<void> _editProfile(BuildContext context) async {
    final updated = await Navigator.pushNamed<AccountModel>(
      context,
      '/profile-info',
    );
    if (updated != null) {
      setState(() {
        _account = updated;
      });
      widget.onAccountUpdated(updated);
    }
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'HematKu',
      applicationVersion: '1.0.0',
      applicationIcon: const CircleAvatar(
        backgroundColor: Color(0xFFE8F2ED),
        child: Icon(Icons.account_balance_wallet, color: Color(0xFF245B4A)),
      ),
      children: const [
        Text('Aplikasi untuk membantu mencatat dan mengelola keuanganmu.'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF245B4A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: Color(0xFFE8F2ED),
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Color(0xFF245B4A),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _account.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _account.email,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _profileMenu(
              icon: Icons.account_circle_outlined,
              title: 'Informasi Profil',
              subtitle: 'Ubah nama dan email akun',
              onTap: () => _editProfile(context),
            ),
            _profileMenu(
              icon: Icons.category_outlined,
              title: 'Kategori Transaksi',
              subtitle: 'Kelola kategori keuangan',
              onTap: () => Navigator.pushNamed(context, '/category'),
            ),
            _profileMenu(
              icon: Icons.notifications_none,
              title: 'Notifikasi',
              subtitle: 'Atur pengingat transaksi dan ringkasan',
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
            _profileMenu(
              icon: Icons.settings_outlined,
              title: 'Pengaturan',
              subtitle: 'Notifikasi dan pengaturan akun',
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
            _profileMenu(
              icon: Icons.info_outline,
              title: 'Tentang Aplikasi',
              subtitle: 'Informasi mengenai HematKu',
              onTap: () => _showAbout(context),
            ),
            const SizedBox(height: 20),
            const Text(
              'HematKu',
              style: TextStyle(
                color: Color(0xFF245B4A),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Versi 1.0.0',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        selectedItemColor: const Color(0xFF245B4A),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/transaction');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/chart');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Grafik',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _profileMenu({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F2ED),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: const Color(0xFF245B4A)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
