import 'package:BSA/Models/vehicle_expiry_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:BSA/Features/Vehicles/db/vehicle_db.dart';
import 'package:BSA/Features/Insurance/data/insurance_db.dart';
import 'package:BSA/Features/Salary/db/salary_db.dart';
import 'package:BSA/Features/Salary/db/deduction_db.dart';
import 'package:BSA/Features/jamaKharcha/db/transaction_db.dart';

import 'package:BSA/core/Controller/expiry_controller.dart';
import 'home_state.dart';

final homeProvider = FutureProvider<HomeState>((ref) async {
  // ---------------- Jama / Kharcha ----------------
  final txs = await TransactionDBHelper().getTransactions() ?? [];

  double jama = 0;
  double kharcha = 0;

  for (final tx in txs) {
    final amount = tx.amount ?? 0;

    if (tx.type == 'Income') {
      jama += amount;
    } else {
      kharcha += amount;
    }
  }

  // ---------------- Salary ----------------
  final totalSalary = (await SalaryDBHelper().getTotalSalary()) ?? 0;

  final totalDeduction = (await DeductionDBHelper().getTotalDeductions()) ?? 0;

  // ---------------- Expiry ----------------
  final vehicles = await VehicleDB.instance.fetchVehicles();
  final insurances = await InsuranceDB.instance.fetchAllInsurances();

  await ref
      .read(expiryProvider.notifier)
      .checkAllExpiry(vehicles: vehicles ?? [], insurances: insurances ?? []);

  final expiryList = ref.read(expiryProvider);

  final expiredCount =
      expiryList.isEmpty
          ? 0
          : expiryList
              .where(
                (e) =>
                    e.pucStatus == ExpiryStatus.expired ||
                    e.insuranceStatus == ExpiryStatus.expired,
              )
              .length;

  return HomeState(
    totalJama: jama,
    totalKharcha: kharcha,
    totalSalary: totalSalary,
    totalDeduction: totalDeduction,
    expiredCount: expiredCount,
  );
});
