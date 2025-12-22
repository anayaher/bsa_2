import 'dart:io';
import 'package:BSA/Features/Insurance/data/insurance_db.dart';
import 'package:BSA/Features/Vehicles/db/vehicle_db.dart';
import 'package:BSA/Models/insurance_model.dart';
import 'package:BSA/Models/vehicle_model.dart';
import 'package:BSA/core/Common/photo_viewer.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class VehicleRegistrationScreen extends StatefulWidget {
  final VehicleModel? vehicle;
  const VehicleRegistrationScreen({super.key, this.vehicle});

  @override
  State<VehicleRegistrationScreen> createState() =>
      _VehicleRegistrationScreenState();
}

class _VehicleRegistrationScreenState extends State<VehicleRegistrationScreen> {
  bool validateForm() {
    if (vehiclePhoto == null) {
      showError("Please upload vehicle photo");
      return false;
    }

    if (vehicleNameCtrl.text.trim().isEmpty) {
      showError("Vehicle name is required");
      return false;
    }

    if (regNumberCtrl.text.trim().length < 6) {
      showError("Enter a valid registration number");
      return false;
    }

    if (registrationDate == null) {
      showError("Select registration date");
      return false;
    }

    if (vehiclePurchaseDate == null) {
      showError("Select purchase date");
      return false;
    }

    if (purchasePriceCtrl.text.trim().isEmpty ||
        double.tryParse(purchasePriceCtrl.text.trim()) == null) {
      showError("Enter a valid purchase price");
      return false;
    }

    // RC book images
    if (rcFront == null || rcBack == null) {
      showError("Please upload RC book (front and back)");
      return false;
    }

    // Insurance details
    if (insuranceBuyDate == null ||
        insuranceValidUpto == null ||
        insurancePhoto == null) {
      showError("Complete insurance details");
      return false;
    }

    // PUC details
    if (pucDate == null || pucValidUpto == null || pucPhoto == null) {
      showError("Complete PUC details");
      return false;
    }

    return true;
  }

  void showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  final TextEditingController vehicleNameCtrl = TextEditingController();
  final TextEditingController regNumberCtrl = TextEditingController();
  final TextEditingController chassisCtrl = TextEditingController();
  final TextEditingController engineCtrl = TextEditingController();
  final TextEditingController purchasePriceCtrl = TextEditingController();

  DateTime? vehiclePurchaseDate;
  DateTime? registrationDate;
  DateTime? insuranceBuyDate;
  DateTime? insuranceValidUpto;
  DateTime? pucDate;
  DateTime? pucValidUpto;

  // ✔ Photos
  File? vehiclePhoto;
  File? rcFront;
  File? rcBack;
  File? insurancePhoto;
  File? pucPhoto;

  // ------------------ IMAGE PICKER ------------------
  Future<void> pickImage(Function(File) onSelected) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      onSelected(File(picked.path));
    }
  }

  // ------------------ DATE PICKER ------------------
  Future<void> pickDate(
    BuildContext context,
    Function(DateTime) onSelected,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1990),
      lastDate: DateTime(now.year + 20),
      initialDate: now,
    );
    if (picked != null) onSelected(picked);
  }

  // ------------------ UI HELPERS ------------------
  Widget buildImagePicker(String title, File? file, Function() onPick) {
    return InkWell(
      onTap: file == null
          ? onPick
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FullImageViewer(image: file)),
              );
            },
      onLongPress: () {
        // allow replacing image
        onPick();
      },
      child: Container(
        height: 230,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade400),
          color: Colors.grey.shade100,
        ),
        child: Stack(
          children: [
            file == null
                ? Center(
                    child: Text(
                      title,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(
                      file,
                      fit: BoxFit.contain,
                      width: double.infinity,
                    ),
                  ),

            // Edit icon overlay
            if (file != null)
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(
    String hint,
    TextEditingController ctrl, {
    bool isCaps = false,
  }) {
    return TextField(
      inputFormatters: isCaps ? [UpperCaseTextFormatter()] : null,
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(width: 1.8, color: Colors.blue),
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 12,
        ),
      ),
    );
  }

  Widget buildDateField(String label, DateTime? selected, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextField(
          readOnly: true,
          decoration: InputDecoration(
            hintText: selected == null
                ? label
                : selected.toString().split(" ").first,
            suffixIcon: const Icon(Icons.calendar_month),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Widget buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.vehicle != null) {
      _loadInsuraceDetails();
      final v = widget.vehicle!;

      vehicleNameCtrl.text = v.vehicleName;
      regNumberCtrl.text = v.regNumber;
      purchasePriceCtrl.text = v.purchasePrice.toString();
      chassisCtrl.text = v.chassis ?? "";
      engineCtrl.text = v.engine ?? "";

      registrationDate = DateTime.parse(v.registrationDate);
      vehiclePurchaseDate = DateTime.parse(v.purchaseDate);
      //  insuranceBuyDate = DateTime.parse(v.insuranceBuyDate);
      // insuranceValidUpto = DateTime.parse(v.insuranceValidUpto);
      pucDate = DateTime.parse(v.pucDate);
      pucValidUpto = DateTime.parse(v.pucValidUpto);

      vehiclePhoto = File(v.vehiclePhoto);
      rcFront = File(v.rcFront);
      rcBack = File(v.rcBack);
      // insurancePhoto = File(v.insurancePhoto);
      pucPhoto = File(v.pucPhoto);
    }
  }

  // ------------------ BUILD ------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.vehicle != null
              ? widget.vehicle!.vehicleName
              : "Register Vehicle",
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildSection("Vehicle Photo", [
              buildImagePicker("Tap to upload vehicle photo", vehiclePhoto, () {
                pickImage((file) {
                  setState(() => vehiclePhoto = file);
                });
              }),
            ]),

            buildSection("Vehicle Basic Details", [
              const Text("Vehicle Name"),
              const SizedBox(height: 6),
              buildTextField("Eg. Honda Activa", vehicleNameCtrl),
              const SizedBox(height: 16),

              const Text("Registration Number"),
              const SizedBox(height: 6),
              buildTextField("Eg. MH01 AB 1234", regNumberCtrl, isCaps: true),
              const SizedBox(height: 16),

              const Text("Date of Registration"),
              const SizedBox(height: 6),
              buildDateField(
                "Choose date",
                registrationDate,
                () => pickDate(context, (d) {
                  setState(() => registrationDate = d);
                }),
              ),
            ]),

            buildSection("Purchase Info", [
              const Text("Purchase Date"),
              const SizedBox(height: 6),
              buildDateField(
                "Select purchase date",
                vehiclePurchaseDate,
                () => pickDate(context, (d) {
                  setState(() => vehiclePurchaseDate = d);
                }),
              ),
              const SizedBox(height: 16),

              const Text("Purchase Price"),
              const SizedBox(height: 6),
              buildTextField("Eg. 72,000", purchasePriceCtrl),
            ]),

            buildSection("RC Book Photos", [
              const Text("Front"),
              const SizedBox(height: 6),
              buildImagePicker("Tap to upload RC Front", rcFront, () {
                pickImage((file) {
                  setState(() => rcFront = file);
                });
              }),
              const SizedBox(height: 16),

              const Text("Back"),
              const SizedBox(height: 6),
              buildImagePicker("Tap to upload RC Back", rcBack, () {
                pickImage((file) {
                  setState(() => rcBack = file);
                });
              }),
            ]),

            buildSection("Insurance Details", [
              const Text("Bought Date"),
              const SizedBox(height: 6),
              buildDateField("Select bought date", insuranceBuyDate, () {
                pickDate(context, (d) {
                  setState(() => insuranceBuyDate = d);
                });
              }),
              const SizedBox(height: 16),

              const Text("Valid Upto"),
              const SizedBox(height: 6),
              buildDateField("Select valid upto", insuranceValidUpto, () {
                pickDate(context, (d) {
                  setState(() => insuranceValidUpto = d);
                });
              }),
              const SizedBox(height: 16),

              const Text("Insurance Photo"),
              const SizedBox(height: 6),
              buildImagePicker(
                "Tap to upload insurance photo",
                insurancePhoto,
                () {
                  pickImage((file) {
                    setState(() => insurancePhoto = file);
                  });
                },
              ),
            ]),

            buildSection("PUC Details", [
              const Text("Bought Date"),
              const SizedBox(height: 6),
              buildDateField("Select date", pucDate, () {
                pickDate(context, (d) {
                  setState(() => pucDate = d);
                });
              }),
              const SizedBox(height: 16),

              const Text("Valid Upto"),
              const SizedBox(height: 6),
              buildDateField("Select date", pucValidUpto, () {
                pickDate(context, (d) {
                  setState(() => pucValidUpto = d);
                });
              }),
              const SizedBox(height: 16),

              const Text("PUC Photo"),
              const SizedBox(height: 6),
              buildImagePicker("Tap to upload PUC photo", pucPhoto, () {
                pickImage((file) {
                  setState(() => pucPhoto = file);
                });
              }),
            ]),

            buildSection("Optional Details", [
              const Text("Chassis Number"),
              const SizedBox(height: 6),
              buildTextField("Enter chassis number", chassisCtrl),
              const SizedBox(height: 16),

              const Text("Engine Number"),
              const SizedBox(height: 6),
              buildTextField("Enter engine number", engineCtrl),
            ]),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (!validateForm()) return;

                  VehicleModel model = VehicleModel(
                    id: widget.vehicle?.id, // <--- IMPORTANT
                    vehicleName: vehicleNameCtrl.text.trim(),
                    regNumber: regNumberCtrl.text.trim(),
                    registrationDate: registrationDate!.toIso8601String(),
                    purchaseDate: vehiclePurchaseDate!.toIso8601String(),
                    purchasePrice: double.parse(purchasePriceCtrl.text.trim()),
                    vehiclePhoto: vehiclePhoto!.path,
                    rcFront: rcFront!.path,
                    rcBack: rcBack!.path,
                    pucDate: pucDate!.toIso8601String(),
                    pucValidUpto: pucValidUpto!.toIso8601String(),
                    pucPhoto: pucPhoto!.path,
                    chassis: chassisCtrl.text.trim().isEmpty
                        ? null
                        : chassisCtrl.text.trim(),
                    engine: engineCtrl.text.trim().isEmpty
                        ? null
                        : engineCtrl.text.trim(),
                  );

                  int vId;
                  if (widget.vehicle == null) {
                    // INSERT
                    vId = await VehicleDB.instance.insertVehicle(model);

                    // 2️⃣ Insert initial insurance record
                    InsuranceModel insurance = InsuranceModel(
                      vehicleId: vId,
                      buyDate: insuranceBuyDate!.toIso8601String(),
                      validUpto: insuranceValidUpto!.toIso8601String(),
                      photoPath: insurancePhoto!.path,
                    );

                    await InsuranceDB.instance.insertInsurance(insurance);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          widget.vehicle == null
                              ? "Vehicle Added"
                              : "Vehicle Updated",
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    // UPDATE
                    await VehicleDB.instance.updateVehicle(model);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Vehicle Updated"),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  }

                  Navigator.pop(context);
                },

                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(widget.vehicle == null ? "Submit" : "Update"),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _loadInsuraceDetails() async {
    if (widget.vehicle == null) return;

    // Fetch all insurances for this vehicle
    List<InsuranceModel> insurances = await InsuranceDB.instance
        .fetchInsurances(widget.vehicle!.id!);

    if (insurances.isNotEmpty) {
      // Assuming the first record is the latest because fetchInsurances orders by buyDate DESC
      final latest = insurances.last;

      setState(() {
        insuranceBuyDate = DateTime.parse(latest.buyDate);
        insuranceValidUpto = DateTime.parse(latest.validUpto);
        insurancePhoto = File(latest.photoPath);
      });
    }
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
