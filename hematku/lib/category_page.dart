import 'package:flutter/material.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  final List<Map<String, dynamic>> categories = const [
    {'name': 'Makanan', 'icon': Icons.restaurant},
    {'name': 'Transportasi', 'icon': Icons.directions_car},
    {'name': 'Kuliah', 'icon': Icons.school},
    {'name': 'Jajan', 'icon': Icons.fastfood},
    {'name': 'Lainnya', 'icon': Icons.more_horiz},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),

      // =========================
      // APP BAR
      // =========================
      appBar: AppBar(
        backgroundColor: const Color(0xFF245B4A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Pilih Kategori',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // =========================
      // BODY
      // =========================
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kategori Transaksi',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            const Text(
              'Pilih kategori untuk transaksi kamu',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),

            const SizedBox(height: 22),

            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];

                  return _categoryItem(
                    context,
                    name: category['name'],
                    icon: category['icon'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // CATEGORY ITEM
  // =========================
  Widget _categoryItem(
    BuildContext context, {
    required String name,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),

        // ICON
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F2ED),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: const Color(0xFF245B4A)),
        ),

        // NAMA KATEGORI
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),

        // PANAH
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),

        // PILIH KATEGORI
        onTap: () {
          Navigator.pop(context, name);
        },
      ),
    );
  }
}
