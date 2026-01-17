import 'package:flutter/material.dart';
import 'package:BSA/Features/Salary/db/deduction_db.dart';
import 'package:BSA/Features/Salary/models/deduction_model.dart';

class DeductionScreen extends StatefulWidget {
  const DeductionScreen({super.key});

  @override
  State<DeductionScreen> createState() => _DeductionScreenState();
}

class _DeductionScreenState extends State<DeductionScreen> {
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();

  List<DeductionModel> _deductions = [];

  @override
  void initState() {
    super.initState();
    _loadDeductions();
  }

  Future<void> _loadDeductions() async {
    _deductions = await DeductionDBHelper().getDeductions();
    setState(() {});
  }

  Future<void> _addDeduction() async {
    if (_titleCtrl.text.isEmpty || _amountCtrl.text.isEmpty) return;

    final d = DeductionModel(
      title: _titleCtrl.text,
      amount: int.parse(_amountCtrl.text),
    );

    await DeductionDBHelper().addDeduction(d);

    _titleCtrl.clear();
    _amountCtrl.clear();

    _loadDeductions();
  }

  Future<void> _deleteDeduction(int id) async {
    await DeductionDBHelper().deleteDeduction(id);
    _loadDeductions();
  }

  Widget _inputField(
    String label,
    TextEditingController c, {
    String suffix = "",
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: TextField(
          controller: c,

          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            labelText: label,
            suffixText: suffix,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Deductions"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _inputField("Deduction Title", _titleCtrl),
            _inputField("Amount", _amountCtrl, suffix: "₹"),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _addDeduction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Add Deduction",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child:
                  _deductions.isEmpty
                      ? const Center(child: Text("No deductions added"))
                      : ListView.builder(
                        itemCount: _deductions.length,
                        itemBuilder: (context, i) {
                          final d = _deductions[i];

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ListTile(
                              title: Text(
                                d.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text("₹ ${d.amount}"),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteDeduction(d.id!),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
