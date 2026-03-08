import 'package:BSA/Features/Vehicles/db/insurance_db.dart';
import 'package:BSA/Features/Vehicles/db/puc_db.dart';
import 'package:BSA/Features/Vehicles/db/vehicle_db.dart';
import 'package:BSA/Models/vehicleWithStatus.dart';

class VehicleRepository {
  VehicleRepository();

  final db = VehicleDB.instance;
  final idb = InsuranceDB.instance;
  final pDb = PucDb.instance;

  Future<List<VehicleStatus>> getVehiclesWithStatus() async {
    final vehicles = await db.fetchVehicles();
    final insurances = await idb.fetchAllInsurances();
    final pucs = await pDb.fetchAllPucs();

    List<VehicleStatus> result = [];

    for (var vehicle in vehicles) {
      final latestInsurance =
          insurances.where((i) => i.vehicleId == vehicle.id).toList()
            ..sort((a, b) => b.validUpto.compareTo(a.validUpto));

      final latestPuc =
          pucs.where((p) => p.vehicleId == vehicle.id).toList()
            ..sort((a, b) => b.validUpto.compareTo(a.validUpto));

      result.add(
        VehicleStatus(
          vehicle: vehicle,
          insurance: latestInsurance.isNotEmpty ? latestInsurance.first : null,
          puc: latestPuc.isNotEmpty ? latestPuc.first : null,
        ),
      );
    }

    return result;
  }
}
