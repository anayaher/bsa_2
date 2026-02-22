import 'dart:io' show Directory, File;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../db/payee_db.dart';
import '../db/transaction_db.dart';
import '../models/payee_model.dart';
import '../models/transaction_model.dart';

class TransactionReportScreen extends StatefulWidget {
  const TransactionReportScreen({super.key});

  @override
  State<TransactionReportScreen> createState() =>
      _TransactionReportScreenState();
}

class _TransactionReportScreenState extends State<TransactionReportScreen> {
  final _txDb = TransactionDBHelper();

  List<TransactionModel> _transactions = [];
  late TransactionDataSource _dataSource;

  double income = 0;
  double expense = 0;

  String? _selectedPayee;
  DateTime? _fromDate;
  DateTime? _toDate;

  String _title = "All Transactions";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openFilterDialog());
  }

  // ================= FILTER =================

  void _openFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ReportFilterSheet(onGenerate: _loadReport),
    );
  }

  // ================= LOAD =================

  Future<void> _loadReport({
    String? payee,
    DateTime? from,
    DateTime? to,
  }) async {
    final data = await _txDb.getTransactions(payee: payee, from: from, to: to);

    _selectedPayee = payee;
    _fromDate = from;
    _toDate = to;

    income = 0;
    expense = 0;

    for (final tx in data) {
      tx.type == 'Income' ? income += tx.amount : expense += tx.amount;
    }

    _dataSource = TransactionDataSource(data);

    setState(() {
      _transactions = data;

      if (payee != null && from != null && to != null) {
        _title =
            "$payee · ${DateFormat.yMMMd().format(from)} → ${DateFormat.yMMMd().format(to)}";
      } else if (payee != null) {
        _title = "Payee: $payee";
      } else if (from != null && to != null) {
        _title =
            "${DateFormat.yMMMd().format(from)} → ${DateFormat.yMMMd().format(to)}";
      } else {
        _title = "All Transactions";
      }
    });
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Transaction Report",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              _title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          if (_transactions.isNotEmpty)
            IconButton(
              tooltip: "Export PDF",
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: _generatePdf,
            ),
          IconButton(
            tooltip: "Filter",
            icon: const Icon(Icons.tune),
            onPressed: _openFilterDialog,
          ),
        ],
      ),
      body:
          _transactions.isEmpty
              ? _emptyState()
              : Column(
                children: [
                  _summaryStrip(),
                  const Divider(height: 1),
                  Expanded(child: _table()),
                ],
              ),
    );
  }

  // ================= SUMMARY =================

  Widget _summaryStrip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Wrap(
        spacing: 20,
        children: [
          _summaryItem("Income", income, Colors.green),
          _summaryItem("Expense", expense, Colors.red),
          _summaryItem("Balance", income - expense, Colors.blue),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, double value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("$label: ", style: const TextStyle(fontSize: 12)),
        Text(
          "₹${value.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // ================= TABLE =================

  Widget _table() {
    return SfDataGrid(
      source: _dataSource,
      columnSizer: ColumnSizer(),

      defaultColumnWidth: 120,
      headerRowHeight: 40,
      rowHeight: 36,
      gridLinesVisibility: GridLinesVisibility.horizontal,
      headerGridLinesVisibility: GridLinesVisibility.horizontal,
      columns: [
        GridColumn(columnName: 'date', label: _GridHeader('Date')),
        GridColumn(columnName: 'payee', label: _GridHeader('Payee')),
        GridColumn(columnName: 'head', label: _GridHeader('Head')),
        GridColumn(columnName: 'income', label: _GridHeader('Income')),
        GridColumn(columnName: 'expense', label: _GridHeader('Expense')),
      ],
    );
  }

  // ================= EMPTY =================

  Widget _emptyState() {
    return const Center(
      child: Text(
        "No transactions for selected filter",
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  // ================= PDF =================

  String _buildReportFileName({String? payee, DateTime? from, DateTime? to}) {
    String safe(String text) =>
        text.replaceAll(' ', '_').replaceAll(RegExp(r'[^\w_]'), '');

    final dateFmt = DateFormat('dd-MMM-yyyy');

    if (payee != null && from != null && to != null) {
      return 'Payee_${safe(payee)}_${dateFmt.format(from)}_to_${dateFmt.format(to)}.pdf';
    }

    if (payee != null) {
      return 'Payee_${safe(payee)}.pdf';
    }

    if (from != null && to != null) {
      return 'All_Transactions_${dateFmt.format(from)}_to_${dateFmt.format(to)}.pdf';
    }

    return 'All_Transactions.pdf';
  }

  Future<void> _generatePdf() async {
    final document = PdfDocument();
    final page = document.pages.add();

    PdfTextElement(
      text: "Transaction Report\n$_title",
      font: PdfStandardFont(
        PdfFontFamily.helvetica,
        16,
        style: PdfFontStyle.bold,
      ),
    ).draw(page: page, bounds: const Rect.fromLTWH(0, 0, 500, 40));

    PdfTextElement(
      text:
          "Income: ${income.toStringAsFixed(2)}\n"
          "Expense: ${expense.toStringAsFixed(2)}\n"
          "Balance: ${(income - expense).toStringAsFixed(2)}",
      font: PdfStandardFont(PdfFontFamily.helvetica, 10),
    ).draw(page: page, bounds: const Rect.fromLTWH(0, 50, 500, 40));

    final grid = PdfGrid();
    grid.columns.add(count: 5);
    grid.headers.add(1);

    final header = grid.headers[0];
    header.cells[0].value = 'Date';
    header.cells[1].value = 'Payee';
    header.cells[2].value = 'Head';
    header.cells[3].value = 'Income';
    header.cells[4].value = 'Expense';

    for (final tx in _transactions) {
      final row = grid.rows.add();
      final isIncome = tx.type == 'Income';

      row.cells[0].value = DateFormat.yMMMd().format(tx.date);
      row.cells[1].value = tx.payee;
      row.cells[2].value = tx.head;
      row.cells[3].value = isIncome ? tx.amount.toStringAsFixed(2) : '-';
      row.cells[4].value = !isIncome ? tx.amount.toStringAsFixed(2) : '-';
    }

    grid.draw(page: page, bounds: const Rect.fromLTWH(0, 100, 500, 600));

    final bytes = Uint8List.fromList(document.saveSync());
    document.dispose();

    // 📁 Save to specific folder
    final dir = await getApplicationDocumentsDirectory();
    final reportDir = Directory('${dir.path}/TransactionReports');

    if (!await reportDir.exists()) {
      await reportDir.create(recursive: true);
    }

    final fileName = _buildReportFileName(
      payee: _selectedPayee,
      from: _fromDate,
      to: _toDate,
    );
    final file = File('${reportDir.path}/$fileName');

    await file.writeAsBytes(bytes);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PDF saved to TransactionReports'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// =====================================================
// ================= DATA SOURCE ========================
// =====================================================

class TransactionDataSource extends DataGridSource {
  TransactionDataSource(List<TransactionModel> transactions) {
    _rows =
        transactions.map((tx) {
          final isIncome = tx.type == 'Income';
          return DataGridRow(
            cells: [
              DataGridCell<DateTime>(columnName: 'date', value: tx.date),
              DataGridCell<String>(columnName: 'payee', value: tx.payee),
              DataGridCell<String>(columnName: 'head', value: tx.head),
              DataGridCell<double>(
                columnName: 'income',
                value: isIncome ? tx.amount : 0,
              ),
              DataGridCell<double>(
                columnName: 'expense',
                value: !isIncome ? tx.amount : 0,
              ),
            ],
          );
        }).toList();
  }

  late final List<DataGridRow> _rows;

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells:
          row.getCells().map((cell) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                cell.value is DateTime
                    ? DateFormat.yMMMd().format(cell.value)
                    : cell.value is double
                    ? cell.value == 0
                        ? '-'
                        : "${cell.value.toStringAsFixed(2)}"
                    : cell.value.toString(),
                style: TextStyle(
                  fontSize: 12,
                  color:
                      cell.columnName == 'income'
                          ? Colors.green
                          : cell.columnName == 'expense'
                          ? Colors.red
                          : null,
                ),
              ),
            );
          }).toList(),
    );
  }
}

// =====================================================
// ================= FILTER SHEET =======================
// =====================================================

class _ReportFilterSheet extends StatefulWidget {
  final Function({String? payee, DateTime? from, DateTime? to}) onGenerate;
  const _ReportFilterSheet({required this.onGenerate});

  @override
  State<_ReportFilterSheet> createState() => _ReportFilterSheetState();
}

class _ReportFilterSheetState extends State<_ReportFilterSheet> {
  final _payeeDb = PayeeDBHelper();
  List<PayeeModel> _payees = [];

  bool byPayee = false;
  bool byDate = false;

  String? selectedPayee;
  DateTime? fromDate;
  DateTime? toDate;

  @override
  void initState() {
    super.initState();
    _loadPayees();
  }

  Future<void> _loadPayees() async {
    _payees = await _payeeDb.getPayees();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Generate Report",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SwitchListTile(
            value: byPayee,
            title: const Text("Filter by Payee"),
            onChanged: (v) => setState(() => byPayee = v),
          ),
          if (byPayee)
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Payee"),
              items:
                  _payees
                      .map(
                        (p) => DropdownMenuItem(
                          value: p.name,
                          child: Text(p.name),
                        ),
                      )
                      .toList(),
              onChanged: (v) => selectedPayee = v,
            ),
          SwitchListTile(
            value: byDate,
            title: const Text("Filter by Date"),
            onChanged: (v) => setState(() => byDate = v),
          ),
          if (byDate)
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    child: Text(
                      fromDate == null
                          ? "From"
                          : DateFormat.yMMMd().format(fromDate!),
                    ),
                    onPressed: () async {
                      fromDate = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      setState(() {});
                    },
                  ),
                ),
                Expanded(
                  child: TextButton(
                    child: Text(
                      toDate == null
                          ? "To"
                          : DateFormat.yMMMd().format(toDate!),
                    ),
                    onPressed: () async {
                      toDate = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onGenerate(
                  payee: byPayee ? selectedPayee : null,
                  from: byDate ? fromDate : null,
                  to: byDate ? toDate : null,
                );
                Navigator.pop(context);
              },
              child: const Text("Generate"),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// ================= GRID HEADER ========================
// =====================================================

class _GridHeader extends StatelessWidget {
  final String text;
  final bool alignRight;
  const _GridHeader(this.text, {this.alignRight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
