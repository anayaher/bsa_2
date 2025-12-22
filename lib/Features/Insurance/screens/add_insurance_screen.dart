import 'dart:io';
import 'package:BSA/Features/Insurance/data/insurance_db.dart';
import 'package:BSA/Models/insurance_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddInsuranceScreen extends StatefulWidget {
  final int vehicleId;
  final InsuranceModel? insurance;

  const AddInsuranceScreen({
    super.key,
    required this.vehicleId,
    this.insurance,
  });

  @override
  State<AddInsuranceScreen> createState() => _AddInsuranceScreenState();
}

class _AddInsuranceScreenState extends State<AddInsuranceScreen> {
  DateTime? boughtDate;
  DateTime? validUpto;
  File? insurancePhoto;

  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.insurance != null) {
      boughtDate = DateTime.parse(widget.insurance!.buyDate);
      validUpto = DateTime.parse(widget.insurance!.validUpto);
      insurancePhoto = File(widget.insurance!.photoPath);
    }
  }

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => insurancePhoto = File(picked.path));
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

    if (insurancePhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Upload insurance photo"),
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
        title: Text(
          widget.insurance == null ? "Add Insurance" : "Update Insurance",
        ),
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
                    hintText: boughtDate != null
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
                    hintText: validUpto != null
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
                "Insurance Photo",
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
                child: insurancePhoto == null
                    ? const Center(
                        child: Text(
                          "Tap to upload photo",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(insurancePhoto!, fit: BoxFit.cover),
                      ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (!validate()) return;

                  // Save insurance here
                  final newInsurance = InsuranceModel(
                    vehicleId: widget.vehicleId,
                    buyDate: boughtDate!.toIso8601String(),
                    validUpto: validUpto!.toIso8601String(),
                    photoPath: insurancePhoto!.path,
                  );

                  // TODO: Insert/update to DB
                  if (widget.insurance == null) {
                    await InsuranceDB.instance.insertInsurance(newInsurance);
                  } else {
                    await InsuranceDB.instance.updateInsurance(newInsurance);
                  }

                  Navigator.pop(context, newInsurance);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  widget.insurance == null
                      ? "Add Insurance"
                      : "Update Insurance",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
