import 'package:BSA/Features/Salary/db/salary_db.dart';
import 'package:BSA/Features/Salary/models/salary_model.dart';
import 'package:BSA/Features/Salary/utils/sal_utils.dart';
import 'package:flutter/material.dart';

class SalarySetupScreen extends StatefulWidget {
  const SalarySetupScreen({super.key});

  @override
  State<SalarySetupScreen> createState() => _SalarySetupScreenState();
}

class _SalarySetupScreenState extends State<SalarySetupScreen> {
  final _basic = TextEditingController();
  final _daPercent = TextEditingController();
  final _hraPercent = TextEditingController();
  final _ta = TextEditingController();
  final _arrears = TextEditingController();

  final _daAmount = TextEditingController();
  final _hraAmount = TextEditingController();
  final _total = TextEditingController();

  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _loadSalary();

    _basic.addListener(_recalculate);
    _daPercent.addListener(_recalculate);
    _hraPercent.addListener(_recalculate);
    _ta.addListener(_recalculate);
    _arrears.addListener(_recalculate);
  }

  Future<void> _loadSalary() async {
    final salary = await SalaryDBHelper().getSalary();

    if (salary != null) {
      _isEditMode = true;

      _basic.text = salary.basic.toString();
      _daPercent.text = salary.daPercent.toString();
      _hraPercent.text = salary.hraPercent.toString();
      _ta.text = salary.ta.toString();
      _arrears.text = salary.arrears.toString();
      _daAmount.text = salary.daAmount.toString();
      _hraAmount.text = salary.hraAmount.toString();

      _recalculate();
      setState(() {});
    }
  }

  void _recalculate() {
    final basic = int.tryParse(_basic.text) ?? 0;
    final daP = int.tryParse(_daPercent.text) ?? 0;
    final hraP = int.tryParse(_hraPercent.text) ?? 0;
    final ta = int.tryParse(_ta.text) ?? 0;
    final arrears = int.tryParse(_arrears.text) ?? 0;

    final da = SalaryUtils.calculatePercent(basic, daP);
    final hra = SalaryUtils.calculatePercent(basic, hraP);

    final total = basic + da + hra + ta + arrears;

    _daAmount.text = da.toString();
    _hraAmount.text = hra.toString();
    _total.text = total.toString();
  }

  Future<void> _saveSalary() async {
    final salary = SalaryModel(
      basic: int.tryParse(_basic.text) ?? 0,
      daPercent: int.tryParse(_daPercent.text) ?? 0,
      hraPercent: int.tryParse(_hraPercent.text) ?? 0,
      daAmount: int.tryParse(_daAmount.text) ?? 0,
      hraAmount: int.tryParse(_hraAmount.text) ?? 0,
      ta: int.tryParse(_ta.text) ?? 0,
      arrears: int.tryParse(_arrears.text) ?? 0,
    );

    await SalaryDBHelper().saveSalary(salary);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditMode
              ? "Salary Updated Successfully"
              : "Salary Saved Successfully",
        ),
      ),
    );
  }

  Widget _cardField(
    String label,
    TextEditingController c, {
    String suffix = "",
    bool enabled = true,
  }) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: TextField(
          controller: c,
          enabled: enabled,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            fontSize: 18, // Bigger numbers
            fontWeight: FontWeight.w600, // Medium-bold
            color: Colors.black, // Dark text
            letterSpacing: 0.5,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            suffixText: suffix,
            suffixStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Salary Setup"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _sectionTitle("Basic Salary"),
            _cardField("Basic Amount", _basic, suffix: "₹"),

            _sectionTitle("Allowances"),
            Row(
              children: [
                Expanded(child: _cardField("DA %", _daPercent, suffix: "%")),
                const SizedBox(width: 12),
                Expanded(
                  child: _cardField(
                    "DA Amount",
                    _daAmount,
                    suffix: "₹",
                    enabled: false,
                  ),
                ),
              ],
            ),

            Row(
              children: [
                Expanded(child: _cardField("HRA %", _hraPercent, suffix: "%")),
                const SizedBox(width: 12),
                Expanded(
                  child: _cardField(
                    "HRA Amount",
                    _hraAmount,
                    suffix: "₹",
                    enabled: false,
                  ),
                ),
              ],
            ),

            _cardField("Travel Allowance", _ta, suffix: "₹"),
            _cardField("Arrears", _arrears, suffix: "₹"),

            _sectionTitle("Total Salary"),
            _cardField("Total Pay", _total, suffix: "₹", enabled: false),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: _saveSalary,
                child: Text(
                  _isEditMode ? "Update Salary" : "Save Salary",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
