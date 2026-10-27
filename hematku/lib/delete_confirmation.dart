import 'package:flutter/material.dart';

Future<bool?> showDeleteConfirmation(
  BuildContext context,
  String transactionName,
) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hapus Transaksi?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah kamu yakin ingin menghapus transaksi "$transactionName"?',
          style: const TextStyle(color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF245B4A)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD95C5C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Hapus'),
          ),
        ],
      );
    },
  );
}
