class GoldItem {
  final int? id;
  final String date;
  final String item;
  final String weight;
  final String jewellerName;
  final String rate;
  final String userName;
  final String gst;
  final String making;
  final String totalCost;
  final String? photoPath;

  GoldItem({
    this.id,
    required this.date,
    required this.item,
    required this.userName,
    required this.weight,
    required this.jewellerName,
    required this.rate,
    required this.gst,
    required this.making,
    required this.totalCost,
    this.photoPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'item': item,
      'userName': userName,
      'weight': weight,
      'jewellerName': jewellerName,
      'rate': rate,
      'gst': gst,
      'making': making,
      'totalCost': totalCost,
      'photoPath': photoPath,
    };
  }

  factory GoldItem.fromMap(Map<String, dynamic> map) {
    return GoldItem(
      id: map['id'],
      date: map['date'],
      item: map['item'],
      userName: map['userName'],

      weight: map['weight'],
      jewellerName: map['jewellerName'],
      rate: map['rate'],
      gst: map['gst'],
      making: map['making'],
      totalCost: map['totalCost'],
      photoPath: map['photoPath'],
    );
  }
}
