import 'dart:typed_data';

import 'package:BSA/Features/Reports/screens/gold_report_screen.dart';
import 'package:BSA/Features/Reports/screens/jk_report_list_screen.dart';
import 'package:BSA/Features/Salary/Screens/sal_slip_history.dart';
import 'package:BSA/Features/Savings/gold_db.dart';
import 'package:BSA/Features/jamaKharcha/screens/transaction_report.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class ReportMainScreen extends StatefulWidget {
  const ReportMainScreen({super.key});

  @override
  State<ReportMainScreen> createState() => _ReportMainScreenState();
}

class _ReportMainScreenState extends State<ReportMainScreen> {
  Future<void> _onJamaKharchaTap() async {
    final choice = await showDialog<String>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Jama-Kharcha"),
            content: const Text("What would you like to do?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JkReportListScreen(),
                    ),
                  );
                },
                child: const Text("View Reports"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, 'generate'),
                child: const Text("Generate New"),
              ),
            ],
          ),
    );

    if (choice == 'list') {
      // 🔹 List screen (saved PDFs or reports)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TransactionReportScreen()),
      );
    }

    if (choice == 'generate') {
      // 🔹 Directly open filter → generate flow
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TransactionReportScreen()),
      );
      // If later you split generate screen, hook it here
    }
  }

  Future<void> _selectUserAndGenerate() async {
    final goldItems = await GoldDB.instance.fetchGold();

    final users =
        goldItems
            .map((e) => e.userName?.trim())
            .where((e) => e != null && e!.isNotEmpty)
            .toSet()
            .toList();

    if (users.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No users found')));
      return;
    }

    final selectedUser = await showDialog<String>(
      context: context,
      builder:
          (_) => SimpleDialog(
            title: const Text('Select User'),
            children:
                users
                    .map(
                      (u) => SimpleDialogOption(
                        onPressed: () => Navigator.pop(context, u),
                        child: Text(u!),
                      ),
                    )
                    .toList(),
          ),
    );

    if (selectedUser != null) {
      await generateGoldReportPdf(userName: selectedUser);
    }
  }

  Future<void> generateGoldReportPdf({String? userName}) async {
    final goldItems = await GoldDB.instance.fetchGold();
    final currency = NumberFormat.currency(symbol: '', decimalDigits: 2);

    final filtered =
        userName == null
            ? goldItems
            : goldItems.where((e) => e.userName == userName).toList();

    if (filtered.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data to generate report')),
      );
      return;
    }

    final PdfDocument document = PdfDocument();
    final PdfFont titleFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      22,
      style: PdfFontStyle.bold,
    );
    final PdfFont headerFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      12,
      style: PdfFontStyle.bold,
    );
    final PdfFont bodyFont = PdfStandardFont(PdfFontFamily.helvetica, 11);

    final PdfPage page = document.pages.add();
    final graphics = page.graphics;
    double yOffset = 0;

    graphics.drawString(
      'Gold Investment Report',
      titleFont,
      bounds: Rect.fromLTWH(0, yOffset, page.getClientSize().width, 40),
    );

    yOffset += 30;

    graphics.drawString(
      userName == null ? 'All Users' : 'User: $userName',
      bodyFont,
      bounds: Rect.fromLTWH(0, yOffset, page.getClientSize().width, 20),
    );

    yOffset += 18;

    graphics.drawString(
      'Generated on: ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
      bodyFont,
      bounds: Rect.fromLTWH(0, yOffset, page.getClientSize().width, 20),
    );

    yOffset += 25;

    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 6);
    grid.headers.add(1);

    final header = grid.headers[0];
    header.cells[0].value = 'Date';
    header.cells[1].value = 'Weight (gm)';
    header.cells[2].value = 'Rate';
    header.cells[3].value = 'Making';
    header.cells[4].value = 'GST';
    header.cells[5].value = 'Total';

    header.style = PdfGridRowStyle(
      backgroundBrush: PdfBrushes.gold,
      font: headerFont,
    );

    double grandTotal = 0;

    for (final g in filtered) {
      final row = grid.rows.add();

      final weight = double.tryParse(g.weight) ?? 0;
      final rate = double.tryParse(g.rate) ?? 0;
      final making = double.tryParse(g.making) ?? 0;
      final gst = double.tryParse(g.gst) ?? 0;

      final goldValue = weight * rate;
      final makingTotal = weight * making;
      final gstAmount = (goldValue + makingTotal) * gst / 100;
      final total = double.tryParse(g.totalCost) ?? 0;

      grandTotal += total;

      row.cells[0].value = g.date;
      row.cells[1].value = g.weight;
      row.cells[2].value = currency.format(rate);
      row.cells[3].value = currency.format(makingTotal);
      row.cells[4].value = currency.format(gstAmount);
      row.cells[5].value = currency.format(total);

      row.style = PdfGridRowStyle(font: bodyFont);
    }

    final result =
        grid.draw(
          page: page,
          bounds: Rect.fromLTWH(0, yOffset, page.getClientSize().width, 0),
        )!;

    yOffset = result.bounds.bottom + 20;

    graphics.drawString(
      'Grand Total: ${currency.format(grandTotal)}',
      PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(page.getClientSize().width - 250, yOffset, 250, 30),
      format: PdfStringFormat(alignment: PdfTextAlignment.right),
    );

    final bytes = Uint8List.fromList(document.saveSync());
    document.dispose();

    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reports")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _reportCard(
              context,
              title: "Salary",
              icon: Icons.payments_rounded,
              color: Colors.green.shade50,
              iconColor: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SalSlipHistory()),
                );
              },
            ),
            _reportCard(
              context,
              title: "Jama-Kharcha",
              icon: Icons.account_balance_wallet_rounded,
              color: Colors.blue.shade50,
              iconColor: Colors.blue,
              onTap: _onJamaKharchaTap,
            ),
            _reportCard(
              context,
              title: "Gold",
              icon: Icons.workspace_premium_rounded,
              color: Colors.amber.shade50,
              iconColor: Colors.amber.shade800,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GoldReportScreen()),
                );

                // ---------------- PDF GENERATION ----------------
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _reportCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      color: color,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.15),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: onTap,
      ),
    );
  }
}
