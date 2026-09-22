import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:terraresin_design_system/design_system.dart';

import '../../providers/categories/category_providers.dart';
import '../../providers/founders/founder_providers.dart';
import '../banks/banks_screen.dart';
import 'category_form_dialog.dart';
import 'founder_form_dialog.dart';

class FinanceMastersScreen extends StatelessWidget {
  const FinanceMastersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: TerraResinColors.background,
        appBar: AppBar(
          title: const Text('Finance Masters'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Founders'),
              Tab(text: 'Categories'),
              Tab(text: 'Banks'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            FoundersTab(),
            CategoriesTab(),
            BanksScreen(showAddButton: true),
          ],
        ),
      ),
    );
  }
}

class FoundersTab extends ConsumerWidget {
  const FoundersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final founders = ref.watch(foundersProvider);
    final isPhone = MediaQuery.sizeOf(context).width < 600;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Align(
            alignment: isPhone ? Alignment.centerLeft : Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () => showDialog<bool>(
                context: context,
                builder: (context) => const FounderFormDialog(),
              ),
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Add Founder'),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: founders.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Unable to load founders: $error'),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => ref.invalidate(foundersProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (items) => items.isEmpty
                  ? const Center(child: Text('No founders found.'))
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final founder = items[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: TerraResinColors.primary
                                  .withValues(alpha: 0.12),
                              child: const Icon(
                                Icons.person,
                                color: TerraResinColors.primary,
                              ),
                            ),
                            title: Text(founder['name'] as String? ?? ''),
                            subtitle: Text(
                              'Code: ${founder['code']}\n'
                              'Contact: ${founder['contact'] ?? '-'}',
                            ),
                            trailing: Chip(
                              label: const Text('Active'),
                              backgroundColor: Colors.green.shade50,
                              side: BorderSide.none,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoriesTab extends ConsumerWidget {
  const CategoriesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final isPhone = MediaQuery.sizeOf(context).width < 600;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Align(
            alignment: isPhone ? Alignment.centerLeft : Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () => showDialog<bool>(
                context: context,
                builder: (context) => const CategoryFormDialog(),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add Category'),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: categories.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Unable to load categories: $error'),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => ref.invalidate(categoriesProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (items) => _CategoryGrid(categories: items),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.categories});

  final List<Map<String, dynamic>> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Center(child: Text('No categories found.'));
    }

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                headingRowColor: WidgetStatePropertyAll(
                  TerraResinColors.primary.withValues(alpha: 0.08),
                ),
                columns: const [
                  DataColumn(label: Text('Sno')),
                  DataColumn(label: Text('Category')),
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Description')),
                ],
                rows: categories.indexed.map((entry) {
                  final index = entry.$1;
                  final category = entry.$2;
                  return DataRow(
                    cells: [
                      DataCell(
                        Text('${category['display_order'] ?? index + 1}'),
                      ),
                      DataCell(
                        SizedBox(
                          width: 220,
                          child: Text(
                            category['name'] as String? ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 150,
                          child: Text(
                            category['category_type'] as String? ?? '',
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 380,
                          child: Text(category['description'] as String? ?? ''),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
