import 'package:flutter/material.dart';
import '../controllers/configuration_controller.dart';
import '../models/configuration.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({Key? key}) : super(key: key);

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  final ConfigurationController _configController = ConfigurationController();
  final _formKey = GlobalKey<FormState>();
  final _serverUrlController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;
  String? _lastSync;

  @override
  void initState() {
    super.initState();
    _loadConfiguration();
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadConfiguration() async {
    setState(() {
      _isLoading = true;
    });

    final config = await _configController.getConfiguration();
    if (config != null) {
      setState(() {
        _serverUrlController.text = config.serverUrl;
        _lastSync = config.lastSync;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveConfiguration() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      try {
        final config = Configuration(
          serverUrl: _serverUrlController.text,
          lastSync: _lastSync,
        );

        await _configController.saveConfiguration(config);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Configuration saved successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving configuration: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _serverUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Server URL *',
                        hintText: 'https://example.com/api',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the server URL';
                        }
                        if (!value.startsWith('http://') && !value.startsWith('https://')) {
                          return 'URL must start with http:// or https://';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_lastSync != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          'Last Synchronization: $_lastSync',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveConfiguration,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator()
                            : const Text('Save Configuration'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}