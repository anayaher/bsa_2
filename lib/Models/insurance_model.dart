// lib/Features/Insurance/db/insurance_model.dart
class InsuranceModel {
  int? id;
  int vehicleId; // FK to Vehicle
  String buyDate;
  String validUpto;
  String photoPath;

  InsuranceModel({
    this.id,
    required this.vehicleId,
    required this.buyDate,
    required this.validUpto,
    required this.photoPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'buyDate': buyDate,
      'validUpto': validUpto,
      'photoPath': photoPath,
    };
  }

  factory InsuranceModel.fromMap(Map<String, dynamic> map) {
    return InsuranceModel(
      id: map['id'],
      vehicleId: map['vehicleId'],
      buyDate: map['buyDate'],
      validUpto: map['validUpto'],
      photoPath: map['photoPath'],
    );
  }
}
