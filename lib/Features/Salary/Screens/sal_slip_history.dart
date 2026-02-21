import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Fetch all saved salary slip PDFs
Future<List<File>> getSavedSalarySlips() async {
  final dir = await getApplicationDocumentsDirectory();
  final slipDir = Directory('${dir.path}/salaryslip');

  if (!await slipDir.exists()) return [];

  final files =
      slipDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.pdf'))
          .toList();

  // Latest first
  files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));

  return files;
}

class SalSlipHistory extends StatefulWidget {
  const SalSlipHistory({super.key});

  @override
  State<SalSlipHistory> createState() => _SalSlipHistoryState();
}

class _SalSlipHistoryState extends State<SalSlipHistory> {
  late Future<List<File>> _filesFuture;

  @override
  void initState() {
    super.initState();
    _filesFuture = getSavedSalarySlips();
  }

  void _refresh() {
    setState(() {
      _filesFuture = getSavedSalarySlips();
    });
  }

  Future<void> _deleteFile(File file) async {
    final fileName = file.path.split('/').last;

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Salary Slip'),
            content: Text('Are you sure you want to delete "$fileName"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    await file.delete();

    if (!mounted) return;
    _refresh();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Salary slip deleted')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Salary Slips')),
      body: FutureBuilder<List<File>>(
        future: _filesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No salary slips found',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final files = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: files.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, index) {
              final file = files[index];
              final name = file.path.split('/').last;
              final date = file.statSync().modified;

              return ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  'Saved on ${date.day}-${date.month}-${date.year}',
                ),
                onTap: () {
                  OpenFile.open(file.path);
                },
                onLongPress: () {
                  _showSlipActions(context, file);
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showSlipActions(BuildContext context, File file) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.open_in_new),
                title: const Text('Open'),
                onTap: () {
                  Navigator.pop(context);
                  OpenFile.open(file.path);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share'),
                onTap: () {
                  Navigator.pop(context);
                  Share.shareXFiles([XFile(file.path)]);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await _confirmDelete(context, file);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, File file) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete Salary Slip?'),
            content: const Text(
              'This salary slip will be permanently deleted.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await file.delete();
      if (!mounted) return;
      _refresh();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Salary slip deleted')));
    }
  }
}
