import 'package:flutter/material.dart';
import '../models/table_config.dart';

class TableConfigForm extends StatefulWidget {
  final TableConfig? initialConfig;
  final Function(TableConfig) onSave;

  const TableConfigForm({
    super.key,
    this.initialConfig,
    required this.onSave,
  });

  @override
  State<TableConfigForm> createState() => _TableConfigFormState();
}

class _TableConfigFormState extends State<TableConfigForm> {
  final _formKey = GlobalKey<FormState>();
  final _tableNameController = TextEditingController();
  final _archivalDaysController = TextEditingController();
  final _purgeDaysController = TextEditingController();
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialConfig != null) {
      _tableNameController.text = widget.initialConfig!.tableName;
      _archivalDaysController.text = widget.initialConfig!.archivalDays.toString();
      _purgeDaysController.text = widget.initialConfig!.purgeDays.toString();
      _isActive = widget.initialConfig!.isActive;
    }
  }

  @override
  void dispose() {
    _tableNameController.dispose();
    _archivalDaysController.dispose();
    _purgeDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialConfig == null ? 'Add Configuration' : 'Edit Configuration'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _tableNameController,
                decoration: const InputDecoration(
                  labelText: 'Table Name',
                  hintText: 'Enter table name',
                ),
                enabled: widget.initialConfig == null, // Don't allow editing table name
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Table name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _archivalDaysController,
                decoration: const InputDecoration(
                  labelText: 'Archival Days',
                  hintText: 'Enter number of days',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Archival days is required';
                  }
                  final days = int.tryParse(value);
                  if (days == null || days < 1) {
                    return 'Archival days must be at least 1';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _purgeDaysController,
                decoration: const InputDecoration(
                  labelText: 'Purge Days',
                  hintText: 'Enter number of days',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Purge days is required';
                  }
                  final days = int.tryParse(value);
                  if (days == null || days < 1) {
                    return 'Purge days must be at least 1';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Active'),
                subtitle: const Text('Enable/disable this configuration'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveConfiguration,
          child: Text(widget.initialConfig == null ? 'Create' : 'Update'),
        ),
      ],
    );
  }

  void _saveConfiguration() {
    if (_formKey.currentState!.validate()) {
      final config = TableConfig(
        id: widget.initialConfig?.id,
        tableName: _tableNameController.text.trim(),
        archivalDays: int.parse(_archivalDaysController.text),
        purgeDays: int.parse(_purgeDaysController.text),
        isActive: _isActive,
      );
      
      widget.onSave(config);
    }
  }
}