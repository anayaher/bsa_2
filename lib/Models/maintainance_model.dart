class MaintenanceModel {
  final int? id;
  final int vehicleId;
  final String date; // YYYY-MM-DD
  final String maintenanceType;
  final double price;
  final String garage;
  final int? kms;

  MaintenanceModel({
    this.id,
    required this.vehicleId,
    required this.date,
    required this.maintenanceType,
    required this.price,
    required this.garage,
    this.kms,
  });

  // Convert to Map (for DB)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'date': date,
      'maintenanceType': maintenanceType,
      'price': price,
      'garage': garage,
      'kms': kms,
    };
  }

  // Convert DB Row → Model
  factory MaintenanceModel.fromMap(Map<String, dynamic> map) {
    return MaintenanceModel(
      id: map['id'],
      vehicleId: map['vehicleId'],
      date: map['date'],
      maintenanceType: map['maintenanceType'],
      price: map['price'] * 1.0,
      garage: map['garage'],
      kms: map['kms'],
    );
  }
}
