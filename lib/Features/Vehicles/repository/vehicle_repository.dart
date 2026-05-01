import 'package:BSA/Features/Vehicles/db/insurance_db.dart';
import 'package:BSA/Features/Vehicles/db/puc_db.dart';
import 'package:BSA/Features/Vehicles/db/vehicle_db.dart';
import 'package:BSA/Models/insurance_model.dart';
import 'package:BSA/Models/puc_model.dart';
import 'package:BSA/Models/vehicleWithStatus.dart';
import 'package:BSA/Models/vehicle_model.dart';

class VehicleRepository {
  VehicleRepository();

  final db = VehicleDB.instance;
  final idb = InsuranceDB.instance;
  final pDb = PucDb.instance;

  // =========================
  // 🔹 FETCH ALL
  // =========================

  Future<List<InsuranceModel>> fetchAllInsurances() async {
    return await idb.fetchAllInsurances();
  }

  Future<List<PucModel>> fetchAllPucs() async {
    return await pDb.fetchAllPucs();
  }

  Future<void> deleteVehicle(int id) async {
    await db.deleteVehicle(id);
  }
  // =========================
  // 🔹 PUC CRUD
  // =========================

  Future<void> insertPuc(PucModel puc) async {
    await pDb.insertPuc(puc);
  }

  Future<void> insertVehicle(VehicleModel vehicle) async {
    await db.insertVehicle(vehicle);
  }

  
   Future<void> updateVehicle(VehicleModel vehicle) async {
    await db.updateVehicle(vehicle);
  }

  Future<void> updatePuc(PucModel puc) async {
    await pDb.updatePuc(puc);
  }

  Future<void> deletePuc(int id) async {
    await pDb.deletePuc(id);
  }

  Future<List<PucModel>> getPucByVehicle(int vehicleId) async {
    final all = await pDb.fetchAllPucs();
    return all.where((p) => p.vehicleId == vehicleId).toList();
  }

  // =========================
  // 🔹 INSURANCE CRUD
  // =========================

  Future<void> insertInsurance(InsuranceModel ins) async {
    await idb.insertInsurance(ins);
  }

  Future<void> updateInsurance(InsuranceModel ins) async {
    await idb.updateInsurance(ins);
  }

  Future<void> deleteInsurance(int id) async {
    await idb.deleteInsurance(id);
  }

  Future<List<InsuranceModel>> getInsuranceByVehicle(int vehicleId) async {
    final all = await idb.fetchAllInsurances();
    return all.where((i) => i.vehicleId == vehicleId).toList();
  }

  // =========================
  // 🔹 VEHICLE STATUS (SSOT CORE)
  // =========================

  Future<List<VehicleStatus>> getVehiclesWithStatus() async {
    final vehicles = await db.fetchVehicles();
    final insurances = await idb.fetchAllInsurances();
    final pucs = await pDb.fetchAllPucs();

    List<VehicleStatus> result = [];

    for (var vehicle in vehicles) {
      final vehicleInsurances =
          insurances.where((i) => i.vehicleId == vehicle.id).toList()
            ..sort((a, b) => b.validUpto.compareTo(a.validUpto));

      final vehiclePucs =
          pucs.where((p) => p.vehicleId == vehicle.id).toList()
            ..sort((a, b) => b.validUpto.compareTo(a.validUpto));

      result.add(
        VehicleStatus(
          vehicle: vehicle,
          insurance:
              vehicleInsurances.isNotEmpty ? vehicleInsurances.first : null,
          puc: vehiclePucs.isNotEmpty ? vehiclePucs.first : null,
        ),
      );
    }

    return result;
  }

  // =========================
  // 🔹 OPTIONAL OPTIMIZATION (VERY USEFUL)
  // =========================

  Future<Map<int, List<PucModel>>> getPucGrouped() async {
    final all = await pDb.fetchAllPucs();
    Map<int, List<PucModel>> map = {};

    for (var p in all) {
      map.putIfAbsent(p.vehicleId, () => []).add(p);
    }

    return map;
  }

  Future<Map<int, List<InsuranceModel>>> getInsuranceGrouped() async {
    final all = await idb.fetchAllInsurances();
    Map<int, List<InsuranceModel>> map = {};

    for (var i in all) {
      map.putIfAbsent(i.vehicleId, () => []).add(i);
    }

    return map;
  }
}
