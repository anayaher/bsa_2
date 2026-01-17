class TransactionModel {
  int? id;
  double amount;
  String type; // Income / Expense
  String payee;
  String head;
  DateTime date;

  TransactionModel({
    this.id,
    required this.amount,
    required this.type,
    required this.payee,
    required this.head,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'payee': payee,
      'head': head,
      'date': date.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'],
      payee: map['payee'],
      head: map['head'],
      date: DateTime.parse(map['date']),
    );
  }
}
