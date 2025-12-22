import 'package:BSA/Features/Maintainance/Controller/admaintainance_controller.dart';
import 'package:BSA/Models/maintainance_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AddMaintenanceScreen extends ConsumerStatefulWidget {
  final int vehicleId;

  const AddMaintenanceScreen({super.key, required this.vehicleId});

  @override
  ConsumerState createState() => _AddMaintenanceScreenState();
}

class _AddMaintenanceScreenState extends ConsumerState<AddMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();

  final dateCtrl = TextEditingController();
  final typeCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final garageCtrl = TextEditingController();
  final kmCtrl = TextEditingController();

  @override
  void dispose() {
    dateCtrl.dispose();
    typeCtrl.dispose();
    priceCtrl.dispose();
    garageCtrl.dispose();
    kmCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4C9AFF), // header
              onPrimary: Colors.white, // header text
              onSurface: Colors.black, // body text
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      dateCtrl.text = DateFormat("yyyy-MM-dd").format(picked);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final addState = ref.watch(addMaintenanceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: const Text(
          "Add Maintenance",
          style: TextStyle(
            color: Color(0xFF2D3142),
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2D3142)),
      ),

      body: Padding(
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),

            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label("Date"),

                  GestureDetector(
                    onTap: _pickDate,
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: dateCtrl,
                        decoration: _inputDecoration("Pick a date", icon: Icons.calendar_month),
                        validator: (v) => v!.isEmpty ? "Select a date" : null,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  _label("Maintenance Type"),
                  TextFormField(
                    controller: typeCtrl,
                    decoration: _inputDecoration("Eg. Oil Change, Tyre Change"),
                    validator: (v) => v!.isEmpty ? "Enter maintenance type" : null,
                  ),

                  const SizedBox(height: 16),
                  _label("Price"),
                  TextFormField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration("Enter price"),
                    validator: (v) => v!.isEmpty ? "Enter price" : null,
                  ),

                  const SizedBox(height: 16),
                  _label("Garage"),
                  TextFormField(
                    controller: garageCtrl,
                    decoration: _inputDecoration("Garage Name"),
                    validator: (v) => v!.isEmpty ? "Enter garage name" : null,
                  ),

                  const SizedBox(height: 16),
                  _label("Kilometers (optional)"),
                  TextFormField(
                    controller: kmCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration("KM Reading"),
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4C9AFF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: addState.isLoading
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) return;

                              final model = MaintenanceModel(
                                vehicleId: widget.vehicleId,
                                date: dateCtrl.text.trim(),
                                maintenanceType: typeCtrl.text.trim(),
                                price: double.parse(priceCtrl.text.trim()),
                                garage: garageCtrl.text.trim(),
                                kms: kmCtrl.text.isEmpty
                                    ? null
                                    : int.parse(kmCtrl.text.trim()),
                              );

                              final success = await ref
                                  .read(addMaintenanceProvider.notifier)
                                  .addMaintenance(model);

                              if (success && mounted) Navigator.pop(context, true);
                            },
                      child: addState.isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              "Add Maintenance",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF2D3142),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {IconData? icon}) {
    return InputDecoration(
      prefixIcon: icon != null ? Icon(icon, color: Color(0xFF4C9AFF)) : null,
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF9FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD9E2EC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4C9AFF), width: 1.4),
      ),
    );
  }
}
