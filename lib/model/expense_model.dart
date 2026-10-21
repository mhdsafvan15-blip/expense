class ExpenseModel {
  final int? id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? description;
  final String type;

  ExpenseModel({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.description,
    this.type = 'expense',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'description': description,
      'type': type,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      date: DateTime.parse(map['date'] as String),
      description: map['description'] as String?,
      type: map['type'] as String? ?? 'expense',
    );
  }
}
