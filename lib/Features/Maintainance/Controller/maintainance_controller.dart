import 'package:BSA/Features/Maintainance/Data/maintainance_db.dart';
import 'package:BSA/Models/maintainance_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';


class MaintenanceState {
  final bool loading;
  final List<MaintenanceModel> items;

  MaintenanceState({
    required this.loading,
    required this.items,
  });

  MaintenanceState copyWith({
    bool? loading,
    List<MaintenanceModel>? items,
  }) {
    return MaintenanceState(
      loading: loading ?? this.loading,
      items: items ?? this.items,
    );
  }
}

class MaintenanceNotifier extends StateNotifier<MaintenanceState> {
  MaintenanceNotifier()
      : super(MaintenanceState(loading: true, items: []));

  Future<void> load(int vehicleId) async {
    state = state.copyWith(loading: true);

    final data =
        await MaintenanceDB.instance.fetchMaintenanceByVehicle(vehicleId);

    state = state.copyWith(
      loading: false,
      items: data,
    );
  }

  Future<void> delete(int id, int vehicleId) async {
    await MaintenanceDB.instance.deleteMaintenance(id);
    await load(vehicleId);
  }
}

// GLOBAL PROVIDER
final maintenanceProvider =
    StateNotifierProvider<MaintenanceNotifier, MaintenanceState>(
  (ref) => MaintenanceNotifier(),
);
