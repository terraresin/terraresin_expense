import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/categories/category_providers.dart';

class CategoryFormDialog extends ConsumerStatefulWidget {
  const CategoryFormDialog({super.key});

  @override
  ConsumerState<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends ConsumerState<CategoryFormDialog> {
  static const categoryTypes = [
    'Expense',
    'Income/Contribution',
    'Liability/Adjustment',
    'Non-business',
    'Transfer',
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _categoryType = categoryTypes.first;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await ref.read(categoryRepositoryProvider).createCategory({
        'name': _nameController.text.trim(),
        'category_type': _categoryType,
        'description': _descriptionController.text.trim(),
        'is_active': true,
      });
      ref.invalidate(categoriesProvider);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add category: $error')),
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
        'Add Category',
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
                  decoration: const InputDecoration(labelText: 'Category*'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Please enter a category name'
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _categoryType,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Type*'),
                  items: categoryTypes
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: _isSaving
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() => _categoryType = value);
                          }
                        },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Description'),
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
          label: Text(_isSaving ? 'Adding...' : 'Add Category'),
        ),
      ],
    );
  }
}
