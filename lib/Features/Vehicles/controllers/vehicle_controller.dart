import 'package:BSA/Features/Vehicles/repository/vehicle_repository.dart';
import 'package:BSA/Models/insurance_model.dart';
import 'package:BSA/Models/puc_model.dart';
import 'package:BSA/Models/vehicleWithStatus.dart';
import 'package:BSA/Models/vehicle_model.dart';
import 'package:get/get.dart';

class VehicleController extends GetxController {
  VehicleController();

  RxList<VehicleStatus> vehicles = <VehicleStatus>[].obs;

  RxList<InsuranceModel> insurances = <InsuranceModel>[].obs;

  RxList<PucModel> pucs = <PucModel>[].obs;

  final repo = VehicleRepository();

  @override
  void onInit() {
    loadVehicles();
    super.onInit();
  }

// UPDATE VEHICLE
Future<void> updateVehicle(VehicleModel vehicle) async {
  await repo.updateVehicle(vehicle);
  await loadVehicles();
}
  Future<void> deleteVehicle(int id) async {
  await repo.deleteVehicle(id);
  await loadVehicles();
}

  Future<void> loadVehicles() async {
    vehicles.value = await repo.getVehiclesWithStatus();

    // Load insurances and pucs separately for easier access in other screens
    insurances.value = await repo.fetchAllInsurances();
    pucs.value = await repo.fetchAllPucs();
  }

  List<VehicleStatus> get expiredVehicles =>
      vehicles.where((v) => v.hasAnyExpired).toList();

  List<VehicleStatus> get expiredInsurance =>
      vehicles.where((v) => v.isInsuranceExpired).toList();

  List<VehicleStatus> get expiredPuc =>
      vehicles.where((v) => v.isPucExpired).toList();

List<PucModel> getPucByVehicle(int vehicleId) {
  return pucs.where((p) => p.vehicleId == vehicleId).toList();
}


List<InsuranceModel> getInsuranceByVehicle(int vehicleId) {
  return insurances.where((i) => i.vehicleId == vehicleId).toList();
}
// ADD
Future<void> addPuc(PucModel puc) async {
  await repo.insertPuc(puc);
  await loadVehicles();
}

// UPDATE
Future<void> updatePuc(PucModel puc) async {
  await repo.updatePuc(puc);
  await loadVehicles();
}

// DELETE
Future<void> deletePuc(int id) async {
  await repo.deletePuc(id);
  await loadVehicles();
}

// EXPIRY CHECK
bool isPucExpired(PucModel puc) {
  return DateTime.parse(puc.validUpto).isBefore(DateTime.now());
}


// ADD
Future<void> addInsurance(InsuranceModel insurance) async {
  await repo.insertInsurance(insurance);
  await loadVehicles();
}

// UPDATE
Future<void> updateInsurance(InsuranceModel insurance) async {
  await repo.updateInsurance(insurance);
  await loadVehicles();
}

// DELETE
Future<void> deleteInsurance(int id) async {
  await repo.deleteInsurance(id);
  await loadVehicles();
}

// EXPIRY CHECK
bool isInsuranceExpired(InsuranceModel insurance) {
  return DateTime.parse(insurance.validUpto).isBefore(DateTime.now());
}
      
}

