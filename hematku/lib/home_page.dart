import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'transaction_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TransactionModel> transactions = [];

  int pemasukan = 0;
  int pengeluaran = 0;
  int saldo = 0;

  String rupiah(int angka) {
    return 'Rp ${angka.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
  }

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    final data = await DatabaseHelper.instance.getTransactions();

    int totalPemasukan = 0;
    int totalPengeluaran = 0;

    for (final transaction in data) {
      if (transaction.type == 'Pemasukan') {
        totalPemasukan += transaction.amount;
      } else {
        totalPengeluaran += transaction.amount;
      }
    }

    if (!mounted) return;

    setState(() {
      transactions = data;
      pemasukan = totalPemasukan;
      pengeluaran = totalPengeluaran;
      saldo = totalPemasukan - totalPengeluaran;
    });
  }

  IconData _transactionIcon(String category) {
    switch (category.toLowerCase()) {
      case 'makanan':
        return Icons.restaurant;
      case 'transportasi':
      case 'bensin':
        return Icons.directions_car;
      case 'kuliah':
        return Icons.school;
      case 'jajan':
        return Icons.fastfood;
      default:
        return Icons.account_balance_wallet;
    }
  }

  Future<void> _openAddTransaction() async {
    await Navigator.pushNamed(context, '/add-transaction');
    if (mounted) {
      await loadTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),

      // =========================
      // APP BAR
      // =========================
      appBar: AppBar(
        backgroundColor: const Color(0xFF245B4A),
        elevation: 0,
        title: const Text(
          'HematKu',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: Colors.white),
          ),
        ],
      ),

      // =========================
      // BODY
      // =========================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // SALDO CARD
            // =========================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFF245B4A),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sisa Saldo',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    rupiah(saldo),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 18),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: 0.55,
                      minHeight: 8,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFB8E0D2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    '55% dari pemasukan bulan ini',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // PEMASUKAN & PENGELUARAN
            // =========================
            Row(
              children: [
                Expanded(
                  child: _summaryCard(
                    icon: Icons.arrow_downward,
                    title: 'Pemasukan',
                    amount: pemasukan,
                    iconColor: const Color(0xFF2E8B57),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: _summaryCard(
                    icon: Icons.arrow_upward,
                    title: 'Pengeluaran',
                    amount: pengeluaran,
                    iconColor: const Color(0xFFD95C5C),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // =========================
            // TRANSAKSI TERBARU
            // =========================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transaksi Terbaru',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),

                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/transaction');
                  },
                  child: const Text(
                    'Lihat Semua',
                    style: TextStyle(color: Color(0xFF245B4A)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            if (transactions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'Belum ada transaksi. Tekan + untuk menambahkan.',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              for (final transaction in transactions.take(4))
                _transactionItem(
                  icon: _transactionIcon(transaction.category),
                  title: transaction.title,
                  category: transaction.category,
                  amount: transaction.amount,
                  isIncome: transaction.type == 'Pemasukan',
                ),
          ],
        ),
      ),

      // =========================
      // BOTTOM NAVIGATION
      // =========================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF245B4A),
        unselectedItemColor: Colors.grey,

        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacementNamed(context, '/transaction');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/chart');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/profile');
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
      // =========================
      // TAMBAH TRANSAKSI
      // =========================
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTransaction,
        backgroundColor: const Color(0xFF245B4A),
        child: const Icon(Icons.add, color: Colors.white),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // =========================================================
  // WIDGET SUMMARY CARD
  // =========================================================
  Widget _summaryCard({
    required IconData icon,
    required String title,
    required int amount,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: iconColor.withOpacity(0.12),
            child: Icon(icon, color: iconColor),
          ),

          const SizedBox(height: 12),

          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),

          const SizedBox(height: 5),

          Text(
            rupiah(amount),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // WIDGET TRANSAKSI
  // =========================================================
  Widget _transactionItem({
    required IconData icon,
    required String title,
    required String category,
    required int amount,
    required bool isIncome,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: isIncome
                  ? const Color(0xFFE5F4EC)
                  : const Color(0xFFFFE9E9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: isIncome
                  ? const Color(0xFF2E8B57)
                  : const Color(0xFFD95C5C),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  category,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

          Text(
            '${isIncome ? '+' : '-'} ${rupiah(amount)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isIncome
                  ? const Color(0xFF2E8B57)
                  : const Color(0xFFD95C5C),
            ),
          ),
        ],
      ),
    );
  }
}
