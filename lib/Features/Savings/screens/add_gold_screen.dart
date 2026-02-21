import 'dart:io';

import 'package:BSA/Features/Savings/gold_db.dart';
import 'package:BSA/Features/Savings/gold_item.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

Future<String> saveImagePermanently(File image) async {
  final dir = await getApplicationDocumentsDirectory();
  final fileName = DateTime.now().millisecondsSinceEpoch.toString();
  final savedImage = await image.copy('${dir.path}/$fileName.jpg');
  return savedImage.path;
}

class AddEditGoldScreen extends StatefulWidget {
  final GoldItem? goldItem;
  const AddEditGoldScreen({super.key, this.goldItem});

  @override
  State<AddEditGoldScreen> createState() => _AddEditGoldScreenState();
}

class _AddEditGoldScreenState extends State<AddEditGoldScreen> {
  final _formKey = GlobalKey<FormState>();

  File? _image;

  final name = TextEditingController();
  final jewellerName = TextEditingController();
  final userName = TextEditingController();

  final weight = TextEditingController();
  final rate = TextEditingController();
  final makingPerGram = TextEditingController();
  final gst = TextEditingController();
  final total = TextEditingController();
  final dateController = TextEditingController();

  final goldValueCtrl = TextEditingController();
  final makingTotalCtrl = TextEditingController();
  final gstAmountCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final g = widget.goldItem;

    dateController.text = g?.date ?? DateTime.now().toString().split(' ')[0];
    weight.text = g?.weight ?? '';
    rate.text = g?.rate ?? '';
    name.text = g?.item ?? '';
    jewellerName.text = g?.jewellerName ?? '';
    makingPerGram.text = g?.making ?? '';
    gst.text = g?.gst ?? '';
    total.text = g?.totalCost ?? '';

    if (g?.photoPath != null) {
      _image = File(g!.photoPath!);
    }

    calculateTotal();
  }

  @override
  void dispose() {
    weight.dispose();
    rate.dispose();
    makingPerGram.dispose();
    gst.dispose();
    total.dispose();
    goldValueCtrl.dispose();
    makingTotalCtrl.dispose();
    gstAmountCtrl.dispose();
    dateController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(dateController.text),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      dateController.text = picked.toString().split(' ')[0];
      setState(() {});
    }
  }

  void calculateTotal() {
    final w = double.tryParse(weight.text) ?? 0;
    final r = double.tryParse(rate.text) ?? 0;
    final makingRate = double.tryParse(makingPerGram.text) ?? 0;
    final gstPercent = double.tryParse(gst.text) ?? 0;

    final goldValue = w * r;
    final makingTotal = w * makingRate;
    final gstAmount = (goldValue + makingTotal) * (gstPercent / 100);
    final grandTotal = goldValue + makingTotal + gstAmount;

    setState(() {
      goldValueCtrl.text = goldValue.toStringAsFixed(2);
      makingTotalCtrl.text = makingTotal.toStringAsFixed(2);
      gstAmountCtrl.text = gstAmount.toStringAsFixed(2);
      total.text = grandTotal.toStringAsFixed(2);
    });
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;

    String? imagePath = widget.goldItem?.photoPath;

    if (_image != null && _image!.path != widget.goldItem?.photoPath) {
      imagePath = await saveImagePermanently(_image!);
    }

    final gold = GoldItem(
      id: widget.goldItem?.id,
      date: dateController.text,
      userName: userName.text,
      item: name.text,
      weight: weight.text,
      jewellerName: jewellerName.text,
      rate: rate.text,
      gst: gst.text,
      making: makingPerGram.text,
      totalCost: total.text,
      photoPath: imagePath,
    );

    widget.goldItem == null
        ? await GoldDB.instance.insertGold(gold)
        : await GoldDB.instance.updateGold(gold);

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gold Purchase')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: save,
              icon: const Icon(Icons.save),
              label: const Text(
                'Save',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _bigField(
                controller: dateController,
                label: "Date",
                readOnly: true,
                onTap: pickDate,
                suffix: Icons.calendar_today,
              ),
              const SizedBox(height: 14),
              _bigField(
                controller: name,
                label: "Item",
                readOnly: false,
                isText: true,
              ),

              const SizedBox(height: 14),
              _bigField(
                controller: jewellerName,
                label: "Jeweller Name",
                isText: true,
                readOnly: false,
              ),
              const SizedBox(height: 14),
              _bigField(
                controller: userName,
                isText: true,
                label: "User Name",
                readOnly: false,
              ),

              const SizedBox(height: 14),
              _card(
                title: "Gold Details",
                children: [
                  _bigField(
                    controller: weight,
                    label: 'Weight (gm)',
                    onChanged: (_) => calculateTotal(),
                  ),

                  const SizedBox(height: 14),
                  _inlineFieldWithValue(
                    field: _bigField(
                      controller: rate,
                      label: 'Rate ₹ / gm',
                      onChanged: (_) => calculateTotal(),
                    ),
                    title: 'Gold Value',
                    value: goldValueCtrl.text,
                  ),
                ],
              ),

              _card(
                title: "Charges",
                children: [
                  _inlineFieldWithValue(
                    field: _bigField(
                      controller: makingPerGram,
                      label: 'Making ₹ / gm',
                      onChanged: (_) => calculateTotal(),
                    ),
                    title: 'Making Total',
                    value: makingTotalCtrl.text,
                  ),
                  const SizedBox(height: 14),
                  _inlineFieldWithValue(
                    field: _bigField(
                      controller: gst,
                      label: 'GST %',
                      onChanged: (_) => calculateTotal(),
                    ),
                    title: 'GST Amount',
                    value: gstAmountCtrl.text,
                  ),
                ],
              ),

              _totalCard(),
              const SizedBox(height: 12),
              _imagePickerCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _bigField({
    required TextEditingController controller,
    required String label,
    void Function(String)? onChanged,
    bool readOnly = false,
    VoidCallback? onTap,
    bool isText = false,
    IconData? suffix,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType:
          !isText
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,

      onChanged: onChanged,
      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        fillColor: Colors.grey.shade300,
        labelText: label,
        suffixIcon: suffix != null ? Icon(suffix) : null,
      ),
    );
  }

  Widget _inlineFieldWithValue({
    required Widget field,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Expanded(flex: 3, child: field),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(
                  value.isEmpty ? '0.00' : value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _totalCard() {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: Colors.amber.shade100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Grand Total', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text(
                '₹ ${total.text.isEmpty ? '0.00' : total.text}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePickerCard() {
    return GestureDetector(
      onTap: pickImage,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: SizedBox(
          height: 170,
          child:
              _image == null
                  ? const Center(child: Icon(Icons.add_a_photo, size: 44))
                  : ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.file(
                      _image!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
        ),
      ),
    );
  }
}
