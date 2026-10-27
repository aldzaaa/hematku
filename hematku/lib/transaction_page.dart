import 'package:flutter/material.dart';

class TransactionPage extends StatelessWidget {
  const TransactionPage({super.key});

  String rupiah(int angka) {
    return 'Rp ${angka.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    const int pemasukan = 500000;
    const int pengeluaran = 275000;
    const int saldo = pemasukan - pengeluaran;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),

      // =========================
      // APP BAR
      // =========================
      appBar: AppBar(
        backgroundColor: const Color(0xFF245B4A),
        elevation: 0,
        title: const Text(
          'Transaksi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
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
            // FILTER BULAN
            // =========================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: 'Oktober 2026',
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: const [
                    DropdownMenuItem(
                      value: 'Oktober 2026',
                      child: Text('Oktober 2026'),
                    ),
                    DropdownMenuItem(
                      value: 'September 2026',
                      child: Text('September 2026'),
                    ),
                    DropdownMenuItem(
                      value: 'Agustus 2026',
                      child: Text('Agustus 2026'),
                    ),
                  ],
                  onChanged: (value) {},
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // RINGKASAN
            // =========================
            const Text(
              'Ringkasan Bulan Ini',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _summaryCard(
                    title: 'Pemasukan',
                    amount: pemasukan,
                    icon: Icons.arrow_downward,
                    iconColor: const Color(0xFF2E8B57),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _summaryCard(
                    title: 'Pengeluaran',
                    amount: pengeluaran,
                    icon: Icons.arrow_upward,
                    iconColor: const Color(0xFFD95C5C),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // =========================
            // SALDO
            // =========================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F2ED),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFF245B4A),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 14),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saldo Bulan Ini',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Rp 225.000',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(Icons.check_circle, color: Color(0xFF2E8B57)),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // =========================
            // JUDUL TRANSAKSI
            // =========================
            const Text(
              'Daftar Transaksi',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // =========================
            // TRANSAKSI 1
            // =========================
            _transactionItem(
              icon: Icons.restaurant,
              title: 'Makan Siang',
              category: 'Makanan',
              date: '06 Oktober 2026',
              amount: 25000,
              isIncome: false,
            ),

            // =========================
            // TRANSAKSI 2
            // =========================
            _transactionItem(
              icon: Icons.directions_car,
              title: 'Bensin',
              category: 'Transportasi',
              date: '05 Oktober 2026',
              amount: 50000,
              isIncome: false,
            ),

            // =========================
            // TRANSAKSI 3
            // =========================
            _transactionItem(
              icon: Icons.account_balance_wallet,
              title: 'Uang Saku',
              category: 'Pemasukan',
              date: '03 Oktober 2026',
              amount: 500000,
              isIncome: true,
            ),

            // =========================
            // TRANSAKSI 4
            // =========================
            _transactionItem(
              icon: Icons.school,
              title: 'Fotokopi Materi',
              category: 'Kuliah',
              date: '02 Oktober 2026',
              amount: 15000,
              isIncome: false,
            ),

            // =========================
            // TRANSAKSI 5
            // =========================
            _transactionItem(
              icon: Icons.fastfood,
              title: 'Jajan',
              category: 'Jajan',
              date: '01 Oktober 2026',
              amount: 20000,
              isIncome: false,
            ),
          ],
        ),
      ),

      // =========================
      // BOTTOM NAVIGATION
      // =========================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF245B4A),
        unselectedItemColor: Colors.grey,

        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/');
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
        onPressed: () {},
        backgroundColor: const Color(0xFF245B4A),
        child: const Icon(Icons.add, color: Colors.white),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // =========================================================
  // SUMMARY CARD
  // =========================================================
  Widget _summaryCard({
    required String title,
    required int amount,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: iconColor.withOpacity(0.12),
            child: Icon(icon, color: iconColor),
          ),

          const SizedBox(height: 10),

          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),

          const SizedBox(height: 4),

          Text(
            rupiah(amount),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // TRANSACTION ITEM
  // =========================================================
  Widget _transactionItem({
    required IconData icon,
    required String title,
    required String category,
    required String date,
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
            width: 48,
            height: 48,
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

                const SizedBox(height: 3),

                Text(
                  date,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
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
