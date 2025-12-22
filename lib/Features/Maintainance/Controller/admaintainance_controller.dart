import 'package:BSA/Features/Maintainance/Data/maintainance_db.dart';
import 'package:BSA/Models/maintainance_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class AddMaintenanceState {
  final bool isLoading;
  final String? error;

  const AddMaintenanceState({this.isLoading = false, this.error});

  AddMaintenanceState copyWith({bool? isLoading, String? error}) {
    return AddMaintenanceState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AddMaintenanceNotifier extends StateNotifier<AddMaintenanceState> {
  AddMaintenanceNotifier() : super(const AddMaintenanceState());

  Future<bool> addMaintenance(MaintenanceModel maintenance) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final id = await MaintenanceDB.instance.addMaintenance(maintenance);

      if (id > 0) {
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: "Failed to add maintenance",
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "Error: ${e.toString()}");
      return false;
    }
  }
}

final addMaintenanceProvider =
    StateNotifierProvider<AddMaintenanceNotifier, AddMaintenanceState>((ref) {
      return AddMaintenanceNotifier();
    });
