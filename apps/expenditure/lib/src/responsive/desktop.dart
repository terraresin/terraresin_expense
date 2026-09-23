import 'package:flutter/material.dart';
import 'package:terraresin_design_system/design_system.dart';

import '../screens/dashboard/dashboard_screen.dart';
import '../screens/masters/finance_masters_screen.dart';
import '../screens/reports/finance_reports_screen.dart';
import '../screens/transactions/transactions_screen.dart';

class DesktopLayout extends StatefulWidget {
  const DesktopLayout({super.key});

  @override
  State<DesktopLayout> createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends State<DesktopLayout> {
  int selectedIndex = 0;
  ReportKind _selectedReport = ReportKind.expenditure;
  bool _reportsExpanded = false;

  static const navigationItems = [
    _NavigationItem(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'Dashboard',
    ),
    _NavigationItem(
      icon: Icons.swap_horiz_outlined,
      selectedIcon: Icons.swap_horiz,
      label: 'Transactions',
    ),
    _NavigationItem(
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
      label: 'Masters',
    ),
    _NavigationItem(
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart,
      label: 'Reports',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(context),
          Expanded(child: _buildContent(context)),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      shape: Border(right: BorderSide(color: Theme.of(context).dividerColor)),
      child: SizedBox(
        width: 250,
        child: Column(
          children: [
            const SizedBox(height: 28),

            _buildBrand(context),

            const SizedBox(height: 32),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: navigationItems.length,
                itemBuilder: (context, index) {
                  return _buildNavigationItem(
                    context,
                    index,
                    navigationItems[index],
                  );
                },
              ),
            ),

            _buildSettings(context),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBrand(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            height: 42,
            child: Image.asset(
              'assets/TerraResin_Logo.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'TerraResin',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItem(
    BuildContext context,
    int index,
    _NavigationItem item,
  ) {
    final isSelected = selectedIndex == index;

    if (index == 3) {
      return _buildReportsMenu(context, item);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        selected: isSelected,
        selectedTileColor: TerraResinColors.primary.withValues(alpha: 0.10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        leading: Icon(
          isSelected ? item.selectedIcon : item.icon,
          color: isSelected
              ? TerraResinColors.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        title: Text(
          item.label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? TerraResinColors.primary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildReportsMenu(BuildContext context, _NavigationItem item) {
    final isSelected = selectedIndex == 3;

    return ExpansionTile(
      initiallyExpanded: _reportsExpanded,
      onExpansionChanged: (expanded) {
        setState(() {
          _reportsExpanded = expanded;
          if (expanded) selectedIndex = 3;
        });
      },
      leading: Icon(
        isSelected ? item.selectedIcon : item.icon,
        color: isSelected
            ? TerraResinColors.primary
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(
        item.label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected
              ? TerraResinColors.primary
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
      children: ReportKind.values
          .map(
            (report) => ListTile(
              contentPadding: const EdgeInsets.only(left: 52, right: 12),
              selected: isSelected && _selectedReport == report,
              title: Text(report.title),
              onTap: () {
                setState(() {
                  selectedIndex = 3;
                  _selectedReport = report;
                });
              },
            ),
          )
          .toList(),
    );
  }

  Widget _buildSettings(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListTile(
        leading: const Icon(Icons.settings_outlined),
        title: const Text('Settings'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onTap: () {},
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    const titles = ['Dashboard', 'Transactions', 'Masters', 'Reports'];

    Widget content;

    switch (selectedIndex) {
      case 0:
        content = const DashboardScreen();
        break;
      case 1:
        content = const TransactionsScreen();
        break;
      case 2:
        content = const FinanceMastersScreen();
        break;
      case 3:
        content = FinanceReportsScreen(initialReport: _selectedReport);
        break;
      default:
        content = Center(
          child: Text(
            titles[selectedIndex],
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[selectedIndex]),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifications',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: content,
    );
  }
}

class _NavigationItem {
  const _NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
