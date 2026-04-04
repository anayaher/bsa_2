import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:BSA/Models/vehicle_model.dart';

class VehicleCard extends StatelessWidget {
  final dynamic vehicleWrapper; // contains vehicle + status flags
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
                            /// 🔴 BADGES (only if expired)
                            if (vehicleWrapper.hasAnyExpired)
                              Row(
                                children: [
                                  if (vehicleWrapper.isInsuranceExpired)
                                    _badge(
                                      text: "Insurance Expired",
                                      color: Colors.red,
                                      icon: Icons.warning_rounded,
                                    ),

                                  if (vehicleWrapper.isInsuranceExpired &&
                                      vehicleWrapper.isPucExpired)
                                    const SizedBox(width: 6),

                                  if (vehicleWrapper.isPucExpired)
                                    _badge(
                                      text: "PUC Expired",
                                      color: Colors.red,
                                      icon: Icons.warning_rounded,
                                    ),
                                ],
                              ),

                            if (vehicleWrapper.hasAnyExpired)
                              const SizedBox(height: 6),

                            /// VEHICLE NAME
                            Text(
                              vehicle.vehicleName,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 5),

                            /// REG NUMBER
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
              itemBuilder:
                  (context) => const [
                    PopupMenuItem(
                      value: 'maintenance',
                      child: Text(
                        "View Maintenance",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'insurance',
                      child: Text(
                        "View Insurance",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'puc',
                      child: Text(
                        "View PUC",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔥 PREMIUM BADGE
  Widget _badge({
    required String text,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.25), color.withOpacity(0.10)],
        ),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
