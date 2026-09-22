import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:terraresin_design_system/design_system.dart';

import '../../formatters/currency_formatter.dart';
import '../../providers/accounts/account_providers.dart';
import '../../providers/accounts/bank_balance_providers.dart';
import '../../providers/founders/founder_providers.dart';
import '../../providers/transactions/transaction_providers.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _selectedDateFilter = 'All Dates';

  @override
  Widget build(BuildContext context) {
    final bankBalancesAsync = ref.watch(companyBankBalancesProvider);
    final transactionsAsync = ref.watch(transactionsProvider);
    final founders = ref.watch(foundersProvider).value ?? const [];

    return Scaffold(
      backgroundColor: TerraResinColors.background,
      body: SafeArea(
        child: bankBalancesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildLoadError(error),
          data: (banks) => transactionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildLoadError(error),
            data: (transactions) {
              // 1. Filter transactions based on date filter selection
              final filteredTransactions = _filterTransactions(transactions);

              // 2. Derive metrics from source of truth (underlying transactions)
              double totalBankBalance = banks.fold(
                0.0,
                (sum, b) => sum + b.balance,
              );
              double totalCashBalance = 0.0;
              double totalReceipts = 0.0;
              double totalPayments = 0.0;
              double totalExpenses = 0.0;
              double founderContributions = 0.0;
              double pendingCheques = 0.0;

              for (final t in filteredTransactions) {
                final amount = (t['amount'] as num?)?.toDouble() ?? 0.0;
                final direction = t['direction'] as String? ?? 'debit';
                final type = t['transaction_type'] as String? ?? '';
                final pMethod = t['payment_method'] as String? ?? '';
                final categoryData = t['categories'];
                final categoryType = categoryData is Map
                    ? categoryData['category_type'] as String? ?? ''
                    : '';

                if (direction == 'credit') {
                  totalReceipts += amount;
                } else if (direction == 'debit') {
                  totalPayments += amount;
                }

                if (direction == 'debit' && categoryType == 'Expense') {
                  totalExpenses += amount;
                }

                if (type == 'founder_contribution') {
                  founderContributions += amount;
                }

                if (pMethod == 'cheque') {
                  pendingCheques += amount;
                }
              }

              double netCashFlow = totalReceipts - totalPayments;

              // 3. Compute Category Aggregations for Charts
              final categoryMap = <String, double>{};
              for (final t in filteredTransactions) {
                final direction = t['direction'] as String? ?? 'debit';
                if (direction == 'debit') {
                  final categoryData = t['categories'];
                  final cat = categoryData is Map
                      ? categoryData['name'] as String? ?? 'General Expense'
                      : 'General Expense';
                  final amt = (t['amount'] as num?)?.toDouble() ?? 0.0;
                  categoryMap[cat] = (categoryMap[cat] ?? 0.0) + amt;
                }
              }
              // 4. Compute Founder Aggregations from founder relationships.
              final founderNamesById = <String, String>{
                for (final founder in founders)
                  founder['id'] as String:
                      founder['name'] as String? ?? 'Unknown Founder',
              };
              final founderMap = <String, double>{
                for (final name in founderNamesById.values) name: 0,
              };
              for (final t in filteredTransactions) {
                final type = t['transaction_type'] as String? ?? '';
                final founderId = t['founder_id'] as String?;
                if (type == 'founder_contribution' && founderId != null) {
                  final founderName = founderNamesById[founderId];
                  if (founderName == null) continue;
                  final amt = (t['amount'] as num?)?.toDouble() ?? 0.0;
                  founderMap[founderName] =
                      (founderMap[founderName] ?? 0.0) + amt;
                }
              }
              founderContributions = founderMap.values.fold(
                0,
                (sum, amount) => sum + amount,
              );

              return LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final isDesktop = width >= 1100;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Toolbar
                        if (width < 800)
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TerraResin Finance Dashboard',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: TerraResinColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Real-time financial overview from the transaction engine',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: TerraResinColors.textSecondary,
                                ),
                              ),
                            ],
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'TerraResin Finance Dashboard',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: TerraResinColors.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Real-time financial overview from the transaction engine',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: TerraResinColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              DropdownButton<String>(
                                value: _selectedDateFilter,
                                underline: const SizedBox(),
                                icon: const Icon(
                                  Icons.filter_alt_outlined,
                                  color: TerraResinColors.primary,
                                ),
                                items:
                                    [
                                          'All Dates',
                                          'Today',
                                          'This Week',
                                          'This Month',
                                          'This Quarter',
                                          'This Financial Year',
                                        ]
                                        .map(
                                          (f) => DropdownMenuItem(
                                            value: f,
                                            child: Text(
                                              f,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (v) {
                                  if (v != null) {
                                    setState(() => _selectedDateFilter = v);
                                  }
                                },
                              ),
                            ],
                          ),
                        if (width < 800) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: DropdownButton<String>(
                              value: _selectedDateFilter,
                              underline: const SizedBox(),
                              icon: const Icon(
                                Icons.filter_alt_outlined,
                                color: TerraResinColors.primary,
                              ),
                              items:
                                  [
                                        'All Dates',
                                        'Today',
                                        'This Week',
                                        'This Month',
                                        'This Quarter',
                                        'This Financial Year',
                                      ]
                                      .map(
                                        (f) => DropdownMenuItem(
                                          value: f,
                                          child: Text(
                                            f,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  setState(() => _selectedDateFilter = v);
                                }
                              },
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),

                        // 8 Metrics Grid Architecture
                        GridView.count(
                          crossAxisCount: width < 900 ? 2 : 4,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: width < 600 ? 1.1 : 1.6,
                          children: [
                            _buildMetricCard(
                              'Total Bank Balance',
                              totalBankBalance,
                              Icons.account_balance,
                              Colors.blue,
                            ),
                            _buildMetricCard(
                              'Cash Balance',
                              totalCashBalance,
                              Icons.money,
                              Colors.orange,
                            ),
                            _buildMetricCard(
                              'Total Receipts',
                              totalReceipts,
                              Icons.arrow_upward,
                              Colors.green,
                            ),
                            _buildMetricCard(
                              'Total Payments',
                              totalPayments,
                              Icons.arrow_downward,
                              Colors.red,
                            ),
                            _buildMetricCard(
                              'Total Expenses',
                              totalExpenses,
                              Icons.trending_down,
                              Colors.purple,
                            ),
                            _buildMetricCard(
                              'Founder Contributions',
                              founderContributions,
                              Icons.people,
                              Colors.teal,
                            ),
                            _buildMetricCard(
                              'Pending Cheques',
                              pendingCheques,
                              Icons.hourglass_empty,
                              Colors.amber,
                            ),
                            _buildMetricCard(
                              'Net Cashflow',
                              netCashFlow,
                              Icons.pie_chart,
                              Colors.indigo,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        _buildCategorySummaryCard(categoryMap),
                        const SizedBox(height: 24),

                        // Master Accounts & Contribution Aggregations Side-by-Side
                        if (isDesktop)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildBankBalancesSection(banks)),
                              const SizedBox(width: 24),
                              Expanded(
                                child: _buildFounderContributionsSection(
                                  founderMap,
                                ),
                              ),
                            ],
                          )
                        else ...[
                          _buildBankBalancesSection(banks),
                          const SizedBox(height: 24),
                          _buildFounderContributionsSection(founderMap),
                        ],
                        const SizedBox(height: 24),

                        // Recent Transactions Journal Ledger
                        _buildRecentTransactionsLedger(filteredTransactions),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadError(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 40,
              color: TerraResinColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              'Unable to load dashboard data.\n$error',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                ref.invalidate(companyBankAccountsProvider);
                ref.invalidate(transactionsProvider);
                ref.invalidate(companyBankBalancesProvider);
                ref.invalidate(foundersProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _filterTransactions(
    List<Map<String, dynamic>> list,
  ) {
    if (_selectedDateFilter == 'All Dates') return list;
    final now = DateTime.now();
    return list.where((t) {
      final dateStr = t['transaction_date'] as String? ?? '';
      if (dateStr.isEmpty) return true;
      final date = DateTime.parse(dateStr);
      if (_selectedDateFilter == 'Today') {
        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
      }
      if (_selectedDateFilter == 'This Month') {
        return date.year == now.year && date.month == now.month;
      }
      return true;
    }).toList();
  }

  Widget _buildMetricCard(
    String title,
    double value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: TerraResinColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: TerraResinColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                formatIndianCurrency(value),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: TerraResinColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySummaryCard(Map<String, double> data) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: TerraResinColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Expense by Category',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: TerraResinColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            if (data.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No expense transactions.'),
                ),
              )
            else
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 12,
                      color: TerraResinColors.border,
                    ),
                    itemBuilder: (context, index) {
                      final entry = data.entries.elementAt(index);
                      return Row(
                        children: [
                          const Icon(
                            Icons.circle,
                            size: 10,
                            color: TerraResinColors.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              entry.key,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: TerraResinColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            formatIndianCurrency(entry.value),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: TerraResinColors.textPrimary,
                            ),
                          ),
                        ],
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

  Widget _buildBankBalancesSection(List<BankBalance> banks) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: TerraResinColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bank Balances',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: TerraResinColors.textPrimary,
              ),
            ),
            const Divider(height: 24, color: TerraResinColors.border),
            ...banks.map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        b.account['name'] as String? ?? 'Bank Account',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: TerraResinColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          formatIndianCurrency(b.balance),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: TerraResinColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFounderContributionsSection(Map<String, double> founderMap) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: TerraResinColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Founder Contributions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: TerraResinColors.textPrimary,
              ),
            ),
            const Divider(height: 24, color: TerraResinColors.border),
            ...founderMap.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        e.key,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: TerraResinColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          formatIndianCurrency(e.value),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactionsLedger(List<Map<String, dynamic>> list) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: TerraResinColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: TerraResinColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            if (list.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No recent ledger transactions posted.'),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length.clamp(0, 5),
                separatorBuilder: (context, i) =>
                    const Divider(color: TerraResinColors.border),
                itemBuilder: (context, i) {
                  final t = list[i];
                  final desc = t['description'] as String? ?? 'Transaction';
                  final amt = (t['amount'] as num?)?.toDouble() ?? 0.0;
                  final direction = t['direction'] as String? ?? 'debit';
                  final type = t['transaction_type'] as String? ?? 'Expense';
                  final dateStr = t['transaction_date'] as String? ?? '';
                  final date = dateStr.isNotEmpty
                      ? DateTime.parse(dateStr)
                      : DateTime.now();

                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              desc,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: TerraResinColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${date.day}/${date.month}/${date.year} • $type',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: TerraResinColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${direction == 'credit' ? '+' : '-'}${formatIndianCurrency(amt)}',
                            maxLines: 1,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: direction == 'credit'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16,
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
