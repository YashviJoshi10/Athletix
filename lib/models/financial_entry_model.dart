import 'package:cloud_firestore/cloud_firestore.dart';

// Expense categories
enum ExpenseCategory {
  food,
  transport,
  groceries,
  rent,
  gifts,
  medicine,
  entertainment,
  savings,
  fitness,
  others,
}

// Income categories
enum IncomeCategory {
  salary,
  sponsorships,
  dividend_incomes,
  social_media,
  others,
}

String expenseCategoryToString(ExpenseCategory category) => category.toString().split('.').last;
ExpenseCategory expenseCategoryFromString(String value) => ExpenseCategory.values.firstWhere((e) => expenseCategoryToString(e) == value);

String incomeCategoryToString(IncomeCategory category) => category.toString().split('.').last;
IncomeCategory incomeCategoryFromString(String value) => IncomeCategory.values.firstWhere((e) => incomeCategoryToString(e) == value);

class FinancialEntry {
  final String id;
  final String type; // 'income' or 'expense'
  final String category; // Will be handled as enum in UI, but stored as string
  final double amount;
  final DateTime date;
  final String? notes;

  FinancialEntry({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'category': category,
      'amount': amount,
      'date': date,
      'notes': notes,
    };
  }

  factory FinancialEntry.fromMap(String id, Map<String, dynamic> map) {
    return FinancialEntry(
      id: id,
      type: map['type'],
      category: map['category'],
      amount: (map['amount'] as num).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      notes: map['notes'],
    );
  }
}