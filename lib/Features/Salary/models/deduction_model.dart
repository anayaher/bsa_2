class DeductionModel {
  final int? id;
  final String title;
  final int amount;

  DeductionModel({
    this.id,
    required this.title,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
    };
  }

  factory DeductionModel.fromMap(Map<String, dynamic> map) {
    return DeductionModel(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
    );
  }
}
