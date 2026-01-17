import 'package:BSA/Features/Salary/Screens/sal_slip_screen.dart';
import 'package:flutter/material.dart';

class AnimatedSalaryCard extends StatefulWidget {
  final int totalSalary;
  final int totalDeduction;
  final int netSalary;

  const AnimatedSalaryCard({
    super.key,
    required this.totalSalary,
    required this.totalDeduction,
    required this.netSalary,
  });

  @override
  State<AnimatedSalaryCard> createState() => _AnimatedSalaryCardState();
}

class _AnimatedSalaryCardState extends State<AnimatedSalaryCard> {
  bool hideSalary = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade200, Colors.purple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.payments_rounded,
                color: Colors.deepPurple,
                size: 28,
              ),
              const SizedBox(width: 10),
              const Text(
                "Salary Overview",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 10),

              GestureDetector(
                onTap: () {
                  setState(() {
                    hideSalary = !hideSalary;
                  });
                },
                child:
                    hideSalary
                        ? Icon(Icons.visibility_off)
                        : Icon(Icons.visibility),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Column(
            children: [
              _salaryBox(
                title: "Total Salary",
                value: widget.totalSalary,
                color: Colors.green.shade700,
                icon: Icons.trending_up_rounded,
              ),
              SizedBox(height: 4),
              _salaryBox(
                title: "Deductions",
                value: widget.totalDeduction,
                color: Colors.red.shade700,
                icon: Icons.trending_down_rounded,
              ),
            ],
          ),

          const SizedBox(height: 4),

          _netSalaryBox(),

          const SizedBox(height: 22),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple.shade700,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SalarySlipScreen()),
                );
              },
              icon: const Icon(Icons.receipt_long, color: Colors.white),
              label: const Text(
                "View Salary Slip",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _salaryBox({
    required String title,
    required int value,

    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),

          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: value),
            duration: const Duration(milliseconds: 800),
            builder: (context, val, child) {
              return hideSalary
                  ? Text(
                    "₹ •••••",
                    key: const ValueKey('hidden'),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  )
                  : Text(
                    "₹ ${_format(val)}",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  );
            },
          ),
        ],
      ),
    );
  }

  Widget _netSalaryBox() {
    final color =
        widget.netSalary >= 0 ? Colors.blue.shade700 : Colors.red.shade700;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white, Colors.blue.shade50]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Net Salary",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 5),

          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: widget.netSalary),
            duration: const Duration(milliseconds: 900),
            builder: (context, val, child) {
              return hideSalary
                  ? Text(
                    "₹ •••••",
                    key: const ValueKey('hidden'),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  )
                  : Text(
                    "₹ ${_format(val)}",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  );
            },
          ),
        ],
      ),
    );
  }

  String _format(int value) {
    final str = value.toString();
    return str.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}
