import 'package:intl/intl.dart';
import '../../data/models/transaction_model.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/financial_profile.dart';

/// UTF-8 BOM for proper Vietnamese encoding in Excel
const String utf8Bom = '\uFEFF';

/// Entry thống nhất cho cả chi tiêu cố định và giao dịch
class ExpenseEntry {
  final String name;
  final String category;
  final double amount;
  final bool
  isRecurring; // true = chi tiêu cố định hàng tháng, false = giao dịch 1 lần
  final DateTime? transactionDate; // null cho chi tiêu cố định
  final TransactionType type; // income hoặc expense

  ExpenseEntry({
    required this.name,
    required this.category,
    required this.amount,
    required this.isRecurring,
    this.transactionDate,
    required this.type,
  });

  /// Chuyển đổi thành Map cho fixed expense
  Map<String, dynamic> toFixedExpenseMap() {
    return {'name': name, 'category': category, 'amount': amount};
  }

  /// Kiểm tra có phải chi tiêu cố định không
  bool get isFixedExpense => isRecurring && type == TransactionType.expense;

  /// Kiểm tra có phải giao dịch 1 lần không
  bool get isTransaction => !isRecurring;
}

/// Service để parse CSV file
class CsvParserService {
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  /// Parse unified CSV format (6 columns)
  /// Format: Date,Name,Category,Amount,Type,IsRecurring
  List<ExpenseEntry> parseUnifiedCsv(String csvContent) {
    final lines = csvContent.split('\n');
    final entries = <ExpenseEntry>[];

    // Skip header row
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      try {
        final row = _parseCsvRow(line);
        if (row.length >= 6) {
          final dateStr = row[0].trim();
          DateTime? transactionDate;

          if (dateStr.isNotEmpty) {
            try {
              transactionDate = _dateFormat.parse(dateStr);
            } catch (e) {
              // Try alternative format
              transactionDate = DateTime.tryParse(dateStr);
            }
          }

          entries.add(
            ExpenseEntry(
              transactionDate: transactionDate,
              name: row[1].trim(),
              category: row[2].trim(),
              amount: double.parse(row[3].trim().replaceAll(',', '')),
              type: row[4].trim().toLowerCase() == 'income'
                  ? TransactionType.income
                  : TransactionType.expense,
              isRecurring: row[5].trim().toLowerCase() == 'true',
            ),
          );
        }
      } catch (e) {
        print('Error parsing row $i: $e');
      }
    }

    return entries;
  }

  /// Parse CSV row, handling quoted values
  List<String> _parseCsvRow(String line) {
    final result = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    result.add(buffer.toString());

    return result;
  }

  /// Generate unified CSV template
  String generateUnifiedCsvTemplate() {
    return '''Date,Name,Category,Amount,Type,IsRecurring
,Tiền nhà,Nhà cửa,5000000,Expense,true
,Điện,Tiện ích,500000,Expense,true
,Nước,Tiện ích,100000,Expense,true
,Internet,Tiện ích,200000,Expense,true
01/01/2026,Cơm trưa,Ăn uống,50000,Expense,false
01/01/2026,Grab đi làm,Di chuyển,35000,Expense,false
05/01/2026,Lương tháng,Thu nhập,15000000,Income,false''';
  }

  /// Export entries to CSV format with UTF-8 BOM for Vietnamese support
  String exportToCsv(List<ExpenseEntry> entries) {
    final buffer = StringBuffer();
    // Add UTF-8 BOM for proper Vietnamese encoding in Excel
    buffer.write(utf8Bom);
    buffer.writeln('Date,Name,Category,Amount,Type,IsRecurring');

    for (final entry in entries) {
      final dateStr = entry.transactionDate != null
          ? _dateFormat.format(entry.transactionDate!)
          : '';
      final typeStr = entry.type == TransactionType.income
          ? 'Income'
          : 'Expense';
      // Escape values that might contain commas
      final escapedName = _escapeCSV(entry.name);
      final escapedCategory = _escapeCSV(entry.category);
      buffer.writeln(
        '$dateStr,$escapedName,$escapedCategory,${entry.amount},$typeStr,${entry.isRecurring}',
      );
    }

    return buffer.toString();
  }

  /// Export FixedExpense list to CSV format (for profile export)
  String exportFixedExpensesToCsv(List<FixedExpense> expenses) {
    final buffer = StringBuffer();
    // Add UTF-8 BOM for proper Vietnamese encoding in Excel
    buffer.write(utf8Bom);
    buffer.writeln('Date,Name,Category,Amount,Type,IsRecurring');

    for (final expense in expenses) {
      final escapedName = _escapeCSV(expense.name);
      final escapedCategory = _escapeCSV(expense.category);
      buffer.writeln(
        ',$escapedName,$escapedCategory,${expense.amount},Expense,true',
      );
    }

    return buffer.toString();
  }

  /// Escape CSV value if it contains comma, quote, or newline
  String _escapeCSV(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Lọc chi tiêu cố định từ danh sách entries
  List<ExpenseEntry> getFixedExpenses(List<ExpenseEntry> entries) {
    return entries.where((e) => e.isFixedExpense).toList();
  }

  /// Lọc giao dịch 1 lần từ danh sách entries
  List<ExpenseEntry> getTransactions(List<ExpenseEntry> entries) {
    return entries.where((e) => e.isTransaction).toList();
  }

  // ============ Legacy methods for backward compatibility ============

  /// Parse CSV content to list of transactions (legacy format)
  List<TransactionModel> parseCsv(String csvContent, String userId) {
    final lines = csvContent.split('\n');
    final transactions = <TransactionModel>[];

    // Skip header row
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      try {
        final row = line.split(',');
        if (row.length >= 5) {
          final transaction = TransactionModel.fromCsvRow(row, userId);
          transactions.add(transaction);
        }
      } catch (e) {
        // Skip invalid rows
        print('Error parsing row $i: $e');
      }
    }

    return transactions;
  }

  /// Generate sample CSV template (legacy format)
  String generateCsvTemplate() {
    return '''Date,Category,Description,Amount,Type
01/01/2026,Ăn uống,Cơm trưa,50000,Expense
01/01/2026,Di chuyển,Grab đi làm,35000,Expense
02/01/2026,Ăn uống,Cafe,45000,Expense
02/01/2026,Giải trí,Xem phim,180000,Expense
03/01/2026,Mua sắm,Quần áo,500000,Expense
05/01/2026,Thu nhập,Lương tháng,15000000,Income''';
  }
}
