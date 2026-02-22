import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class GoldReportScreen extends StatefulWidget {
  const GoldReportScreen({super.key});

  @override
  State<GoldReportScreen> createState() => _JkReportListScreenState();
}

class _JkReportListScreenState extends State<GoldReportScreen> {
  List<FileSystemEntity> _files = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final dir = await getApplicationDocumentsDirectory();
    final reportDir = Directory('${dir.path}/goldReports');
    if (await reportDir.exists()) {
      setState(() {
        _files =
            reportDir.listSync().where((f) => f.path.endsWith('.pdf')).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Saved Reports")),
      body:
          _files.isEmpty
              ? const Center(child: Text("No reports found"))
              : ListView.builder(
                itemCount: _files.length,
                itemBuilder: (_, i) {
                  final file = _files[i];
                  final name = file.path.split('/').last;

                  return Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.red,
                      ),
                      title: Text(name),
                      onTap: () => OpenFile.open(file.path),
                    ),
                  );
                },
              ),
    );
  }
}
