import 'dart:io';
import 'package:BSA/Features/Insurance/data/insurance_db.dart';
import 'package:BSA/Models/insurance_model.dart';
import 'package:BSA/core/Controller/expiry_controller.dart';
import 'package:BSA/core/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'add_insurance_screen.dart';

class InsuranceListScreen extends ConsumerStatefulWidget {
  final int vehicleId;
  const InsuranceListScreen({super.key, required this.vehicleId});

  @override
  ConsumerState<InsuranceListScreen> createState() =>
      _InsuranceListScreenState();
}

class _InsuranceListScreenState extends ConsumerState<InsuranceListScreen> {
  bool isLoading = true;
  List<InsuranceModel> insurances = [];

  @override
  void initState() {
    super.initState();
    loadInsurances();
  }

  Future<void> loadInsurances() async {
    setState(() => isLoading = true);
    insurances = await InsuranceDB.instance.fetchInsurances(widget.vehicleId);
    setState(() => isLoading = false);
  }

  Future<void> deleteInsurance(int id) async {
    await InsuranceDB.instance.deleteInsurance(id);
    await loadInsurances();
  }

  void editInsurance(InsuranceModel insurance) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddInsuranceScreen(
          vehicleId: widget.vehicleId,
          insurance: insurance,
        ),
      ),
    ).then((_) => loadInsurances());
  }

  void showInsuranceMenu(InsuranceModel insurance) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text("Edit Insurance"),
                onTap: () {
                  Navigator.pop(context);
                  editInsurance(insurance);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Delete Insurance"),
                onTap: () {
                  Navigator.pop(context);
                  deleteInsurance(insurance.id!);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void viewImage(String path) {
    if (path.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.black),
          body: PhotoView(
            imageProvider: FileImage(File(path)),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),
        ),
      ),
    );
  }

  Widget buildInsuranceCard(InsuranceModel ins, {bool? isExpired}) {
    return GestureDetector(
      onLongPress: () => showInsuranceMenu(ins),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isExpired!
              ? Colors.red.withValues(alpha: 0.1)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Insurance Photo
            InkWell(
              onTap: () => viewImage(ins.photoPath),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ins.photoPath.isNotEmpty
                    ? Image.file(
                        File(ins.photoPath),
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: double.infinity,
                        height: 180,
                        color: Colors.grey.shade300,
                        child: const Icon(
                          Icons.image,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Start From: ${THelper.formatDate(ins.buyDate)}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Valid Upto:  ${THelper.formatDate(ins.validUpto)}",
              style: const TextStyle(
                color: Colors.deepOrange,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expiry = ref.watch(expiryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text("Insurance History")),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff1f1c2c), Color(0xff928dab)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : insurances.isEmpty
            ? const Center(
                child: Text(
                  "No insurance records",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              )
            : ListView.builder(
                itemCount: insurances.length,
                itemBuilder: (context, index) {
                  bool isExpired = expiry.any(
                    (r) => r.vehicleId == insurances[index].vehicleId,
                  );
                  return buildInsuranceCard(
                    insurances[index],
                    isExpired: isExpired,
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddInsuranceScreen(vehicleId: widget.vehicleId),
            ),
          ).then((_) => loadInsurances());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
