class Transaction {
  final int? id;
  final double amount;
  final String description;
  final String category;
  final String type; // 'expense' or 'income'
  final DateTime date;

  Transaction({
    this.id,
    required this.amount,
    required this.description,
    required this.category,
    required this.type,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'category': category,
      'type': type,
      'date': date.toIso8601String(),
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      amount: map['amount'],
      description: map['description'],
      category: map['category'],
      type: map['type'],
      date: DateTime.parse(map['date']),
    );
  }
}