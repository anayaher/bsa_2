import 'package:BSA/Models/insurance_model.dart';
import 'package:BSA/Models/puc_model.dart';
import 'package:BSA/Models/vehicle_model.dart';

class VehicleStatus {
  final VehicleModel vehicle;
  final InsuranceModel? insurance;
  final PucModel? puc;

  VehicleStatus({required this.vehicle, this.insurance, this.puc});

  bool get isInsuranceExpired {
    DateTime validUptoFinal = DateTime.parse(insurance!.validUpto);

    return insurance == null || validUptoFinal.isBefore(DateTime.now());
  }




  bool get isPucExpired {
    DateTime validUptoFinal = DateTime.parse(puc!.validUpto);
  return   puc == null || validUptoFinal.isBefore(DateTime.now());
  }
    

  bool get hasAnyExpired => isInsuranceExpired || isPucExpired;
}
