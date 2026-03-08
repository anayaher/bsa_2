// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class PucModel {
  int? id;
  int vehicleId; // FK to Vehicle
   String buyDate;
  String validUpto;
  
  String photoPath;
  PucModel({
    this.id,
    required this.vehicleId,
    required this.buyDate,
    required this.validUpto,
    required this.photoPath,
  });


  PucModel copyWith({
    int? id,
    int? vehicleId,
    String? buyDate,
    String? validUpto,
    String? photoPath,
  }) {
    return PucModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      buyDate: buyDate ?? this.buyDate,
      validUpto: validUpto ?? this.validUpto,
      photoPath: photoPath ?? this.photoPath,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'vehicleId': vehicleId,
      'validFrom': buyDate,
      'validUpto': validUpto,
      'photoPath': photoPath,
    };
  }

  factory PucModel.fromMap(Map<String, dynamic> map) {
    return PucModel(
      id: map['id'] != null ? map['id'] as int : null,
      vehicleId: map['vehicleId'] as int,
      buyDate: map['validFrom'] as String,
      validUpto: map['validUpto'] as String,
      photoPath: map['photoPath'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory PucModel.fromJson(String source) => PucModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PucModel(id: $id, vehicleId: $vehicleId, buyDate: $buyDate, validUpto: $validUpto, photoPath: $photoPath)';
  }

  @override
  bool operator ==(covariant PucModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.vehicleId == vehicleId &&
      other.buyDate == buyDate &&
      other.validUpto == validUpto &&
      other.photoPath == photoPath;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      vehicleId.hashCode ^
      buyDate.hashCode ^
      validUpto.hashCode ^
      photoPath.hashCode;
  }
}
