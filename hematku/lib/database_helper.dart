import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'account_model.dart';
import 'transaction_model.dart';

const _passwordHashIterations = 120000;

String _derivePasswordHash(Map<String, String> parameters) {
  final key = utf8.encode(parameters['password']!);
  final salt = base64Url.decode(parameters['salt']!);
  final input = Uint8List(salt.length + 4)..setRange(0, salt.length, salt);
  input[input.length - 1] = 1;
  final hmac = Hmac(sha256, key);
  var block = hmac.convert(input).bytes;
  final result = List<int>.from(block);

  for (var iteration = 1; iteration < _passwordHashIterations; iteration++) {
    block = hmac.convert(block).bytes;
    for (var index = 0; index < result.length; index++) {
      result[index] ^= block[index];
    }
  }

  return base64Url.encode(result);
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB('hematku.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      return await databaseFactoryFfiWeb.openDatabase(
        filePath,
        options: OpenDatabaseOptions(
          version: 2,
          onCreate: _createDB,
          onUpgrade: _upgradeDB,
        ),
      );
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL COLLATE NOCASE UNIQUE,
        password_salt TEXT NOT NULL,
        password_hash TEXT NOT NULL,
        transaction_notifications INTEGER NOT NULL DEFAULT 1,
        monthly_summary_notifications INTEGER NOT NULL DEFAULT 1
      )
    ''');
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount INTEGER NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT NOT NULL,
        user_id INTEGER REFERENCES users(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT NOT NULL COLLATE NOCASE UNIQUE,
          password_salt TEXT NOT NULL,
          password_hash TEXT NOT NULL,
          transaction_notifications INTEGER NOT NULL DEFAULT 1,
          monthly_summary_notifications INTEGER NOT NULL DEFAULT 1
        )
      ''');
      await db.execute('ALTER TABLE transactions ADD COLUMN user_id INTEGER');
      await db.execute('''
        CREATE TABLE app_settings (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )
      ''');
    }
  }

  Future<AccountModel> createAccount({
    required String name,
    required String email,
    required String password,
  }) async {
    final db = await database;
    final normalizedEmail = email.trim().toLowerCase();
    final existing = await db.query(
      'users',
      columns: ['id'],
      where: 'email = ?',
      whereArgs: [normalizedEmail],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      throw StateError('Email sudah terdaftar.');
    }

    final salt = base64Url.encode(
      List<int>.generate(16, (_) => Random.secure().nextInt(256)),
    );
    final passwordHash = await compute(_derivePasswordHash, {
      'password': password,
      'salt': salt,
    });

    return db.transaction((txn) async {
      final id = await txn.insert('users', {
        'name': name.trim(),
        'email': normalizedEmail,
        'password_salt': salt,
        'password_hash': passwordHash,
      });
      await txn.update('transactions', {
        'user_id': id,
      }, where: 'user_id IS NULL');
      await _setActiveUser(txn, id);
      final user = await txn.query('users', where: 'id = ?', whereArgs: [id]);
      return AccountModel.fromMap(user.single);
    });
  }

  Future<AccountModel> login({
    required String email,
    required String password,
  }) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );
    if (result.isEmpty) {
      throw StateError('Email atau kata sandi salah.');
    }

    final row = result.single;
    final passwordHash = await compute(_derivePasswordHash, {
      'password': password,
      'salt': row['password_salt'] as String,
    });
    if (passwordHash != row['password_hash']) {
      throw StateError('Email atau kata sandi salah.');
    }

    await _setActiveUser(db, row['id'] as int);
    return AccountModel.fromMap(row);
  }

  Future<AccountModel?> getActiveAccount() async {
    final db = await database;
    final settings = await db.query(
      'app_settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: ['active_user_id'],
      limit: 1,
    );
    if (settings.isEmpty) return null;

    final userId = int.tryParse(settings.single['value'] as String);
    if (userId == null) return null;

    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    return result.isEmpty ? null : AccountModel.fromMap(result.single);
  }

  Future<void> logout() async {
    final db = await database;
    await db.delete(
      'app_settings',
      where: 'key = ?',
      whereArgs: ['active_user_id'],
    );
  }

  Future<AccountModel> updateProfile({
    required int userId,
    required String name,
    required String email,
  }) async {
    final db = await database;
    final normalizedEmail = email.trim().toLowerCase();
    final existing = await db.query(
      'users',
      columns: ['id'],
      where: 'email = ? AND id != ?',
      whereArgs: [normalizedEmail, userId],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      throw StateError('Email sudah digunakan akun lain.');
    }

    await db.update(
      'users',
      {'name': name.trim(), 'email': normalizedEmail},
      where: 'id = ?',
      whereArgs: [userId],
    );
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    return AccountModel.fromMap(result.single);
  }

  Future<AccountModel> updateNotificationSettings({
    required int userId,
    required bool transactionNotifications,
    required bool monthlySummaryNotifications,
  }) async {
    final db = await database;
    await db.update(
      'users',
      {
        'transaction_notifications': transactionNotifications ? 1 : 0,
        'monthly_summary_notifications': monthlySummaryNotifications ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    return AccountModel.fromMap(result.single);
  }

  Future<void> _setActiveUser(DatabaseExecutor db, int userId) async {
    await db.insert('app_settings', {
      'key': 'active_user_id',
      'value': userId.toString(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    final userId = await _activeUserId(db);
    final values = transaction.toMap()..['user_id'] = userId;
    return await db.insert('transactions', values);
  }

  Future<List<TransactionModel>> getTransactions() async {
    final db = await database;
    final userId = await _activeUserId(db);
    final result = await db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );

    return result.map((map) => TransactionModel.fromMap(map)).toList();
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await database;
    final userId = await _activeUserId(db);
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ? AND user_id = ?',
      whereArgs: [transaction.id, userId],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    final userId = await _activeUserId(db);
    return await db.delete(
      'transactions',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  Future<int> _activeUserId(DatabaseExecutor db) async {
    final rows = await db.query(
      'app_settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: ['active_user_id'],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw StateError('Silakan login terlebih dahulu.');
    }
    final userId = int.tryParse(rows.single['value'] as String);
    if (userId == null) {
      throw StateError('Sesi akun tidak valid. Silakan login kembali.');
    }
    return userId;
  }
}
