import 'package:BSA/Features/Home/Screens/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../db/payee_db.dart';
import '../db/transaction_db.dart';
import '../models/payee_model.dart';
import '../models/transaction_model.dart';

class TransactionScreen extends ConsumerStatefulWidget {
  const TransactionScreen({super.key});

  @override
  ConsumerState<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends ConsumerState<TransactionScreen> {
  List<PayeeModel> _payees = [];
  List<PayeeModel> _heads = [];
  List<TransactionModel> _transactions = [];
  bool _showSearch = false;

  double _totalIncome = 0;
  double _totalExpense = 0;
  double _balance = 0;

  String _filterType = 'All';

  String _search = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPayeeHead();
    _loadTransactions();
  }

  Future<void> _loadPayeeHead() async {
    final payees = await PayeeDBHelper().getPayees(type: 'Payee');
    final heads = await PayeeDBHelper().getPayees(type: 'Head');
    setState(() {
      _payees = payees;
      _heads = heads;
    });
  }

  Future<void> _loadTransactions() async {
    setState(() => _loading = true);

    // Get filtered transactions
    final txs = await TransactionDBHelper().getTransactions(
      type: _filterType == 'All' ? null : _filterType,
      search: _search.isNotEmpty ? _search : null,
    );

    // Compute filtered totals
    double income = 0;
    double expense = 0;
    for (var tx in txs) {
      if (tx.type == 'Income')
        income += tx.amount;
      else
        expense += tx.amount;
    }

    setState(() {
      _transactions = txs;
      _totalIncome = income;
      _totalExpense = expense;
      _balance = income - expense;
      _loading = false;
    });
  }

  void _openAddTransactionSheet({TransactionModel? editTx}) {
    final _amountController = TextEditingController(
      text: editTx != null ? editTx.amount.toString() : '',
    );
    String _selectedType = editTx?.type ?? 'Expense';
    String? _selectedPayee =
        editTx?.payee ?? (_payees.isNotEmpty ? _payees.first.name : null);
    String? _selectedHead =
        editTx?.head ?? (_heads.isNotEmpty ? _heads.first.name : null);
    DateTime _selectedDate = editTx?.date ?? DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  editTx == null ? "Add Transaction" : "Edit Transaction",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Amount",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedType,
                        items:
                            ['Income', 'Expense']
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) {
                          if (v != null) _selectedType = v;
                        },
                        decoration: const InputDecoration(
                          labelText: "Type",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedPayee,
                        items:
                            _payees
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e.name,
                                    child: Text(e.name),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) {
                          if (v != null) _selectedPayee = v;
                        },
                        decoration: const InputDecoration(
                          labelText: "Payee",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedHead,
                        items:
                            _heads
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e.name,
                                    child: Text(e.name),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) {
                          if (v != null) _selectedHead = v;
                        },
                        decoration: const InputDecoration(
                          labelText: "Head",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) _selectedDate = date;
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: "Date",
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            DateFormat('yyyy-MM-dd').format(_selectedDate),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final amount = double.tryParse(
                        _amountController.text.trim(),
                      );
                      if (amount == null ||
                          _selectedPayee == null ||
                          _selectedHead == null)
                        return;

                      final tx = TransactionModel(
                        id: editTx?.id,
                        amount: amount,
                        type: _selectedType,
                        payee: _selectedPayee!,
                        head: _selectedHead!,
                        date: _selectedDate,
                      );

                      if (editTx == null) {
                        await TransactionDBHelper().addTransaction(tx);
                      } else {
                        await TransactionDBHelper().updateTransaction(tx);
                      }

                      Navigator.pop(context);
                      ref.invalidate(homeProvider);
                      _loadTransactions();
                    },
                    child: Text(editTx == null ? "Add Transaction" : "Save"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// PDF generation for filtered transactions
  Future<void> _generatePdfReport() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build:
            (context) => [
              pw.Text("Transaction Report", style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 12),
              pw.Text(
                "Filter: $_filterType ${_search.isNotEmpty ? ' | Search: $_search' : ''}",
              ),
              pw.Text("Total Income: ${_totalIncome.toStringAsFixed(2)}"),
              pw.Text("Total Expense: ${_totalExpense.toStringAsFixed(2)}"),
              pw.Text("Balance: ${_balance.toStringAsFixed(2)}"),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: ['Date', 'Payee', 'Head', 'Type', 'Amount'],
                data:
                    _transactions
                        .map(
                          (tx) => [
                            DateFormat('yyyy-MM-dd').format(tx.date),
                            tx.payee,
                            tx.head,
                            tx.type,
                            (tx.amount.toStringAsFixed(2)),
                          ],
                        )
                        .toList(),
              ),
            ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  /// Build transaction list
  Widget _buildTransactionList() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_transactions.isEmpty)
      return const Center(child: Text("No transactions"));

    return ListView.builder(
      itemCount: _transactions.length,
      itemBuilder: (_, i) {
        final tx = _transactions[i];

        return Dismissible(
          key: ValueKey(tx.id),
          direction: DismissDirection.endToStart,

          confirmDismiss: (_) async {
            return await showDialog<bool>(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text("Delete Transaction"),
                    content: const Text(
                      "Are you sure you want to delete this transaction?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
            );
          },

          onDismissed: (_) async {
            await TransactionDBHelper().deleteTransaction(tx.id!);
            _loadTransactions();
            ref.invalidate(homeProvider);
          },

          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),

          child: Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color:
                    tx.type == 'Income'
                        ? Colors.green.withOpacity(0.15)
                        : Colors.red.withOpacity(0.15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('EEE, dd MMM yyyy').format(tx.date),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tx.payee,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      Text(
                        tx.head,
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color.fromRGBO(66, 66, 66, 1),
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Amount",
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      Text(
                        "₹${tx.amount.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              tx.type == 'Income' ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(_showSearch ? 160 : 80),
        child: AppBar(
          title: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Jama Kharcha"),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: _openAddTransactionSheet,
              icon: const Icon(Icons.add, size: 30),
            ),

            IconButton(
              onPressed: () => setState(() => _showSearch = !_showSearch),
              icon: Icon(_showSearch ? Icons.close : Icons.search),
            ),
          ],
          bottom: PreferredSize(
            preferredSize:
                (_showSearch)
                    ? const Size.fromHeight(60)
                    : const Size.fromHeight(0),
            child:
                (_showSearch)
                    ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search by Payee or Head",
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (v) {
                          _search = v;
                          _loadTransactions();
                        },
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
        ),
      ),
      body: Column(
        children: [
          // 💰 BALANCE DASHBOARD
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 33, 1, 51),
                    Color.fromARGB(255, 0, 0, 0),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(
                      255,
                      76,
                      112,
                      175,
                    ).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "Balance ₹${_balance.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _summaryTile(
                        "Income",
                        _totalIncome,
                        Colors.green,
                        Icons.arrow_downward,
                      ),
                      _summaryTile(
                        "Expense",
                        _totalExpense,
                        Colors.red,
                        Icons.arrow_upward,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // FILTER CHIPS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children:
                  ['All', 'Income', 'Expense'].map((type) {
                    final selected = _filterType == type;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: ChoiceChip(
                        label: Text(type),
                        selected: selected,
                        selectedColor:
                            _filterType == "Income"
                                ? Colors.blue
                                : _filterType == "Expense"
                                ? Colors.red
                                : Colors.green,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : Colors.black,
                        ),
                        onSelected: (_) {
                          setState(() => _filterType = type);
                          _loadTransactions();
                        },
                      ),
                    );
                  }).toList(),
            ),
          ),

          // Transaction list
          Expanded(child: _buildTransactionList()),
        ],
      ),
    );
  }

  Widget _summaryTile(String title, double amount, Color color, IconData icon) {
    return Row(
      children: [
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(width: 8),
        Text(
          amount.toStringAsFixed(2),
          style: TextStyle(
            color: title == "Income" ? Colors.green : Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
