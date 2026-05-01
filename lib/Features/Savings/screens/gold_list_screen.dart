import 'dart:io';
import 'dart:typed_data';

import 'package:BSA/Features/Savings/gold_db.dart';
import 'package:BSA/Features/Savings/gold_item.dart';
import 'package:BSA/Features/Savings/screens/add_gold_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class GoldListScreen extends StatefulWidget {
  const GoldListScreen({super.key});

  @override
  State<GoldListScreen> createState() => _GoldListScreenState();
}

class _GoldListScreenState extends State<GoldListScreen> {
  late Future<List<GoldItem>> _goldFuture;

  Future<Directory> getGoldReportDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final reportDir = Directory('${dir.path}/goldReports');
    if (!await reportDir.exists()) {
      await reportDir.create(recursive: true);
    }
    return reportDir;
  }

  void _loadGold() {
    _goldFuture = GoldDB.instance.fetchGold();
  }

  // ---------------- DELETE ----------------

  Future<void> _confirmDelete(GoldItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete Gold Entry'),
            content: Text(
              'Are you sure you want to delete "${item.item}" purchased on ${item.date}?\n\nThis action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true && item.id != null) {
      await GoldDB.instance.deleteGold(item.id!);
      setState(_loadGold);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${item.item}" deleted successfully'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
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

    final document = PdfDocument();
    final titleFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      22,
      style: PdfFontStyle.bold,
    );
    final headerFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      12,
      style: PdfFontStyle.bold,
    );
    final bodyFont = PdfStandardFont(PdfFontFamily.helvetica, 11);

    final page = document.pages.add();
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
    double totalWeight = 0;
    double totalMaking = 0;
    double totalGst = 0;

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

      totalWeight += weight;
      totalMaking += makingTotal;
      totalGst += gstAmount;
      grandTotal += total;

      row.cells[0].value = g.date;
      row.cells[1].value = g.weight;
      row.cells[2].value = currency.format(rate);
      row.cells[3].value = currency.format(makingTotal);
      row.cells[4].value = currency.format(gstAmount);
      row.cells[5].value = currency.format(total);
      row.style = PdfGridRowStyle(font: bodyFont);
    }

    final totalRow = grid.rows.add();
    totalRow.cells[0].value = 'TOTAL';
    totalRow.cells[1].value = totalWeight.toStringAsFixed(2);
    totalRow.cells[2].value = '-';
    totalRow.cells[3].value = currency.format(totalMaking);
    totalRow.cells[4].value = currency.format(totalGst);
    totalRow.cells[5].value = currency.format(grandTotal);

    totalRow.style = PdfGridRowStyle(
      font: PdfStandardFont(
        PdfFontFamily.helvetica,
        11,
        style: PdfFontStyle.bold,
      ),
      backgroundBrush: PdfBrushes.lightGray,
    );

    for (int i = 1; i < 6; i++) {
      totalRow.cells[i].stringFormat = PdfStringFormat(
        alignment: PdfTextAlignment.right,
      );
    }

    grid.draw(
      page: page,
      bounds: Rect.fromLTWH(0, yOffset, page.getClientSize().width, 0),
    );

    final bytes = Uint8List.fromList(document.saveSync());
    document.dispose();

    final dir = await getGoldReportDirectory();
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final fileName =
        userName == null
            ? 'all_$date.pdf'
            : '${userName.replaceAll(' ', '_')}_$date.pdf';

    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);

    await Printing.layoutPdf(onLayout: (_) async => bytes);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Saved to Gold Reports: $fileName')));
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

              // ---- SWIPE TO DELETE WRAPPER ----
              return Dismissible(
                key: ValueKey(item.id),
                direction: DismissDirection.endToStart,
                // Intercept the dismiss and show a dialog instead of
                // letting the widget auto-remove itself
                confirmDismiss: (_) async {
                  await _confirmDelete(item);
                  // Always return false so Dismissible never removes
                  // the tile itself — _confirmDelete calls setState
                  return false;
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade400,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete_outline, color: Colors.white, size: 28),
                      SizedBox(height: 4),
                      Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                child: _GoldCard(
                  item: item,
                  index: index,
                  onTap: () => _openAddEdit(item),
                ),
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
