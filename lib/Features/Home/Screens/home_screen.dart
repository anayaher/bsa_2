import 'package:BSA/Features/Home/widgets/salary_card.dart';
import 'package:BSA/Features/Insurance/data/insurance_db.dart';
import 'package:BSA/Features/Salary/Screens/deductions_screen.dart';
import 'package:BSA/Features/Salary/Screens/sal_slip_screen.dart';
import 'package:BSA/Features/Salary/Screens/salary_screen.dart';
import 'package:BSA/Features/Salary/db/deduction_db.dart';
import 'package:BSA/Features/Salary/db/salary_db.dart';
import 'package:BSA/Features/Vehicles/db/vehicle_db.dart';
import 'package:BSA/Features/Vehicles/screens/vehicles_list_screen.dart';
import 'package:BSA/Features/jamaKharcha/screens/add_payee.dart';
import 'package:BSA/Features/jamaKharcha/screens/transaction_screen.dart';
import 'package:BSA/Models/vehicle_expiry_model.dart';
import 'package:BSA/core/Controller/expiry_controller.dart';
import 'package:BSA/core/services/local_data_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  double totalJama = 0;
  double totalKharcha = 0;

  double get netBalance => totalJama - totalKharcha;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.microtask(() async {
      final vehicles = await VehicleDB.instance.fetchVehicles();
      final insurances = await InsuranceDB.instance.fetchAllInsurances();
      ref
          .read(expiryProvider.notifier)
          .checkAllExpiry(vehicles: vehicles, insurances: insurances);
    });
  }

  @override
  Widget build(BuildContext context) {
    final expiry = ref.watch(expiryProvider);
    final expiredCount =
        expiry
            .where(
              (e) =>
                  e.pucStatus == ExpiryStatus.expired ||
                  e.insuranceStatus == ExpiryStatus.expired,
            )
            .length;
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      drawer: _buildAppDrawer(context),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _salarySummaryCard(),

            const SizedBox(height: 20),

            _jamaKharchaHighlightCard(), // 👈 ADD HERE
            // --------------- FEATURE CARDS -----------------
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _featureCard(
                  badgeCount: expiredCount,
                  title: "Vehicles",
                  icon: Icons.two_wheeler,
                  color: Colors.blue.shade50,
                  iconColor: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VehiclesListScreen(),
                      ),
                    );
                  },
                ),

                _featureCard(
                  title: "Jama-Kharcha",
                  icon: Icons.currency_rupee,
                  color: Colors.green.shade50,
                  iconColor: Colors.green,
                  onTap: () => _comingSoon(),
                ),

                _featureCard(
                  title: "Income / Expense",
                  icon: Icons.account_balance_wallet,
                  color: Colors.orange.shade50,
                  iconColor: Colors.orange,
                  onTap: () => _comingSoon(),
                ),

                _featureCard(
                  title: "Salary Manager",
                  icon: Icons.payments,
                  color: Colors.purple.shade50,
                  iconColor: Colors.purple,
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SalarySlipScreen(),
                        ),
                      ),
                ),

                _featureCard(
                  title: "Reports",
                  icon: Icons.bar_chart,
                  color: Colors.red.shade50,
                  iconColor: Colors.red,
                  onTap: () => _comingSoon(),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _salarySummaryCard() {
    return FutureBuilder(
      future: Future.wait([
        SalaryDBHelper().getTotalSalary(),
        DeductionDBHelper().getTotalDeductions(),
      ]),
      builder: (context, AsyncSnapshot<List<int>> snapshot) {
        final totalSalary = snapshot.data?[0] ?? 0;
        final totalDeduction = snapshot.data?[1] ?? 0;
        final netSalary = totalSalary - totalDeduction;

        return AnimatedSalaryCard(
          totalSalary: totalSalary,
          totalDeduction: totalDeduction,
          netSalary: netSalary,
        );
      },
    );
  }

  // ------------------ Drawer ---------------------
  Drawer _buildAppDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundImage: const AssetImage("assets/profile.png"),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Welcome!",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const Text(
                  "User",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),

          ListTile(
            leading: const Icon(Icons.lock_reset),
            title: const Text("Reset Password"),
            onTap: () {
              Navigator.pop(context);
              _showResetPasswordDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock_reset),
            title: const Text("Set Salary"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SalarySetupScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock_reset),
            title: const Text("Set Deductions"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DeductionScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock_reset),
            title: const Text("Set Payee/Heads"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PayeeSetupScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text("Change Theme"),
            onTap: () {
              Navigator.pop(context);
              _comingSoon();
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () {},
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              "v1.0.0",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureCard({
    int? badgeCount,
    required String title,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        children: [
          Container(
            width: 175,
            height: 150,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(icon, size: 45, color: iconColor),

                    if (badgeCount != null && badgeCount > 0)
                      Positioned(
                        top: -6,
                        right: -90,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            badgeCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Coming Soon Snackbar -----------------

  void _comingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Coming Soon!"),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showResetPasswordDialog() {
    TextEditingController passCtrl = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Reset Password"),
            content: TextField(
              controller: passCtrl,
              obscureText: true,
              maxLength: 4,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "New 4-digit Password",
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final pass = passCtrl.text.trim();

                  if (pass.length != 4) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Password must be 4 digits"),
                      ),
                    );
                    return;
                  }

                  await LocalStorageService.savePassword(pass);

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password Updated")),
                  );
                },
                child: const Text("Save"),
              ),
            ],
          ),
    );
  }

  Widget _jamaKharchaHighlightCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade100, Colors.green.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.currency_rupee, color: Colors.green, size: 26),
              SizedBox(width: 8),
              Text(
                "Jama - Kharcha",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // JAMA Highlight (Most Weight)
              Expanded(
                child: _amountBox(
                  "Jama",
                  totalJama,
                  Colors.green.shade700,
                  Icons.arrow_downward_rounded,
                ),
              ),
              const SizedBox(width: 12),

              // KHARCHA
              Expanded(
                child: _amountBox(
                  "Kharcha",
                  totalKharcha,
                  Colors.red.shade700,
                  Icons.arrow_upward_rounded,
                ),
              ),

              const SizedBox(width: 12),

              // BALANCE
              Expanded(
                child: _amountBox(
                  "Balance",
                  netBalance,
                  netBalance >= 0 ? Colors.blue.shade700 : Colors.red.shade700,
                  Icons.account_balance_wallet_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TransactionScreen(),
                    ),
                  ),
              child: const Text(
                "View Full Jama-Kharcha",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountBox(String title, double value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 5),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "₹ ${value.toStringAsFixed(0)}",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountItem(String title, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          "₹ ${value.toStringAsFixed(0)}",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
