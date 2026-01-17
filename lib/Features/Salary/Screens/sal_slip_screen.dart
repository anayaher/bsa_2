import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import 'package:BSA/Features/Salary/db/salary_db.dart';
import 'package:BSA/Features/Salary/db/deduction_db.dart';
import 'package:BSA/Features/Salary/models/salary_model.dart';
import 'package:BSA/Features/Salary/models/deduction_model.dart';

class SalarySlipScreen extends StatefulWidget {
  const SalarySlipScreen({super.key});

  @override
  State<SalarySlipScreen> createState() => _SalarySlipScreenState();
}

class _SalarySlipScreenState extends State<SalarySlipScreen> {
  SalaryModel? _salary;
  List<DeductionModel> _deductions = [];
  late SalarySlipDataSource _dataSource;
  late String _formattedDate;

  int _gross = 0;
  int _totalDeductions = 0;
  int _netPay = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _salary = await SalaryDBHelper().getSalary();
    _deductions = await DeductionDBHelper().getDeductions();
    final now = DateTime.now();

    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];

    _formattedDate = "${months[now.month - 1]} ${now.year}";

    if (_salary == null) return;

    _gross =
        _salary!.basic +
        _salary!.daAmount +
        _salary!.hraAmount +
        _salary!.ta +
        _salary!.arrears;

    _totalDeductions = _deductions.fold(0, (sum, d) => sum + d.amount);
    _netPay = _gross - _totalDeductions;

    _dataSource = SalarySlipDataSource(
      salary: _salary!,
      deductions: _deductions,
      gross: _gross,
      totalDeduction: _totalDeductions,
    );

    setState(() {});
  }

  Future<void> _exportPdf() async {
    final PdfDocument document = PdfDocument();
    final page = document.pages.add();
    final now = DateTime.now();

    final titleFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      16,
      style: PdfFontStyle.bold,
    );

    final headerFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      12,
      style: PdfFontStyle.bold,
    );

    final normalFont = PdfStandardFont(PdfFontFamily.helvetica, 11);

    // ===== TITLE =====
    page.graphics.drawString(
      "SALARY SLIP",
      titleFont,
      bounds: const Rect.fromLTWH(0, 20, 500, 30),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );

    // ===== EMPLOYEE INFO =====
    page.graphics.drawString(
      "Employee Name : B. S. Aher",
      normalFont,
      bounds: const Rect.fromLTWH(20, 60, 250, 20),
    );

    page.graphics.drawString(
      "Salary Date : ${now.day} - $_formattedDate",
      normalFont,
      bounds: const Rect.fromLTWH(300, 60, 200, 20),
    );

    double y = 95;

    void drawRow(String a, String b, String c, String d, {bool bold = false}) {
      final font = bold ? headerFont : normalFont;

      page.graphics.drawString(a, font, bounds: Rect.fromLTWH(20, y, 120, 20));
      page.graphics.drawString(b, font, bounds: Rect.fromLTWH(150, y, 80, 20));
      page.graphics.drawString(c, font, bounds: Rect.fromLTWH(260, y, 140, 20));
      page.graphics.drawString(d, font, bounds: Rect.fromLTWH(420, y, 80, 20));

      y += 22;
    }

    // ===== TABLE HEADER =====
    drawRow("EARNINGS", "AMT", "DEDUCTIONS", "AMT", bold: true);

    final earnings = [
      ["Basic", _salary!.basic],
      ["DA", _salary!.daAmount],
      ["HRA", _salary!.hraAmount],
      ["TA", _salary!.ta],
      ["Arrears", _salary!.arrears],
    ];

    final max =
        earnings.length > _deductions.length
            ? earnings.length
            : _deductions.length;

    for (int i = 0; i < max; i++) {
      final e = i < earnings.length ? earnings[i] : ["", ""];
      final d =
          i < _deductions.length
              ? [_deductions[i].title, _deductions[i].amount]
              : ["", ""];

      drawRow("${e[0]}", "${e[1]}", "${d[0]}", "${d[1]}");
    }

    // ===== TOTALS =====
    y += 8;
    drawRow(
      "GROSS SALARY",
      "$_gross",
      "TOTAL DEDUCTIONS",
      "$_totalDeductions",
      bold: true,
    );

    // ===== NET PAY =====
    y += 20;
    page.graphics.drawString(
      "NET PAY : ₹ $_netPay",
      titleFont,
      bounds: Rect.fromLTWH(0, y, 500, 30),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );

    final bytes = await document.save();
    document.dispose();

    final dir = await getApplicationDocumentsDirectory();

    // 1️⃣ Create salaryslip folder
    final salaryDir = Directory("${dir.path}/salaryslip");
    if (!await salaryDir.exists()) {
      await salaryDir.create(recursive: true);
    }

    // 2️⃣ Format date like 18-Jan-2026
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];

    final today = DateTime.now();
    final fileName =
        "${today.day}-${months[today.month - 1]}-${today.year}.pdf";

    // 3️⃣ Save PDF inside salaryslip folder
    final file = File("${salaryDir.path}/$fileName");
    await file.writeAsBytes(bytes);

    // 4️⃣ Open PDF
    OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    if (_salary == null) {
      return const Scaffold(
        body: Center(child: Text("Please setup salary first")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Salary Slip"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _exportPdf,
          ),
        ],
      ),
      floatingActionButton: Container(
        width: 350,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 48, 135, 74), // soft red
              Color.fromARGB(255, 3, 188, 129), // deep red
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _exportPdf,
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.save_alt, color: Colors.white),
          label: const Text(
            "Save Salary",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            /// Title Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color.fromARGB(255, 40, 34, 34),
                ),
              ),
              child: Text(
                "Salary Slip • $_formattedDate",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// Table Card
            SizedBox(
              height: 400,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: SfDataGrid(
                  source: _dataSource,
                  gridLinesVisibility: GridLinesVisibility.both,
                  headerGridLinesVisibility: GridLinesVisibility.both,
                  columnWidthMode: ColumnWidthMode.fill,
                  headerRowHeight: 48,
                  rowHeight: 44,
                  columns: [
                    GridColumn(
                      columnName: 'earnTitle',
                      label: _header("EARNINGS"),
                    ),
                    GridColumn(columnName: 'earnAmt', label: _header("AMOUNT")),
                    GridColumn(
                      columnName: 'deductTitle',
                      label: _header("DEDUCTIONS"),
                    ),
                    GridColumn(
                      columnName: 'deductAmt',
                      label: _header("AMOUNT"),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// Net Pay Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black),
              ),
              child: Text(
                "Sal In Hand : $_netPay",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(String text) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      color: Colors.grey.shade200,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}

class SalarySlipDataSource extends DataGridSource {
  final SalaryModel salary;
  final List<DeductionModel> deductions;
  final int gross;
  final int totalDeduction;

  SalarySlipDataSource({
    required this.salary,
    required this.deductions,
    required this.gross,
    required this.totalDeduction,
  }) {
    _buildRows();
  }

  List<DataGridRow> _rows = [];

  void _buildRows() {
    final earnings = [
      ["Basic", salary.basic],
      ["DA", salary.daAmount],
      ["HRA", salary.hraAmount],
      ["TA", salary.ta],
      ["Arrears", salary.arrears],
    ];

    final max =
        earnings.length > deductions.length
            ? earnings.length
            : deductions.length;

    for (int i = 0; i < max; i++) {
      final e = i < earnings.length ? earnings[i] : ["", ""];
      final d =
          i < deductions.length
              ? [
                "${deductions[i].title.substring(0, 5)}...",
                deductions[i].amount,
              ]
              : ["", ""];

      _rows.add(
        DataGridRow(
          cells: [
            DataGridCell(columnName: 'earnTitle', value: e[0]),
            DataGridCell(columnName: 'earnAmt', value: e[1]),
            DataGridCell(columnName: 'deductTitle', value: d[0]),
            DataGridCell(columnName: 'deductAmt', value: d[1]),
          ],
        ),
      );
    }

    _rows.add(
      DataGridRow(
        cells: [
          const DataGridCell(columnName: 'earnTitle', value: 'GROSS'),
          DataGridCell(columnName: 'earnAmt', value: gross),
          const DataGridCell(columnName: 'deductTitle', value: 'TOTAL'),
          DataGridCell(columnName: 'deductAmt', value: totalDeduction),
        ],
      ),
    );
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells:
          row.getCells().map((cell) {
            bool isEarning = cell.columnName.startsWith('earn');
            bool isTotal =
                cell.value.toString().toUpperCase().contains("GROSS") ||
                cell.value.toString().toUpperCase().contains("TOTAL");

            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                cell.value.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                  color: isEarning ? Colors.blue : Colors.red,
                ),
              ),
            );
          }).toList(),
    );
  }
}
