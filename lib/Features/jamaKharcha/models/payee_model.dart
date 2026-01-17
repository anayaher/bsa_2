class PayeeModel {
  final int? id;
  final String name;
  final String type; // e.g. Salary, Rent, Deduction, Expense

  PayeeModel({
    this.id,
    required this.name,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
    };
  }

  factory PayeeModel.fromMap(Map<String, dynamic> map) {
    return PayeeModel(
      id: map['id'],
      name: map['name'],
      type: map['type'],
    );
  }
}
