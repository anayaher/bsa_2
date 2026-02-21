import 'package:BSA/Features/jamaKharcha/screens/transaction_report.dart';
import 'package:flutter/material.dart';

class ReportMainScreen extends StatelessWidget {
  const ReportMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reports")),
      body: Column(
        children: [
          ListTile(
            title: Text("Jama-Kharcha Report"),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TransactionReportScreen(),
                ),
              );
            },
          ),
          // ListTile(
          //   title: Text("Salary Report"),
          //   onTap: () {
          //     // Navigate to Salary Report Screen
          //   },
          // ),
        ],
      ),
    );
  }
}
