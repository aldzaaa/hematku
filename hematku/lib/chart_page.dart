import 'package:flutter/material.dart';

import 'database_helper.dart';
import 'transaction_model.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  late int selectedYear;
  List<TransactionModel> transactions = [];
  bool isLoading = true;
  Object? loadError;

  @override
  void initState() {
    super.initState();
    selectedYear = DateTime.now().year;
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      isLoading = true;
      loadError = null;
    });

    try {
      final data = await DatabaseHelper.instance.getTransactions();
      if (!mounted) return;

      setState(() {
        transactions = data;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        loadError = error;
        isLoading = false;
      });
    }
  }

  Future<void> _openAddTransaction() async {
    await Navigator.pushNamed(context, '/add-transaction');
    if (mounted) {
      await _loadTransactions();
    }
  }

  String rupiah(int angka) {
    return 'Rp ${angka.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
  }

  String _axisLabel(int amount) {
    if (amount < 1000) {
      return amount.toString();
    }
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}jt';
    }
    return '${(amount / 1000).round()}K';
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'makanan':
        return Icons.restaurant;
      case 'transportasi':
        return Icons.directions_car;
      case 'kuliah':
        return Icons.school;
      case 'jajan':
        return Icons.fastfood;
      default:
        return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    final yearTransactions = transactions
        .where((transaction) => transaction.date.year == selectedYear)
        .toList();
    final monthlyIncome = List<int>.filled(12, 0);
    final monthlyExpense = List<int>.filled(12, 0);
    final expenseByCategory = <String, int>{};

    for (final transaction in yearTransactions) {
      final monthIndex = transaction.date.month - 1;
      if (transaction.type == 'Pemasukan') {
        monthlyIncome[monthIndex] += transaction.amount;
      } else if (transaction.type == 'Pengeluaran') {
        monthlyExpense[monthIndex] += transaction.amount;
        expenseByCategory.update(
          transaction.category,
          (amount) => amount + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }
    }

    final totalExpense = expenseByCategory.values.fold<int>(
      0,
      (total, amount) => total + amount,
    );
    final maxMonthlyAmount = [
      ...monthlyIncome,
      ...monthlyExpense,
    ].fold<int>(0, (maximum, amount) => amount > maximum ? amount : maximum);
    final maxChartAmount = maxMonthlyAmount == 0 ? 1 : maxMonthlyAmount;
    final categories = expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),

      // =========================
      // APP BAR
      // =========================
      appBar: AppBar(
        backgroundColor: const Color(0xFF245B4A),
        elevation: 0,
        title: const Text(
          'Grafik Keuangan',
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : loadError != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Data grafik gagal dimuat.'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loadTransactions,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =========================
                  // FILTER TAHUN
                  // =========================
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: selectedYear,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: List.generate(6, (index) {
                          final year = DateTime.now().year - index;
                          return DropdownMenuItem(
                            value: year,
                            child: Text('Tahun $year'),
                          );
                        }),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedYear = value;
                            });
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // =========================
                  // GRAFIK PEMASUKAN & PENGELUARAN
                  // =========================
                  const Text(
                    'Pemasukan & Pengeluaran',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Perbandingan keuangan setiap bulan',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),

                  const SizedBox(height: 18),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      children: [
                        // LEGEND
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _legend(
                              color: const Color(0xFF2E8B57),
                              text: 'Pemasukan',
                            ),
                            const SizedBox(width: 25),
                            _legend(
                              color: const Color(0xFFD95C5C),
                              text: 'Pengeluaran',
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        // GRAFIK
                        SizedBox(
                          height: 260,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Y AXIS
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _axisLabel(maxChartAmount),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    _axisLabel(maxChartAmount * 2 ~/ 3),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    _axisLabel(maxChartAmount ~/ 3),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    '0',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(width: 12),

                              // BAR CHART
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    for (var month = 0; month < 12; month++)
                                      _monthBar(
                                        month: const [
                                          'Jan',
                                          'Feb',
                                          'Mar',
                                          'Apr',
                                          'Mei',
                                          'Jun',
                                          'Jul',
                                          'Agt',
                                          'Sep',
                                          'Okt',
                                          'Nov',
                                          'Des',
                                        ][month],
                                        income: monthlyIncome[month],
                                        expense: monthlyExpense[month],
                                        maxAmount: maxChartAmount,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // =========================
                  // REKAP KATEGORI
                  // =========================
                  const Text(
                    'Pengeluaran Berdasarkan Kategori',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Total pengeluaran tahun $selectedYear',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),

                  const SizedBox(height: 18),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      children: [
                        // DONUT SEDERHANA
                        SizedBox(
                          width: 170,
                          height: 170,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 150,
                                height: 150,
                                child: CircularProgressIndicator(
                                  value: totalExpense == 0
                                      ? 0
                                      : categories.first.value / totalExpense,
                                  strokeWidth: 28,
                                  backgroundColor: const Color(0xFFE7ECE9),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Color(0xFF245B4A),
                                      ),
                                ),
                              ),

                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Total',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    rupiah(totalExpense),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        if (categories.isEmpty)
                          Text(
                            'Belum ada data pengeluaran untuk tahun $selectedYear.',
                            style: const TextStyle(color: Colors.grey),
                          )
                        else
                          for (final entry in categories)
                            _categoryItem(
                              icon: _categoryIcon(entry.key),
                              category: entry.key,
                              amount: entry.value,
                              percentage:
                                  '${(entry.value / totalExpense * 100).round()}%',
                            ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

      // =========================
      // BOTTOM NAVIGATION
      // =========================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF245B4A),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/transaction');
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

      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTransaction,
        backgroundColor: const Color(0xFF245B4A),
        child: const Icon(Icons.add, color: Colors.white),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // =========================================================
  // LEGEND
  // =========================================================
  Widget _legend({required Color color, required String text}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // =========================================================
  // BAR
  // =========================================================
  Widget _monthBar({
    required String month,
    required int income,
    required int expense,
    required int maxAmount,
  }) {
    double barHeight(int amount) {
      if (amount == 0) return 2;
      return (amount / maxAmount * 190).clamp(2, 190).toDouble();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 190,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 7,
                height: barHeight(income),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E8B57),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),

              const SizedBox(width: 3),

              Container(
                width: 7,
                height: barHeight(expense),
                decoration: BoxDecoration(
                  color: const Color(0xFFD95C5C),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        Text(month, style: const TextStyle(fontSize: 9, color: Colors.grey)),
      ],
    );
  }

  // =========================================================
  // CATEGORY ITEM
  // =========================================================
  Widget _categoryItem({
    required IconData icon,
    required String category,
    required int amount,
    required String percentage,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F2ED),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF245B4A)),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 5),

                LinearProgressIndicator(
                  value: double.parse(percentage.replaceAll('%', '')) / 100,
                  minHeight: 5,
                  borderRadius: BorderRadius.circular(10),
                  backgroundColor: const Color(0xFFE7ECE9),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF245B4A),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                rupiah(amount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                percentage,
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
