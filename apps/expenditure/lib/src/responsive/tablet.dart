import 'package:flutter/material.dart';

import '../screens/dashboard/dashboard_screen.dart';
import '../screens/masters/finance_masters_screen.dart';
import '../screens/reports/finance_reports_screen.dart';
import '../screens/transactions/transactions_screen.dart';

class TabletLayout extends StatefulWidget {
  const TabletLayout({super.key});

  @override
  State<TabletLayout> createState() => _TabletLayoutState();
}

class _TabletLayoutState extends State<TabletLayout> {
  int selectedIndex = 0;

  static const navigationItems = [
    _TabletNavigationItem(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'Dashboard',
    ),
    _TabletNavigationItem(
      icon: Icons.swap_horiz_outlined,
      selectedIcon: Icons.swap_horiz,
      label: 'Transactions',
    ),
    _TabletNavigationItem(
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
      label: 'Masters',
    ),
    _TabletNavigationItem(
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
          _buildNavigationRail(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildNavigationRail() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: NavigationRail(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        labelType: NavigationRailLabelType.all,
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Image.asset(
              'assets/TerraResin_Logo.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        destinations: navigationItems
            .map(
              (item) => NavigationRailDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: Text(item.label),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildContent() {
    switch (selectedIndex) {
      case 0:
        return const DashboardScreen();

      case 1:
        return const TransactionsScreen();

      case 2:
        return const FinanceMastersScreen();

      case 3:
        return const FinanceReportsScreen();

      default:
        return const DashboardScreen();
    }
  }
}

class _TabletNavigationItem {
  const _TabletNavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
