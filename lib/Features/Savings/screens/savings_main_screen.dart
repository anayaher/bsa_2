import 'package:BSA/Features/Savings/gold_db.dart';
import 'package:BSA/Features/Savings/screens/add_gold_screen.dart';
import 'package:BSA/Features/Savings/screens/gold_list_screen.dart';
import 'package:flutter/material.dart';

class SavingsMainScreen extends StatefulWidget {
  const SavingsMainScreen({super.key});

  @override
  State<SavingsMainScreen> createState() => _SavingsMainScreenState();
}

class _SavingsMainScreenState extends State<SavingsMainScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Savings")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            FutureBuilder<double>(
              future: GoldDB.instance.fetchTotalGoldValue(),
              builder: (context, snapshot) {
                final total = snapshot.data ?? 0;

                return _loanCard(
                  title: "Gold",
                  amount: total.toString(),
                  isVehicleCard: true,
                  icon: Icons.currency_rupee,
                  color: const Color(0XFFEFBF04),
                  iconColor: Colors.black,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const GoldListScreen()),
                    );
                  },
                );
              },
            ),

            SizedBox(height: 20),
            _loanCard(
              title: "Shares",
              amount: "",
              isVehicleCard: true,
              icon: Icons.money,
              color: Colors.blueAccent,
              iconColor: Colors.black,
              onTap: () {},
            ),
            SizedBox(height: 20),
            _loanCard(
              title: "GPF",
              amount: "",
              isVehicleCard: true,
              icon: Icons.money,
              color: Colors.pink,
              iconColor: Colors.black,
              onTap: () {},
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

Widget _loanCard({
  int? badgeCount,
  required String title,
  required String amount,
  bool isVehicleCard = false,
  required IconData icon,
  required Color color,
  required Color iconColor,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Container(
      width: isVehicleCard ? double.infinity : 175,
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          /// LEFT → Title (takes max space)
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),

          /// RIGHT → Amount (sticks to edge)
          Text(
            amount.isEmpty ? '--' : '₹ $amount',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}
