import 'dart:io';
import 'package:BSA/Features/Vehicles/controllers/vehicle_controller.dart';
import 'package:BSA/Features/Vehicles/screens/add_puc_screen.dart';
import 'package:BSA/Models/puc_model.dart';
import 'package:BSA/core/helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

class PucListScreen extends StatelessWidget {
  final int vehicleId;
  PucListScreen({super.key, required this.vehicleId});

  final controller = Get.find<VehicleController>();

  void showMenu(BuildContext context, PucModel puc) {
    showModalBottomSheet(
      context: context,
      builder:
          (_) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.blue),
                  title: const Text("Edit PUC"),
                  onTap: () {
                    Navigator.pop(context);
                    Get.to(
                      () => AddPucScreen(vehicleId: vehicleId, insurance: puc),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text("Delete PUC"),
                  onTap: () async {
                    Navigator.pop(context);
                    await controller.deletePuc(puc.id!);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void viewImage(BuildContext context, String path) {
    if (path.isEmpty) return;

    Get.to(
      () => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black),
        body: PhotoView(imageProvider: FileImage(File(path))),
      ),
    );
  }

  Widget buildCard(PucModel puc, BuildContext context) {
    final isExpired = controller.isPucExpired(puc);

    return GestureDetector(
      onLongPress: () => showMenu(context, puc),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:
              isExpired
                  ? Colors.red.withValues(alpha: 0.1)
                  : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => viewImage(Get.context!, puc.photoPath),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child:
                    puc.photoPath.isNotEmpty
                        ? Image.file(
                          File(puc.photoPath),
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                        : Container(
                          height: 180,
                          color: Colors.grey,
                          child: const Icon(Icons.image),
                        ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Start: ${THelper.formatDate(puc.buyDate)}",
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              "Expiry: ${THelper.formatDate(puc.validUpto)}",
              style: const TextStyle(color: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PUC History')),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff1f1c2c), Color(0xff928dab)],
          ),
        ),
        child: Obx(() {
          final pucs = controller.getPucByVehicle(vehicleId);

          if (pucs.isEmpty) {
            return const Center(
              child: Text(
                "No PUC records",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.builder(
            itemCount: pucs.length,
            itemBuilder: (_, i) => buildCard(pucs[i], context),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddPucScreen(vehicleId: vehicleId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
