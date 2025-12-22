import 'package:BSA/core/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:BSA/Features/Maintainance/Controller/maintainance_controller.dart';
import 'package:BSA/Features/Maintainance/screens/add_maintainance_screen.dart';

class MaintenanceListScreen extends ConsumerStatefulWidget {
  final int vehicleId;
  final String vechileName;

  const MaintenanceListScreen(
    this.vechileName, {
    super.key,
    required this.vehicleId,
  });

  @override
  ConsumerState<MaintenanceListScreen> createState() =>
      _MaintenanceListScreenState();
}

class _MaintenanceListScreenState extends ConsumerState<MaintenanceListScreen> {
  late ScrollController horizontalController;
  late ScrollController verticalController;

  @override
  void initState() {
    super.initState();

    horizontalController = ScrollController();
    verticalController = ScrollController();

    Future.microtask(() {
      ref.read(maintenanceProvider.notifier).load(widget.vehicleId);
    });
  }

  @override
  void dispose() {
    horizontalController.dispose();
    verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(maintenanceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shape: const Border(bottom: BorderSide(color: Colors.black12)),
        title: Text(
          "${widget.vechileName} – Maintenance",
          style: const TextStyle(
            color: Color(0xFF1C222B),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1C222B)),
      ),

      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Builder(
                builder: (context) {
                  if (state.loading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4C9AFF),
                      ),
                    );
                  }

                  if (state.items.isEmpty) {
                    return const Center(
                      child: Text(
                        "No maintenance records added yet.",
                        style: TextStyle(
                          color: Color(0xFF3A4750),
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.black12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),

                    child: Scrollbar(
                      controller: verticalController,
                      thumbVisibility: false,
                      child: Scrollbar(
                        controller: horizontalController,
                        thumbVisibility: false,
                        notificationPredicate: (notif) =>
                            notif.metrics.axis == Axis.horizontal,

                        child: SingleChildScrollView(
                          controller: horizontalController,
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 10),
                            child: SingleChildScrollView(
                              controller: verticalController,
                              child: DataTable(
                                headingRowHeight: 42,
                                dataRowMinHeight: 42,
                                horizontalMargin: 12,

                                columnSpacing: 5,

                                headingTextStyle: const TextStyle(
                                  color: Color(0xFF1A1F27),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),

                                dataTextStyle: const TextStyle(
                                  color: Color(0xFF1E2430),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),

                                headingRowColor: WidgetStateProperty.all(
                                  const Color(0xFFE6EEF9),
                                ),

                                // ALTERNATE ROW COLORS
                                dataRowColor:
                                    WidgetStateProperty.resolveWith<Color?>((
                                      states,
                                    ) {
                                      if (states.contains(
                                        WidgetState.selected,
                                      )) {
                                        return Colors.red;
                                      }
                                      return null;
                                    }),

                                columns: const [
                                  DataColumn(label: Text("Date")),
                                  DataColumn(label: Text("Work Done")),
                                  DataColumn(label: Text("Price")),
                                  DataColumn(label: Text("Garage")),
                                  DataColumn(label: Text("KM")),
                                  DataColumn(label: Text("Delete")),
                                ],

                                rows: List.generate(state.items.length, (i) {
                                  final m = state.items[i];

                                  return DataRow(
                                    color: WidgetStateProperty.all(
                                      i % 2 == 0
                                          ? const Color(0xFFF9FBFE)
                                          : const Color.fromARGB(
                                              255,
                                              217,
                                              231,
                                              255,
                                            ),
                                    ),
                                    cells: [
                                      _cell(THelper.formatDate(m.date)),
                                      _cell(m.maintenanceType),
                                      _cell("₹${m.price}"),
                                      _cell(m.garage),
                                      _cell(m.kms?.toString() ?? "-"),
                                      DataCell(
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          color: Colors.redAccent,
                                          onPressed: () {
                                            ref
                                                .read(
                                                  maintenanceProvider.notifier,
                                                )
                                                .delete(
                                                  m.id!,
                                                  widget.vehicleId,
                                                );
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4C9AFF), Color(0xFF2D7DFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: FloatingActionButton.extended(
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            "Add Maintenance",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    AddMaintenanceScreen(vehicleId: widget.vehicleId),
              ),
            );

            ref.read(maintenanceProvider.notifier).load(widget.vehicleId);
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  DataCell _cell(String text) {
    return DataCell(
      SizedBox(
        width: 150,
        child: Text(text, overflow: TextOverflow.ellipsis, maxLines: 1),
      ),
    );
  }
}
