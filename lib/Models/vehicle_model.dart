class VehicleModel {
  int? id;

  String vehicleName;
  String regNumber;
  String registrationDate;

  String purchaseDate;
  double purchasePrice;

  String vehiclePhoto;
  String rcFront;
  String rcBack;

  

  String pucDate;
  String pucValidUpto;
  String pucPhoto;

  String? chassis;
  String? engine;

  VehicleModel({
    this.id,
    required this.vehicleName,
    required this.regNumber,
    required this.registrationDate,
    required this.purchaseDate,
    required this.purchasePrice,
    required this.vehiclePhoto,
    required this.rcFront,
    required this.rcBack,
    required this.pucDate,
    required this.pucValidUpto,
    required this.pucPhoto,
    this.chassis,
    this.engine,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "vehicleName": vehicleName,
      "regNumber": regNumber,
      "registrationDate": registrationDate,
      "purchaseDate": purchaseDate,
      "purchasePrice": purchasePrice,
      "vehiclePhoto": vehiclePhoto,
      "rcFront": rcFront,
      "rcBack": rcBack,
      "pucDate": pucDate,
      "pucValidUpto": pucValidUpto,
      "pucPhoto": pucPhoto,
      "chassis": chassis,
      "engine": engine,
    };
  }

  factory VehicleModel.fromMap(Map<String, dynamic> map) {
    return VehicleModel(
      id: map["id"],
      vehicleName: map["vehicleName"],
      regNumber: map["regNumber"],
      registrationDate: map["registrationDate"],
      purchaseDate: map["purchaseDate"],
      purchasePrice: map["purchasePrice"],
      vehiclePhoto: map["vehiclePhoto"],
      rcFront: map["rcFront"],
      rcBack: map["rcBack"],
      pucDate: map["pucDate"],
      pucValidUpto: map["pucValidUpto"],
      pucPhoto: map["pucPhoto"],
      chassis: map["chassis"],
      engine: map["engine"],
    );
  }
}
