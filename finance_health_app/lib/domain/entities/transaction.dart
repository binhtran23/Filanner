import 'package:equatable/equatable.dart';

/// Entity đại diện cho giao dịch (thu nhập hoặc chi tiêu)
class Transaction extends Equatable {
  final String id;
  final String userId;
  final TransactionType type;
  final String category;
  final double amount;
  final String? description;
  final DateTime transactionDate;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.category,
    required this.amount,
    this.description,
    required this.transactionDate,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    category,
    amount,
    description,
    transactionDate,
    createdAt,
  ];
}

/// Loại giao dịch
enum TransactionType {
  income('Thu nhập'),
  expense('Chi tiêu');

  final String label;
  const TransactionType(this.label);
}
