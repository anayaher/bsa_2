import 'package:BSA/Features/Vehicles/repository/vehicle_repository.dart';
import 'package:BSA/Models/vehicleWithStatus.dart';
import 'package:get/get.dart';

class VehicleController extends GetxController {
  VehicleController();

  RxList<VehicleStatus> vehicles = <VehicleStatus>[].obs;

  final repo = VehicleRepository();

  @override
  void onInit() {
    loadVehicles();
    super.onInit();
  }

  Future<void> loadVehicles() async {
    vehicles.value = await repo.getVehiclesWithStatus();
  }

  List<VehicleStatus> get expiredVehicles =>
      vehicles.where((v) => v.hasAnyExpired).toList();

  List<VehicleStatus> get expiredInsurance =>
      vehicles.where((v) => v.isInsuranceExpired).toList();

  List<VehicleStatus> get expiredPuc =>
      vehicles.where((v) => v.isPucExpired).toList();
}
