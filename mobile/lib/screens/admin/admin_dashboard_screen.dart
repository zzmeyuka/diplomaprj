import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/admin_service.dart';
import '../../widgets/loading_widget.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      _stats = await context.read<AdminService>().stats();
    } catch (_) {
      _stats = null;
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: _loading
          ? const LoadingWidget()
          : _stats == null
              ? const Center(child: Text('Failed to load stats'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: _stats!.entries
                      .map(
                        (e) => Card(
                          child: ListTile(
                            title: Text(e.key),
                            trailing: Text('${e.value}'),
                          ),
                        ),
                      )
                      .toList(),
                ),
    );
  }
}
