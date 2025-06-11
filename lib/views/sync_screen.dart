import 'package:flutter/material.dart';
import '../controllers/sync_controller.dart';
import '../controllers/configuration_controller.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({Key? key}) : super(key: key);

  @override
  _SyncScreenState createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  final SyncController _syncController = SyncController();
  final ConfigurationController _configController = ConfigurationController();
  
  bool _isSyncing = false;
  String _syncStatus = '';
  String _lastSyncDate = 'Never';
  String _serverUrl = '';
  List<String> _syncLog = [];

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final config = await _configController.getConfiguration();
    if (config != null) {
      setState(() {
        _serverUrl = config.serverUrl;
        _lastSyncDate = config.lastSync ?? 'Never';
      });
    }
  }

  Future<void> _syncData() async {
    if (_serverUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Server URL not configured. Please set it in the Configuration screen.')),
      );
      return;
    }

    setState(() {
      _isSyncing = true;
      _syncStatus = 'Starting synchronization...';
      _syncLog = [];
    });

    try {
      // Sync users
      setState(() {
        _syncStatus = 'Synchronizing users...';
        _syncLog.add('Synchronizing users...');
      });
      final userResult = await _syncController.syncUsers();
      setState(() {
        _syncLog.add('Users sync result: $userResult');
      });

      // Sync clients
      setState(() {
        _syncStatus = 'Synchronizing clients...';
        _syncLog.add('Synchronizing clients...');
      });
      final clientResult = await _syncController.syncClients();
      setState(() {
        _syncLog.add('Clients sync result: $clientResult');
      });

      // Sync products
      setState(() {
        _syncStatus = 'Synchronizing products...';
        _syncLog.add('Synchronizing products...');
      });
      final productResult = await _syncController.syncProducts();
      setState(() {
        _syncLog.add('Products sync result: $productResult');
      });

      // Sync orders
      setState(() {
        _syncStatus = 'Synchronizing orders...';
        _syncLog.add('Synchronizing orders...');
      });
      final orderResult = await _syncController.syncOrders();
      setState(() {
        _syncLog.add('Orders sync result: $orderResult');
      });

      // Update last sync date
      final now = DateTime.now().toIso8601String();
      await _configController.updateLastSync(now);
      setState(() {
        _lastSyncDate = now;
        _syncStatus = 'Synchronization completed successfully';
        _syncLog.add('Synchronization completed at $now');
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Synchronization completed successfully')),
      );
    } catch (e) {
      setState(() {
        _syncStatus = 'Synchronization failed: ${e.toString()}';
        _syncLog.add('Error: ${e.toString()}');
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Synchronization failed: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Synchronization'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Server URL: $_serverUrl',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Last Sync: $_lastSyncDate',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSyncing ? null : _syncData,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: _isSyncing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Sync Now'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Status: $_syncStatus',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sync Log:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Card(
                child: ListView.builder(
                  itemCount: _syncLog.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(_syncLog[index]),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}