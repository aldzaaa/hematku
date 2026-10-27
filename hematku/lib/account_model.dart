class AccountModel {
  final int id;
  final String name;
  final String email;
  final bool transactionNotifications;
  final bool monthlySummaryNotifications;

  const AccountModel({
    required this.id,
    required this.name,
    required this.email,
    required this.transactionNotifications,
    required this.monthlySummaryNotifications,
  });

  factory AccountModel.fromMap(Map<String, Object?> map) {
    return AccountModel(
      id: map['id'] as int,
      name: map['name'] as String,
      email: map['email'] as String,
      transactionNotifications: map['transaction_notifications'] == 1,
      monthlySummaryNotifications: map['monthly_summary_notifications'] == 1,
    );
  }

  AccountModel copyWith({
    String? name,
    String? email,
    bool? transactionNotifications,
    bool? monthlySummaryNotifications,
  }) {
    return AccountModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      transactionNotifications:
          transactionNotifications ?? this.transactionNotifications,
      monthlySummaryNotifications:
          monthlySummaryNotifications ?? this.monthlySummaryNotifications,
    );
  }
}
