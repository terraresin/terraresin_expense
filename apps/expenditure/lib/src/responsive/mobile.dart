import 'package:flutter/material.dart';

import '../screens/dashboard/dashboard_screen.dart';
import '../screens/masters/finance_masters_screen.dart';
import '../screens/reports/finance_reports_screen.dart';
import '../screens/transactions/transactions_screen.dart';

class MobileLayout extends StatefulWidget {
  const MobileLayout({super.key});

  @override
  State<MobileLayout> createState() => _MobileLayoutState();
}

class _MobileLayoutState extends State<MobileLayout> {
  int selectedIndex = 0;

  static const navigationItems = [
    _MobileNavigationItem(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'Home',
      title: 'Dashboard',
    ),
    _MobileNavigationItem(
      icon: Icons.swap_horiz_outlined,
      selectedIcon: Icons.swap_horiz,
      label: 'Transactions',
      title: 'Transactions',
    ),
    _MobileNavigationItem(
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
      label: 'Masters',
      title: 'Finance Masters',
    ),
    _MobileNavigationItem(
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart,
      label: 'Reports',
      title: 'Finance Reports',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentItem = navigationItems[selectedIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(currentItem.title),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifications',
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
            tooltip: 'More',
          ),
        ],
      ),

      body: _buildContent(),

      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        labelBehavior: MediaQuery.sizeOf(context).width < 380
            ? NavigationDestinationLabelBehavior.onlyShowSelected
            : NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: navigationItems
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: item.label,
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

class _MobileNavigationItem {
  const _MobileNavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.title,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String title;
}
