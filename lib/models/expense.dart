import 'package:flutter/foundation.dart';

class Expense {
  final int? id;
  final double amount;
  final String description;
  final String category;
  final DateTime date;

  Expense({
    this.id,
    required this.amount,
    required this.description,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'category': category,
      'date': date.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      amount: map['amount'],
      description: map['description'],
      category: map['category'],
      date: DateTime.parse(map['date']),
    );
  }
}