import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/founders/founder_providers.dart';

class FounderFormDialog extends ConsumerStatefulWidget {
  const FounderFormDialog({super.key});

  @override
  ConsumerState<FounderFormDialog> createState() => _FounderFormDialogState();
}

class _FounderFormDialogState extends ConsumerState<FounderFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _contactController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await ref.read(founderRepositoryProvider).createFounder({
        'name': _nameController.text.trim(),
        'code': _codeController.text.trim().toUpperCase(),
        'contact': _contactController.text.trim(),
        'is_active': true,
      });
      ref.invalidate(foundersProvider);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add founder: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = MediaQuery.sizeOf(context).width < 600;

    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isPhone ? 12 : 40,
        vertical: isPhone ? 16 : 24,
      ),
      titlePadding: EdgeInsets.fromLTRB(
        isPhone ? 20 : 24,
        isPhone ? 20 : 24,
        isPhone ? 20 : 24,
        8,
      ),
      contentPadding: EdgeInsets.fromLTRB(
        isPhone ? 20 : 24,
        0,
        isPhone ? 20 : 24,
        8,
      ),
      actionsPadding: EdgeInsets.fromLTRB(
        isPhone ? 20 : 24,
        0,
        isPhone ? 20 : 24,
        isPhone ? 16 : 8,
      ),
      title: Text(
        'Add Founder',
        style: isPhone ? const TextStyle(fontSize: 26) : null,
      ),
      content: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Founder Name*'),
                  validator: _required('founder name'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'Code*',
                    hintText: 'FO-004',
                  ),
                  validator: _required('founder code'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contactController,
                  decoration: const InputDecoration(labelText: 'Contact'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _isSaving ? null : _save,
          icon: _isSaving
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.add),
          label: Text(_isSaving ? 'Adding...' : 'Add Founder'),
        ),
      ],
    );
  }

  String? Function(String?) _required(String field) {
    return (value) =>
        value == null || value.trim().isEmpty ? 'Please enter $field' : null;
  }
}
