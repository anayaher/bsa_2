import 'package:BSA/Features/Home/Screens/home_provider.dart';
import 'package:BSA/Features/Home/widgets/salary_card.dart';
import 'package:BSA/Features/Insurance/data/insurance_db.dart';
import 'package:BSA/Features/Reports/screens/record_main.dart';
import 'package:BSA/Features/Salary/Screens/deductions_screen.dart';
import 'package:BSA/Features/Salary/Screens/sal_slip_screen.dart';
import 'package:BSA/Features/Salary/Screens/salary_screen.dart';
import 'package:BSA/Features/Salary/db/deduction_db.dart';
import 'package:BSA/Features/Salary/db/salary_db.dart';
import 'package:BSA/Features/Savings/screens/savings_main_screen.dart';
import 'package:BSA/Features/Vehicles/db/vehicle_db.dart';
import 'package:BSA/Features/Vehicles/screens/vehicles_list_screen.dart';
import 'package:BSA/Features/jamaKharcha/db/transaction_db.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    final homeAsync = ref.watch(homeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      drawer: _buildAppDrawer(context),

      body: homeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (home) {
          final expiredCount = home.expiredCount;
          totalJama = home.totalJama;
          totalKharcha = home.totalKharcha;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                _salarySummaryCard(),

                const SizedBox(height: 20),
                _jamaKharchaHighlightCard(),

                const SizedBox(height: 20),
                _vehicleCard(
                  badgeCount: expiredCount,
                  title: "Vehicles",
                  isVehicleCard: true,
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
                const SizedBox(height: 20),

                _loanCard(
                  title: "Loans",
                  icon: Icons.currency_rupee,
                  isVehicleCard: true,
                  color: Colors.green.shade50,
                  iconColor: Colors.green,
                  onTap: () => _comingSoon(),
                ),
                SizedBox(height: 20),
                _loanCard(
                  title: "Savings",
                  icon: Icons.currency_rupee,
                  isVehicleCard: true,
                  color: Colors.green.shade50,
                  iconColor: Colors.yellow.shade600,
                  onTap:
                      () => {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return SavingsMainScreen();
                            },
                          ),
                        ),
                      },
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
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
            leading: const Icon(Icons.report),
            title: const Text("Reports"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportMainScreen()),
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
    bool isVehicleCard = false,
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
            width: isVehicleCard ? double.infinity : 175,
            height: 180,
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

  Widget _vehicleCard({
    int? badgeCount,
    required String title,
    bool isVehicleCard = false,
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
            width: isVehicleCard ? double.infinity : 175,
            height: 140,
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _loanCard({
    int? badgeCount,
    required String title,
    bool isVehicleCard = false,
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
            width: isVehicleCard ? double.infinity : 175,
            height: 140,
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
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
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
    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => TransactionScreen()));
      },
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "Jama - Kharcha",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Column(
              children: [
                // JAMA Highlight (Most Weight)
                _amountBox(
                  "Jama",
                  totalJama,
                  Colors.green.shade700,
                  Icons.arrow_downward_rounded,
                ),

                const SizedBox(height: 12),

                // KHARCHA
                _amountBox(
                  "Kharcha",
                  totalKharcha,
                  Colors.red.shade700,
                  Icons.arrow_upward_rounded,
                ),

                const SizedBox(height: 12),

                // BALANCE
                _amountBox(
                  "Balance",
                  netBalance,
                  netBalance >= 0 ? Colors.blue.shade700 : Colors.red.shade700,
                  Icons.account_balance_wallet_rounded,
                ),
              ],
            ),
          ],
        ),
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
      child: Row(
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 5),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
          Text(
            " ${value.toStringAsFixed(0)}",
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
    return Row(
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
