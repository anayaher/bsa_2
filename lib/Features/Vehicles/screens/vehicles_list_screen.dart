import 'dart:io';
import 'dart:ui';
import 'package:BSA/Features/Insurance/screens/insurance_list_screen.dart';
import 'package:BSA/Features/Maintainance/screens/add_maintainance_screen.dart';
import 'package:BSA/Features/Maintainance/screens/maintainance_list_screen.dart';
import 'package:BSA/Features/Vehicles/controllers/vehicle_controller.dart';
import 'package:BSA/Features/Vehicles/db/vehicle_db.dart';
import 'package:BSA/Features/Vehicles/screens/puc_list_screen.dart';
import 'package:BSA/Models/vehicle_model.dart';
import 'package:BSA/core/Controller/expiry_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'vehicle_registration_screen.dart';

class VehiclesListScreen extends ConsumerStatefulWidget {
  const VehiclesListScreen({super.key});

  @override
  ConsumerState<VehiclesListScreen> createState() => _VehiclesListScreenState();
}

class _VehiclesListScreenState extends ConsumerState<VehiclesListScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  Future<void> deleteVehicle(int id) async {
    await VehicleDB.instance.deleteVehicle(id);
  }

  void editVehicle(VehicleModel vehicle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VehicleRegistrationScreen(vehicle: vehicle),
      ),
    );
  }

  void openMaintenance(VehicleModel v) {
    // TODO: Navigate to maintenance list screen
    // Navigator.push(context, MaterialPageRoute(builder: (_) => MaintenanceList(v.id!)));
  }

  void showVehicleMenu(VehicleModel v) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text("Edit Vehicle"),
                onTap: () {
                  Navigator.pop(context);
                  editVehicle(v);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Delete Vehicle"),
                onTap: () {
                  Navigator.pop(context);
                  deleteVehicle(v.id!);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vehicleController = Get.put(VehicleController());

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("My Vehicles"),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff1f1c2c), Color(0xff928dab)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Expanded(
                        child:
                            vehicleController.vehicles.isEmpty
                                ? const Center(
                                  child: Text(
                                    "No vehicles added yet",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                                : Obx(() {
                                  return ListView.separated(
                                    itemCount:
                                        vehicleController.vehicles.length,
                                    separatorBuilder:
                                        (_, __) => const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final vehicle =
                                          vehicleController.vehicles[index];

                                      final vehicleModel = vehicle.vehicle;

                                      final isExipred = vehicle.hasAnyExpired;

                                      return GestureDetector(
                                        onTap:
                                            () => editVehicle(vehicle.vehicle),
                                        onLongPress:
                                            () => showVehicleMenu(
                                              vehicle.vehicle,
                                            ),
                                        child: Stack(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                gradient: LinearGradient(
                                                  colors:
                                                      !isExipred
                                                          ? [
                                                            Colors.white
                                                                .withOpacity(
                                                                  0.20,
                                                                ),
                                                            Colors.white
                                                                .withOpacity(
                                                                  0.05,
                                                                ),
                                                          ]
                                                          : [
                                                            const Color.fromARGB(
                                                              255,
                                                              220,
                                                              15,
                                                              0,
                                                            ).withOpacity(0.50),
                                                            const Color.fromARGB(
                                                              255,
                                                              127,
                                                              7,
                                                              7,
                                                            ).withOpacity(0.5),
                                                          ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                border: Border.all(
                                                  color: Colors.white
                                                      .withOpacity(0.25),
                                                  width: 1.2,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.07),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 6),
                                                  ),
                                                ],
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: BackdropFilter(
                                                  filter: ImageFilter.blur(
                                                    sigmaX: 12,
                                                    sigmaY: 12,
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          14,
                                                        ),
                                                    child: Row(
                                                      children: [
                                                        // Vehicle Image
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                14,
                                                              ),
                                                          child: Image.asset(
                                                            "assets/images/bsa.png",
                                                            height: 65,
                                                            width: 65,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),

                                                        const SizedBox(
                                                          width: 16,
                                                        ),

                                                        // Vehicle info
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                vehicle
                                                                    .vehicle
                                                                    .vehicleName,
                                                                style: const TextStyle(
                                                                  fontSize: 19,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Text(
                                                                vehicle
                                                                    .vehicle
                                                                    .regNumber,
                                                                style: TextStyle(
                                                                  fontSize: 17,
                                                                  color: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                        0.8,
                                                                      ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),

                                                        // Maintenance button
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),

                                            // Menu button on top-right
                                            Positioned(
                                              top: 4,
                                              right: 4,
                                              child: PopupMenuButton<String>(
                                                color: Colors.grey[900],
                                                icon: const Icon(
                                                  Icons.more_vert,
                                                  color: Colors.white,
                                                ),
                                                onSelected: (value) {
                                                  if (value == 'maintenance') {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (
                                                              _,
                                                            ) => MaintenanceListScreen(
                                                              vehicle
                                                                  .vehicle
                                                                  .vehicleName,
                                                              vehicleId:
                                                                  vehicle
                                                                      .vehicle
                                                                      .id!,
                                                            ),
                                                      ),
                                                    );
                                                  }
                                                  if (value == 'insurance') {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (context) {
                                                          return InsuranceListScreen(
                                                            vehicleId:
                                                                vehicle
                                                                    .vehicle
                                                                    .id!,
                                                          );
                                                        },
                                                      ),
                                                    );
                                                  }
                                                  if (value == 'puc') {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (context) {
                                                          return PucListScreen(
                                                            vehicleId:
                                                                vehicle
                                                                    .vehicle
                                                                    .id!,
                                                          );
                                                        },
                                                      ),
                                                    );
                                                  }
                                                },
                                                itemBuilder:
                                                    (BuildContext context) => [
                                                      const PopupMenuItem(
                                                        value: 'maintenance',
                                                        child: Text(
                                                          'View Maintenance',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                      const PopupMenuItem(
                                                        value: 'insurance',
                                                        child: Text(
                                                          'View Insurance',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                      const PopupMenuItem(
                                                        value: 'puc',
                                                        child: Text(
                                                          'View PUC',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                }),
                      ),
                      const SizedBox(height: 20),

                      // Add New Vehicle Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => const VehicleRegistrationScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Add New Vehicle",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
