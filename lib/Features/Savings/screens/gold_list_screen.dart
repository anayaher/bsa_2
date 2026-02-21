import 'dart:typed_data';

import 'package:BSA/Features/Savings/gold_db.dart';
import 'package:BSA/Features/Savings/gold_item.dart';
import 'package:BSA/Features/Savings/screens/add_gold_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class GoldListScreen extends StatefulWidget {
  const GoldListScreen({super.key});

  @override
  State<GoldListScreen> createState() => _GoldListScreenState();
}

class _GoldListScreenState extends State<GoldListScreen> {
  late Future<List<GoldItem>> _goldFuture;

  void _loadGold() {
    _goldFuture = GoldDB.instance.fetchGold();
  }

  // ---------------- PDF FLOW ----------------

  Future<void> _onPdfPressed() async {
    final choice = await showDialog<String>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Generate Report'),
            content: const Text('Choose report type'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'all'),
                child: const Text('All Users'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, 'user'),
                child: const Text('Single User'),
              ),
            ],
          ),
    );

    if (choice == 'all') {
      await generateGoldReportPdf();
    } else if (choice == 'user') {
      await _selectUserAndGenerate();
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

  // ---------------- PDF GENERATION ----------------

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

  // ---------------- UI ----------------

  @override
  void initState() {
    super.initState();
    _loadGold();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gold Items'),
        actions: [
          TextButton(onPressed: () => _openAddEdit(), child: const Text('Add')),
          TextButton(onPressed: _onPdfPressed, child: const Text('PDF')),
        ],
      ),
      body: FutureBuilder<List<GoldItem>>(
        future: _goldFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const _EmptyState();
          }

          final items = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              final item = items[index];

              return _GoldCard(
                item: item,
                index: index,
                onTap: () => _openAddEdit(item),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openAddEdit([GoldItem? item]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditGoldScreen(goldItem: item)),
    );

    if (result == true) {
      setState(_loadGold);
    }
  }
}

// ---------------- UI WIDGETS ----------------

class _GoldCard extends StatelessWidget {
  final GoldItem item;
  final VoidCallback onTap;
  final int index;

  const _GoldCard({
    required this.item,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        title: Text(
          item.item,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('${item.weight} gm • ${item.date}'),
        trailing: Text(
          '₹${item.totalCost}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('No gold purchases yet'));
  }
}
