import 'dart:io';
import 'package:BSA/Features/Vehicles/controllers/vehicle_controller.dart';
import 'package:BSA/Features/Vehicles/db/puc_db.dart';
import 'package:BSA/Models/puc_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AddPucScreen extends StatefulWidget {
  final int vehicleId;
  final PucModel? insurance;

  const AddPucScreen({super.key, required this.vehicleId, this.insurance});

  @override
  State<AddPucScreen> createState() => _AddPucScreenState();
}

class _AddPucScreenState extends State<AddPucScreen> {
  DateTime? boughtDate;
  DateTime? validUpto;
  File? pucPhoto;

  final ImagePicker picker = ImagePicker();
  final controller = Get.find<VehicleController>();

  @override
  void initState() {
    super.initState();
    if (widget.insurance != null) {
      boughtDate = DateTime.parse(widget.insurance!.buyDate);
      validUpto = DateTime.parse(widget.insurance!.validUpto);
      pucPhoto = File(widget.insurance!.photoPath);
    }
  }

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => pucPhoto = File(picked.path));
  }

  Future<void> save() async {
    if (!validate()) return;

    final puc = PucModel(
      id: widget.insurance?.id,
      vehicleId: widget.vehicleId,
      buyDate: boughtDate!.toIso8601String(),
      validUpto: validUpto!.toIso8601String(),
      photoPath: pucPhoto!.path,
    );

    if (widget.insurance == null) {
      await controller.addPuc(puc);
    } else {
      await controller.updatePuc(puc);
    }

    Navigator.pop(context);
  }

  Future<void> pickDate(Function(DateTime) onSelected) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1990),
      lastDate: DateTime(now.year + 20),
      initialDate: now,
    );
    if (picked != null) onSelected(picked);
  }

  bool validate() {
    if (boughtDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Select bought date"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (validUpto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Select expiry date"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (pucPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Upload PUC photo"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.insurance == null ? "Add PUC" : "Update PUC"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Bought Date
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Bought Date",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => pickDate((d) => setState(() => boughtDate = d)),
              child: AbsorbPointer(
                child: TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText:
                        boughtDate != null
                            ? boughtDate!.toIso8601String().split("T").first
                            : "Select bought date",
                    suffixIcon: const Icon(Icons.calendar_month),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Valid Upto
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Valid Upto",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => pickDate((d) => setState(() => validUpto = d)),
              child: AbsorbPointer(
                child: TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText:
                        validUpto != null
                            ? validUpto!.toIso8601String().split("T").first
                            : "Select expiry date",
                    suffixIcon: const Icon(Icons.calendar_month),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Insurance Photo
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "PUC Photo",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: pickImage,
              child: Container(
                height: 130,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade400),
                  color: Colors.grey.shade100,
                ),
                child:
                    pucPhoto == null
                        ? const Center(
                          child: Text(
                            "Tap to upload photo",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                        : ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(pucPhoto!, fit: BoxFit.cover),
                        ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  widget.insurance == null ? "Add PUC" : "Update PUC",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
