import 'package:flutter/material.dart';
import 'delete_confirmation.dart';

class EditTransactionPage extends StatefulWidget {
  const EditTransactionPage({super.key});

  @override
  State<EditTransactionPage> createState() => _EditTransactionPageState();
}

class _EditTransactionPageState extends State<EditTransactionPage> {
  final TextEditingController titleController = TextEditingController(
    text: 'Makan Siang',
  );

  final TextEditingController amountController = TextEditingController(
    text: '25000',
  );

  final TextEditingController noteController = TextEditingController(
    text: 'Makan siang di kampus',
  );

  String transactionType = 'Pengeluaran';
  String category = 'Makanan';

  DateTime selectedDate = DateTime(2026, 10, 6);

  // =========================
  // PILIH TANGGAL
  // =========================
  Future<void> selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // =========================
  // FORMAT TANGGAL
  // =========================
  String formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // =========================
  // SIMPAN PERUBAHAN
  // =========================
  void saveChanges() {
    if (titleController.text.trim().isEmpty) {
      showMessage('Keterangan harus diisi');
      return;
    }

    if (amountController.text.trim().isEmpty) {
      showMessage('Nominal harus diisi');
      return;
    }

    final int? amount = int.tryParse(amountController.text);

    if (amount == null || amount <= 0) {
      showMessage('Nominal harus lebih dari 0');
      return;
    }

    Navigator.pop(context);
  }

  // =========================
  // PESAN
  // =========================
  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    noteController.dispose();
    super.dispose();
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
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Edit Transaksi',
          style: TextStyle(fontWeight: FontWeight.bold),
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
            // JENIS TRANSAKSI
            // =========================
            const Text(
              'Jenis Transaksi',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _typeButton(
                    title: 'Pengeluaran',
                    icon: Icons.arrow_upward,
                    selected: transactionType == 'Pengeluaran',
                    color: const Color(0xFFD95C5C),
                    onTap: () {
                      setState(() {
                        transactionType = 'Pengeluaran';
                      });
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _typeButton(
                    title: 'Pemasukan',
                    icon: Icons.arrow_downward,
                    selected: transactionType == 'Pemasukan',
                    color: const Color(0xFF2E8B57),
                    onTap: () {
                      setState(() {
                        transactionType = 'Pemasukan';
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // =========================
            // KETERANGAN
            // =========================
            const Text(
              'Keterangan',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: titleController,
              decoration: _inputDecoration(
                hint: 'Keterangan transaksi',
                icon: Icons.edit_note,
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // NOMINAL
            // =========================
            const Text(
              'Nominal',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration(
                hint: 'Masukkan nominal',
                icon: Icons.payments_outlined,
                prefix: 'Rp ',
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // KATEGORI
            // =========================
            const Text(
              'Kategori',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: category,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'Makanan', child: Text('Makanan')),
                    DropdownMenuItem(
                      value: 'Transportasi',
                      child: Text('Transportasi'),
                    ),
                    DropdownMenuItem(value: 'Kuliah', child: Text('Kuliah')),
                    DropdownMenuItem(value: 'Jajan', child: Text('Jajan')),
                    DropdownMenuItem(value: 'Lainnya', child: Text('Lainnya')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        category = value;
                      });
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // TANGGAL
            // =========================
            const Text(
              'Tanggal',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            InkWell(
              onTap: selectDate,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: Color(0xFF245B4A),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(formatDate(selectedDate))),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // CATATAN
            // =========================
            const Text(
              'Catatan',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: noteController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tambahkan catatan',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // =========================
            // SIMPAN PERUBAHAN
            // =========================
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF245B4A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Simpan Perubahan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // =========================
            // BATAL
            // =========================
            SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Batal',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // =========================
            // HAPUS TRANSAKSI
            // =========================
            TextButton.icon(
              onPressed: () async {
                final result = await showDeleteConfirmation(
                  context,
                  'Makan Siang',
                );

                if (result == true) {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Transaksi berhasil dihapus')),
                  );
                }
              },
              icon: const Icon(Icons.delete_outline, color: Color(0xFFD95C5C)),
              label: const Text(
                'Hapus Transaksi',
                style: TextStyle(
                  color: Color(0xFFD95C5C),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () async {
                final result = await showDeleteConfirmation(
                  context,
                  'Makan Siang',
                );

                if (result == true) {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Transaksi berhasil dihapus')),
                  );
                }
              },
              icon: const Icon(Icons.delete_outline, color: Color(0xFFD95C5C)),
              label: const Text(
                'Hapus Transaksi',
                style: TextStyle(
                  color: Color(0xFFD95C5C),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // TYPE BUTTON
  // =========================================================
  Widget _typeButton({
    required String title,
    required IconData icon,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.10) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color : Colors.grey.shade200,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 7),
            Text(
              title,
              style: TextStyle(
                color: selected ? color : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // INPUT
  // =========================================================
  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    String? prefix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefix,
      prefixIcon: Icon(icon, color: const Color(0xFF245B4A)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF245B4A)),
      ),
    );
  }
}
