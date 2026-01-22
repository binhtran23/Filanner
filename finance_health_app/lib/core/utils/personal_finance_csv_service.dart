import '../../core/constants/enums.dart';
import '../../domain/entities/financial_goal.dart';
import '../../domain/entities/incidental_expense.dart';
import '../../domain/entities/mandatory_expense.dart';
import '../../domain/entities/personal_finance.dart';
import '../../domain/entities/user_profile.dart';

/// Service để import/export Personal Finance từ/ra CSV
class PersonalFinanceCsvService {
  /// Parse CSV content và tạo PersonalFinance object
  /// Format: Section,Field,Value1,Value2,Value3,...
  Future<PersonalFinance> importFromCsv(String csvContent) async {
    final lines = csvContent
        .split('\n')
        .where((line) => line.trim().isNotEmpty && !line.trim().startsWith('#'))
        .toList();

    // Parse user profile
    UserProfile? userProfile;
    final mandatoryExpenses = <MandatoryExpense>[];
    IncidentalExpense? incidentalExpense;
    final financialGoals = <FinancialGoal>[];

    int? age;
    String? occupation;
    MaritalStatus? maritalStatus;
    double? monthlyIncome;
    bool hasDebt = false;
    double? totalDebt;
    double? incidentalPercentage;

    for (var line in lines) {
      final parts = line.split(',');
      if (parts.length < 3) continue;

      final section = parts[0].trim();
      final field = parts[1].trim();
      final value = parts[2].trim();

      switch (section) {
        case 'USER_PROFILE':
          switch (field) {
            case 'Age':
              age = int.tryParse(value);
              break;
            case 'Occupation':
              occupation = value;
              break;
            case 'MaritalStatus':
              maritalStatus = _parseMaritalStatus(value);
              break;
            case 'MonthlyIncome':
              monthlyIncome = double.tryParse(value);
              break;
            case 'HasDebt':
              hasDebt = value.toLowerCase() == 'true';
              break;
            case 'TotalDebt':
              totalDebt = double.tryParse(value);
              if (totalDebt == 0) totalDebt = null;
              break;
          }
          break;

        case 'MANDATORY_EXPENSE':
          if (parts.length >= 5) {
            final name = field;
            final amount = double.tryParse(value);
            final frequency = _parseFrequency(parts[3].trim());
            final note = parts.length > 4 ? parts[4].trim() : null;

            if (amount != null && frequency != null) {
              mandatoryExpenses.add(
                MandatoryExpense(
                  id:
                      DateTime.now().millisecondsSinceEpoch.toString() +
                      mandatoryExpenses.length.toString(),
                  name: name,
                  estimatedAmount: amount,
                  frequency: frequency,
                  note: note?.isEmpty ?? true ? null : note,
                  createdAt: DateTime.now(),
                ),
              );
            }
          }
          break;

        case 'INCIDENTAL_EXPENSE':
          if (field == 'Percentage') {
            incidentalPercentage = double.tryParse(value);
          }
          break;

        case 'FINANCIAL_GOAL':
          if (parts.length >= 6) {
            final type = _parseGoalType(field);
            final customName = value.isEmpty ? null : value;
            final targetAmount = double.tryParse(parts[3].trim());
            final targetDate = _parseDate(parts[4].trim());
            final priority = int.tryParse(parts[5].trim()) ?? 3;

            if (type != null) {
              financialGoals.add(
                FinancialGoal(
                  id:
                      DateTime.now().millisecondsSinceEpoch.toString() +
                      financialGoals.length.toString(),
                  type: type,
                  customName: customName,
                  targetAmount: targetAmount,
                  targetDate: targetDate,
                  priority: priority,
                  createdAt: DateTime.now(),
                ),
              );
            }
          }
          break;
      }
    }

    // Create UserProfile
    if (age != null &&
        occupation != null &&
        maritalStatus != null &&
        monthlyIncome != null) {
      userProfile = UserProfile(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        age: age,
        occupation: occupation,
        maritalStatus: maritalStatus,
        monthlyIncome: monthlyIncome,
        hasDebt: hasDebt,
        totalDebt: totalDebt,
        createdAt: DateTime.now(),
      );
    } else {
      throw Exception('Missing required user profile fields');
    }

    // Create IncidentalExpense
    if (incidentalPercentage != null && monthlyIncome != null) {
      incidentalExpense = IncidentalExpense(
        percentage: incidentalPercentage,
        monthlyIncome: monthlyIncome,
      );
    } else {
      throw Exception('Missing incidental expense percentage');
    }

    // Create PersonalFinance
    return PersonalFinance(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userProfile: userProfile,
      mandatoryExpenses: mandatoryExpenses,
      incidentalExpense: incidentalExpense,
      financialGoals: financialGoals,
      createdAt: DateTime.now(),
    );
  }

  /// Export PersonalFinance object ra CSV content
  String exportToCsv(PersonalFinance personalFinance) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('# PERSONAL FINANCE TEMPLATE');
    buffer.writeln('# Format: Section,Field,Value');
    buffer.writeln(
      '# Instructions: Fill in the Value column. Do not modify Section and Field columns.',
    );
    buffer.writeln('# Date format: DD/MM/YYYY');
    buffer.writeln();

    // User Profile
    buffer.writeln('# USER PROFILE');
    final profile = personalFinance.userProfile;
    buffer.writeln('USER_PROFILE,Age,${profile.age}');
    buffer.writeln('USER_PROFILE,Occupation,${profile.occupation}');
    buffer.writeln(
      'USER_PROFILE,MaritalStatus,${_maritalStatusToString(profile.maritalStatus)}',
    );
    buffer.writeln('USER_PROFILE,MonthlyIncome,${profile.monthlyIncome}');
    buffer.writeln('USER_PROFILE,HasDebt,${profile.hasDebt}');
    buffer.writeln('USER_PROFILE,TotalDebt,${profile.totalDebt ?? 0}');
    buffer.writeln();

    // Mandatory Expenses
    buffer.writeln('# MANDATORY EXPENSES (Format: Name,Amount,Frequency,Note)');
    buffer.writeln('# Frequency: daily, weekly, monthly');
    for (var expense in personalFinance.mandatoryExpenses) {
      buffer.writeln(
        'MANDATORY_EXPENSE,${expense.name},${expense.estimatedAmount},${_frequencyToString(expense.frequency)},${expense.note ?? ""}',
      );
    }
    buffer.writeln();

    // Incidental Expense
    buffer.writeln('# INCIDENTAL EXPENSE');
    buffer.writeln(
      'INCIDENTAL_EXPENSE,Percentage,${personalFinance.incidentalExpense.percentage}',
    );
    buffer.writeln();

    // Financial Goals
    buffer.writeln(
      '# FINANCIAL GOALS (Format: Type,CustomName,TargetAmount,TargetDate,Priority)',
    );
    buffer.writeln(
      '# Type: emergencySavings, buyHouse, buyCar, travel, retirement, investment, payDebt, childEducation, wedding, business, other',
    );
    buffer.writeln('# Priority: 1-5 (1=highest)');
    for (var goal in personalFinance.financialGoals) {
      final dateStr = goal.targetDate != null
          ? _formatDate(goal.targetDate!)
          : '';
      buffer.writeln(
        'FINANCIAL_GOAL,${_goalTypeToString(goal.type)},${goal.customName ?? ""},${goal.targetAmount ?? ""},$dateStr,${goal.priority}',
      );
    }

    return buffer.toString();
  }

  // Helper methods
  MaritalStatus? _parseMaritalStatus(String value) {
    switch (value.toLowerCase()) {
      case 'single':
        return MaritalStatus.single;
      case 'married':
        return MaritalStatus.married;
      case 'divorced':
        return MaritalStatus.divorced;
      case 'widowed':
        return MaritalStatus.widowed;
      default:
        return null;
    }
  }

  String _maritalStatusToString(MaritalStatus status) {
    switch (status) {
      case MaritalStatus.single:
        return 'single';
      case MaritalStatus.married:
        return 'married';
      case MaritalStatus.divorced:
        return 'divorced';
      case MaritalStatus.widowed:
        return 'widowed';
    }
  }

  ExpenseFrequency? _parseFrequency(String value) {
    switch (value.toLowerCase()) {
      case 'daily':
        return ExpenseFrequency.daily;
      case 'weekly':
        return ExpenseFrequency.weekly;
      case 'monthly':
        return ExpenseFrequency.monthly;
      default:
        return null;
    }
  }

  String _frequencyToString(ExpenseFrequency frequency) {
    switch (frequency) {
      case ExpenseFrequency.daily:
        return 'daily';
      case ExpenseFrequency.weekly:
        return 'weekly';
      case ExpenseFrequency.monthly:
        return 'monthly';
    }
  }

  FinancialGoalType? _parseGoalType(String value) {
    switch (value.toLowerCase()) {
      case 'emergencysavings':
        return FinancialGoalType.emergencySavings;
      case 'buyhouse':
        return FinancialGoalType.buyHouse;
      case 'buycar':
        return FinancialGoalType.buyCar;
      case 'travel':
        return FinancialGoalType.travel;
      case 'retirement':
        return FinancialGoalType.retirement;
      case 'investment':
        return FinancialGoalType.investment;
      case 'paydebt':
        return FinancialGoalType.payDebt;
      case 'childeducation':
        return FinancialGoalType.childEducation;
      case 'wedding':
        return FinancialGoalType.wedding;
      case 'business':
        return FinancialGoalType.business;
      case 'other':
        return FinancialGoalType.other;
      default:
        return null;
    }
  }

  String _goalTypeToString(FinancialGoalType type) {
    switch (type) {
      case FinancialGoalType.emergencySavings:
        return 'emergencySavings';
      case FinancialGoalType.buyHouse:
        return 'buyHouse';
      case FinancialGoalType.buyCar:
        return 'buyCar';
      case FinancialGoalType.travel:
        return 'travel';
      case FinancialGoalType.retirement:
        return 'retirement';
      case FinancialGoalType.investment:
        return 'investment';
      case FinancialGoalType.payDebt:
        return 'payDebt';
      case FinancialGoalType.childEducation:
        return 'childEducation';
      case FinancialGoalType.wedding:
        return 'wedding';
      case FinancialGoalType.business:
        return 'business';
      case FinancialGoalType.other:
        return 'other';
    }
  }

  DateTime? _parseDate(String value) {
    if (value.isEmpty) return null;
    try {
      final parts = value.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
