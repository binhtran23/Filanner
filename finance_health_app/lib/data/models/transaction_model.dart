import '../../domain/entities/transaction.dart';

/// Model cho Transaction với JSON serialization
class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.userId,
    required DateTime date,
    required super.category,
    required super.description,
    required super.amount,
    required super.type,
    required super.createdAt,
  }) : super(transactionDate: date);

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'] as String),
      category: json['category'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': transactionDate.toIso8601String(),
      'category': category,
      'description': description,
      'amount': amount,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TransactionModel.fromCsvRow(List<String> row, String userId) {
    // CSV format: Date,Category,Description,Amount,Type
    final dateParts = row[0].split('/'); // DD/MM/YYYY
    final date = DateTime(
      int.parse(dateParts[2]),
      int.parse(dateParts[1]),
      int.parse(dateParts[0]),
    );

    return TransactionModel(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      date: date,
      category: row[1],
      description: row[2],
      amount: double.parse(row[3]),
      type: row[4].toLowerCase() == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      createdAt: DateTime.now(),
    );
  }
}
