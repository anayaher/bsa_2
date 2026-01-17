import 'package:BSA/Features/jamaKharcha/db/payee_db.dart';
import 'package:BSA/Features/jamaKharcha/models/payee_model.dart';
import 'package:flutter/material.dart';

class PayeeSetupScreen extends StatefulWidget {
  const PayeeSetupScreen({super.key});

  @override
  State<PayeeSetupScreen> createState() => _PayeeSetupScreenState();
}

class _PayeeSetupScreenState extends State<PayeeSetupScreen> {
  final _nameController = TextEditingController();

  final List<String> _types = const ['Head', 'Payee'];

  late String _selectedType;
  String _filterType = 'All';
  String _search = '';

  List<PayeeModel> _payees = [];
  bool _loading = true;

  // For editing
  PayeeModel? _editingPayee;

  @override
  void initState() {
    super.initState();
    _selectedType = _types.first;
    _loadPayees();
  }

  Future<void> _loadPayees() async {
    setState(() => _loading = true);

    final data = _search.isNotEmpty
        ? await PayeeDBHelper().searchPayees(_search)
        : await PayeeDBHelper().getPayees(type: _filterType);

    setState(() {
      _payees = data;
      _loading = false;
    });
  }

  Future<void> _savePayee() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    if (_editingPayee != null) {
      // UPDATE existing
      final updated = PayeeModel(
        id: _editingPayee!.id,
        name: name,
        type: _selectedType,
      );
      await PayeeDBHelper().updatePayee(updated);
      _editingPayee = null;
    } else {
      // ADD new
      await PayeeDBHelper().addPayee(
        PayeeModel(name: name, type: _selectedType),
      );
    }

    _nameController.clear();
    _selectedType = _types.first;
    _loadPayees();
  }

  Future<void> _editPayee(PayeeModel payee) async {
    setState(() {
      _editingPayee = payee;
      _nameController.text = payee.name;
      _selectedType = payee.type;
    });
  }

  Future<void> _deletePayee(PayeeModel payee) async {
    await PayeeDBHelper().deletePayee(payee.id!);
    _loadPayees();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payee / Head Setup"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// ADD / EDIT CARD
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Payee / Head Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      items: _types
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _selectedType = v);
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: "Type",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _savePayee,
                        child: Text(_editingPayee != null ? "Update" : "Save"),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// SEARCH & FILTER
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Search",
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (v) {
                      _search = v;
                      _loadPayees();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _filterType,
                  items: ['All', ..._types]
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _filterType = v);
                      _loadPayees();
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// LIST / EMPTY STATE
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _payees.isEmpty
                      ? const Center(
                          child: Text(
                            "No payees added yet",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _payees.length,
                          itemBuilder: (_, i) {
                            final p = _payees[i];
                            return Card(
                              child: ListTile(
                                leading: Icon(
                                  p.type == 'Head'
                                      ? Icons.category
                                      : Icons.person,
                                ),
                                title: Text(p.name),
                                subtitle: Text(p.type),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _editPayee(p),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => _deletePayee(p),
                                    ),
                                  ],
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
