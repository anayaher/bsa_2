import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/payee_db.dart';
import '../db/transaction_db.dart';
import '../models/payee_model.dart';
import '../models/transaction_model.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  List<PayeeModel> _payees = [];
  List<PayeeModel> _heads = [];
  List<TransactionModel> _transactions = [];

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
    final txs = await TransactionDBHelper().getTransactions(
      type: _filterType == 'All' ? null : _filterType,
      search: _search.isNotEmpty ? _search : null,
    );
    setState(() {
      _transactions = txs;
      _loading = false;
    });
  }

  void _openAddTransactionSheet({TransactionModel? editTx}) {
    final _amountController = TextEditingController(
      text: editTx != null ? editTx.amount.toString() : '',
    );
    String _selectedType = editTx?.type ?? 'Income';
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
                      _loadTransactions();
                    },
                    child: Text(
                      editTx == null ? "Add Transaction" : "Save Changes",
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionList() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_transactions.isEmpty)
      return const Center(child: Text("No transactions yet"));

    return ListView.builder(
      itemCount: _transactions.length,
      itemBuilder: (_, i) {
        final tx = _transactions[i];
        return Dismissible(
          key: ValueKey(tx.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) async {
            await TransactionDBHelper().deleteTransaction(tx.id!);
            _loadTransactions();
          },
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors:
                      tx.type == 'Income'
                          ? [Colors.green.shade50, Colors.green.shade100]
                          : [Colors.red.shade50, Colors.red.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        tx.type == 'Income'
                            ? Colors.green.withOpacity(0.15)
                            : Colors.red.withOpacity(0.15),
                  ),
                  child: Icon(
                    tx.type == 'Income' ? Icons.upcoming : Icons.money_off,
                    color: tx.type == 'Income' ? Colors.green : Colors.red,
                    size: 26,
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        tx.payee,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.head,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_month, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('dd MMM yyyy').format(tx.date),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "₹${tx.amount.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: tx.type == 'Income' ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
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
      appBar: AppBar(
        title: const Text("Jama Kharcha"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search by Payee/Head",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) {
                _search = v;
                _loadTransactions();
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          /// TYPE FILTER CHIPS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            child: Row(
              children:
                  ['All', 'Income', 'Expense'].map((type) {
                    final selected = _filterType == type;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(type),
                        selected: selected,
                        onSelected: (_) {
                          setState(() => _filterType = type);
                          _loadTransactions();
                        },
                      ),
                    );
                  }).toList(),
            ),
          ),
          Expanded(child: _buildTransactionList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddTransactionSheet(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
