import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:BSA/Models/vehicle_model.dart';

class VehicleCard extends StatelessWidget {
  final dynamic vehicleWrapper; // your controller object (with flags)
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Function(String) onMenuSelect;

  const VehicleCard({
    super.key,
    required this.vehicleWrapper,
    required this.onTap,
    required this.onLongPress,
    required this.onMenuSelect,
  });

  @override
  Widget build(BuildContext context) {
    final vehicle = vehicleWrapper.vehicle;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.20),
                  Colors.white.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.25),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      /// IMAGE
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          "assets/images/bsa.png",
                          height: 65,
                          width: 65,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(width: 16),

                      /// INFO
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (vehicleWrapper.isInsuranceExpired)
                                  _badge("Insurance Expired"),
                                if (vehicleWrapper.isInsuranceExpired &&
                                    vehicleWrapper.isPucExpired)
                                  const SizedBox(width: 8),
                                if (vehicleWrapper.isPucExpired)
                                  _badge("PUC Expired"),
                              ],
                            ),

                            const SizedBox(height: 8),

                            Text(
                              vehicle.vehicleName,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              vehicle.regNumber,
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// MENU
          Positioned(
            top: 4,
            right: 4,
            child: PopupMenuButton<String>(
              color: Colors.grey[900],
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: onMenuSelect,
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'maintenance',
                  child: Text("View Maintenance",
                      style: TextStyle(color: Colors.white)),
                ),
                PopupMenuItem(
                  value: 'insurance',
                  child: Text("View Insurance",
                      style: TextStyle(color: Colors.white)),
                ),
                PopupMenuItem(
                  value: 'puc',
                  child: Text("View PUC",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.red.shade100,
      ),
      child: Text(text),
    );
  }
}