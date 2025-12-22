enum ExpiryStatus { expired, nearExpiry, valid }

class VehicleExpiryStatus {
  final int vehicleId;
  final ExpiryStatus pucStatus;
  final ExpiryStatus insuranceStatus;

  VehicleExpiryStatus({
    required this.vehicleId,
    required this.pucStatus,
    required this.insuranceStatus,
  });
}
