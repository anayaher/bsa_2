class SalaryModel {
  int basic;
  int daPercent;
  int hraPercent;
  int daAmount;
  int hraAmount;
  int ta;
  int arrears;

  SalaryModel({
    required this.basic,
    required this.daPercent,
    required this.hraPercent,
    required this.daAmount,
    required this.hraAmount,
    required this.ta,
    required this.arrears,
  });

  Map<String, dynamic> toMap() {
    return {
      'basic': basic,
      'daPercent': daPercent,
      'hraPercent': hraPercent,
      'daAmount': daAmount,
      'hraAmount': hraAmount,
      'ta': ta,
      'arrears': arrears,
    };
  }

  factory SalaryModel.fromMap(Map<String, dynamic> map) {
    return SalaryModel(
      basic: map['basic'],
      daPercent: map['daPercent'],
      hraPercent: map['hraPercent'],
      daAmount: map['daAmount'],
      hraAmount: map['hraAmount'],
      ta: map['ta'],
      arrears: map['arrears'],
    );
  }
}
