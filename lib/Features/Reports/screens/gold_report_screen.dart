import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class GoldReportScreen extends StatefulWidget {
  const GoldReportScreen({super.key});

  @override
  State<GoldReportScreen> createState() => _GoldReportScreenState();
}

class _GoldReportScreenState extends State<GoldReportScreen> {
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
        _files = reportDir
            .listSync()
            .where((f) => f.path.endsWith('.pdf'))
            .toList()
          ..sort(
            (a, b) =>
                b.statSync().modified.compareTo(a.statSync().modified),
          );
      });
    }
  }

  Future<bool> _confirmDelete(String fileName) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete report?'),
            content: Text('Are you sure you want to delete "$fileName"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _deleteFile(FileSystemEntity file) async {
    await file.delete();
    _loadReports();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Saved Reports")),
      body: _files.isEmpty
          ? const Center(child: Text("No reports found"))
          : ListView.builder(
              itemCount: _files.length,
              itemBuilder: (_, i) {
                final file = _files[i];
                final name = file.path.split('/').last;

                return Dismissible(
                  key: ValueKey(file.path),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) => _confirmDelete(name),
                  onDismissed: (_) => _deleteFile(file),
                  child: Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.red,
                      ),
                      title: Text(name),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => OpenFile.open(file.path),
                    ),
                  ),
                );
              },
            ),
    );
  }
}