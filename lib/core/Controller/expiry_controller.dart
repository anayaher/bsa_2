import 'package:BSA/Models/insurance_model.dart';
import 'package:BSA/Models/puc_model.dart';
import 'package:BSA/Models/vehicle_expiry_model.dart';
import 'package:BSA/Models/vehicle_model.dart';
import 'package:flutter_riverpod/legacy.dart';

class ExpiryNotifier extends StateNotifier<List<VehicleExpiryStatus>> {
  ExpiryNotifier() : super([]);

  Future<void> checkPucExpiry({required List<PucModel> allPucs}) async{
 final today = DateTime.now();

 


  }

  /// Main function to call on startup
  Future<void> checkAllExpiry({
    required List<VehicleModel> vehicles,
    required List<InsuranceModel> insurances,
  }) async {
    final today = DateTime.now();
    List<VehicleExpiryStatus> result = [];

    for (var v in vehicles) {
      // --- PUC expiry ---

      // --- Insurance expiry ---
      final ins = insurances.firstWhere(
        (i) => i.vehicleId == v.id,
        orElse:
            () => InsuranceModel(
              vehicleId: v.id!,
              buyDate: "",
              validUpto: "3000-01-01",
              photoPath: "",
            ),
      );

      DateTime insExpiry = DateTime.parse(ins.validUpto);
      ExpiryStatus insuranceStatus;
      if (insExpiry.isBefore(today)) {
        insuranceStatus = ExpiryStatus.expired;
      } else if (insExpiry.difference(today).inDays <= 30) {
        insuranceStatus = ExpiryStatus.nearExpiry;
      } else {
        insuranceStatus = ExpiryStatus.valid;
      }

      // Add final status
      result.add(
        VehicleExpiryStatus(
          vehicleId: v.id!,
          pucStatus:
              ExpiryStatus.valid, // Placeholder, implement PUC logic similarly
          insuranceStatus: insuranceStatus,
        ),
      );
    }

    state = result;
  }
}

final expiryProvider =
    StateNotifierProvider<ExpiryNotifier, List<VehicleExpiryStatus>>(
      (ref) => ExpiryNotifier(),
    );
