import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:public_file_saver/public_file_saver.dart';
import 'package:terraresin_design_system/design_system.dart';

import '../../formatters/currency_formatter.dart';
import '../../providers/categories/category_providers.dart';
import '../../providers/transactions/transaction_providers.dart';

enum ReportKind {
  expenditure('Expenditure Report', Icons.receipt_long_outlined),
  categoryExpense('Category-wise Expense Report', Icons.category_outlined),
  founderContribution('Founder Contribution Report', Icons.people_outline),
  salaries('Salaries & Wages Report', Icons.badge_outlined),
  transactions('Transaction Report', Icons.swap_horiz_outlined);

  const ReportKind(this.title, this.icon);
  final String title;
  final IconData icon;
}

class FinanceReportsScreen extends ConsumerStatefulWidget {
  const FinanceReportsScreen({super.key, this.initialReport});

  final ReportKind? initialReport;

  @override
  ConsumerState<FinanceReportsScreen> createState() =>
      _FinanceReportsScreenState();
}

class _FinanceReportsScreenState extends ConsumerState<FinanceReportsScreen> {
  late ReportKind _report;
  bool _fullPeriod = true;
  DateTime _fromDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _toDate = DateTime.now();
  final Set<String> _selectedCategoryIds = {};
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _report = widget.initialReport ?? ReportKind.expenditure;
  }

  @override
  void didUpdateWidget(covariant FinanceReportsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialReport != null &&
        widget.initialReport != oldWidget.initialReport) {
      _report = widget.initialReport!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: TerraResinColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          final content = transactions.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _errorState(
              'Unable to load report data: $error',
              () => ref.invalidate(transactionsProvider),
            ),
            data: (items) => categories.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _errorState(
                'Unable to load categories: $error',
                () => ref.invalidate(categoriesProvider),
              ),
              data: (categoryItems) =>
                  _reportContent(items, categoryItems, wide),
            ),
          );

          if (!wide) {
            return Column(
              children: [
                _mobileReportMenu(),
                Expanded(child: content),
              ],
            );
          }
          return content;
        },
      ),
    );
  }

  Widget _mobileReportMenu() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: DropdownButtonFormField<ReportKind>(
        initialValue: _report,
        decoration: const InputDecoration(labelText: 'Report'),
        items: ReportKind.values
            .map(
              (report) =>
                  DropdownMenuItem(value: report, child: Text(report.title)),
            )
            .toList(),
        onChanged: (report) {
          if (report != null) setState(() => _report = report);
        },
      ),
    );
  }

  Widget _reportContent(
    List<Map<String, dynamic>> transactions,
    List<Map<String, dynamic>> categories,
    bool wide,
  ) {
    final expenseCategories = categories
        .where((category) => category['category_type'] == 'Expense')
        .toList();
    final rows = _rowsForReport(transactions);
    final total = rows.fold<double>(
      0,
      (sum, row) => sum + ((row['amount'] as num?)?.toDouble() ?? 0),
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(wide ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: wide ? 520 : double.infinity,
                child: Text(
                  _report.title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: TerraResinColors.textPrimary,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: rows.isEmpty || _isDownloading
                    ? null
                    : () => _downloadPdf(rows, total),
                icon: _isDownloading
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.picture_as_pdf_outlined),
                label: Text(_isDownloading ? 'Saving...' : 'Download PDF'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _periodFilters(),
          if (_report == ReportKind.categoryExpense) ...[
            const SizedBox(height: 16),
            _categoryFilters(expenseCategories),
          ],
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _summaryCard('Transactions', '${rows.length}'),
              _summaryCard('Total Amount', formatIndianCurrency(total)),
            ],
          ),
          const SizedBox(height: 20),
          _reportGrid(rows),
        ],
      ),
    );
  }

  Widget _periodFilters() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Full Period')),
                ButtonSegment(value: false, label: Text('Date Range')),
              ],
              selected: {_fullPeriod},
              onSelectionChanged: (value) {
                setState(() => _fullPeriod = value.first);
              },
            ),
            if (!_fullPeriod) ...[
              _dateButton('From Date', _fromDate, true),
              _dateButton('To Date', _toDate, false),
            ],
          ],
        ),
      ),
    );
  }

  Widget _dateButton(String label, DateTime date, bool from) {
    return OutlinedButton.icon(
      onPressed: () => _pickDate(from),
      icon: const Icon(Icons.calendar_today_outlined, size: 18),
      label: Text('$label: ${_formatDate(date)}'),
    );
  }

  Widget _categoryFilters(List<Map<String, dynamic>> categories) {
    final selected = categories
        .where((category) => _selectedCategoryIds.contains(category['id']))
        .toList();
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: (MediaQuery.sizeOf(context).width - 64)
                      .clamp(0, 360)
                      .toDouble(),
                  child: Autocomplete<Map<String, dynamic>>(
                    displayStringForOption: (category) =>
                        category['name'] as String? ?? '',
                    optionsBuilder: (value) {
                      final query = value.text.trim().toLowerCase();
                      if (query.length < 2) return const Iterable.empty();
                      return categories.where((category) {
                        final name = category['name'] as String? ?? '';
                        return name.toLowerCase().contains(query) &&
                            !_selectedCategoryIds.contains(category['id']);
                      });
                    },
                    onSelected: (category) => setState(
                      () => _selectedCategoryIds.add(category['id'] as String),
                    ),
                    fieldViewBuilder:
                        (context, controller, focusNode, onSubmitted) {
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: 'Search Expense Categories',
                              hintText: 'Type at least 2 characters',
                              prefixIcon: Icon(Icons.search),
                            ),
                          );
                        },
                  ),
                ),
                OutlinedButton(
                  onPressed: () => setState(() {
                    _selectedCategoryIds
                      ..clear()
                      ..addAll(categories.map((item) => item['id'] as String));
                  }),
                  child: const Text('Select All'),
                ),
                TextButton(
                  onPressed: () => setState(_selectedCategoryIds.clear),
                  child: const Text('Clear All'),
                ),
                Text(
                  _selectedCategoryIds.isEmpty
                      ? 'All Categories'
                      : '${_selectedCategoryIds.length} selected',
                  style: const TextStyle(color: TerraResinColors.textSecondary),
                ),
              ],
            ),
            if (selected.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selected
                    .map(
                      (category) => InputChip(
                        label: Text(category['name'] as String? ?? ''),
                        onDeleted: () => setState(
                          () => _selectedCategoryIds.remove(category['id']),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String label, String value) {
    return SizedBox(
      width: 220,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: TerraResinColors.textSecondary),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reportGrid(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) {
      return const Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('No records match these filters.')),
        ),
      );
    }
    return Card(
      margin: EdgeInsets.zero,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Founder')),
            DataColumn(label: Text('Account')),
            DataColumn(label: Text('Debit / Credit')),
            DataColumn(label: Text('Amount'), numeric: true),
            DataColumn(label: Text('Description')),
          ],
          rows: rows.map((row) {
            return DataRow(
              cells: [
                DataCell(Text(_formatDate(_date(row)))),
                DataCell(Text(_relationName(row['categories']))),
                DataCell(Text(_relationName(row['founders']))),
                DataCell(Text(_relationName(row['accounts']))),
                DataCell(
                  Text(row['direction'] == 'credit' ? 'Credit' : 'Debit'),
                ),
                DataCell(
                  Text(formatIndianCurrency((row['amount'] as num?) ?? 0)),
                ),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: Text(row['description'] as String? ?? ''),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _rowsForReport(
    List<Map<String, dynamic>> transactions,
  ) {
    final rows = transactions.where(_withinPeriod).where((transaction) {
      final category = transaction['categories'];
      final categoryName = _relationName(category);
      final categoryType = category is Map
          ? category['category_type'] as String? ?? ''
          : '';
      return switch (_report) {
        ReportKind.expenditure =>
          transaction['direction'] == 'debit' && categoryType == 'Expense',
        ReportKind.categoryExpense =>
          transaction['direction'] == 'debit' &&
              categoryType == 'Expense' &&
              (_selectedCategoryIds.isEmpty ||
                  _selectedCategoryIds.contains(transaction['category_id'])),
        ReportKind.founderContribution =>
          transaction['transaction_type'] == 'founder_contribution' &&
              transaction['founder_id'] != null,
        ReportKind.salaries => categoryName == 'Salaries & Wages',
        ReportKind.transactions => true,
      };
    }).toList();
    rows.sort((left, right) => _date(right).compareTo(_date(left)));
    return rows;
  }

  bool _withinPeriod(Map<String, dynamic> transaction) {
    if (_fullPeriod) return true;
    final date = _date(transaction);
    final day = DateTime(date.year, date.month, date.day);
    return !day.isBefore(_fromDate) && !day.isAfter(_toDate);
  }

  Future<void> _pickDate(bool from) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: from ? _fromDate : _toDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected == null || !mounted) return;
    setState(() {
      if (from) {
        _fromDate = selected;
        if (_fromDate.isAfter(_toDate)) _toDate = selected;
      } else {
        _toDate = selected;
        if (_toDate.isBefore(_fromDate)) _fromDate = selected;
      }
    });
  }

  Future<void> _downloadPdf(
    List<Map<String, dynamic>> rows,
    double total,
  ) async {
    setState(() => _isDownloading = true);
    try {
      final document = pw.Document();
      document.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(24),
          build: (context) => [
            pw.Text(
              'TerraResin - ${_report.title}',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              _fullPeriod
                  ? 'Period: Full Period'
                  : 'Period: ${_formatDate(_fromDate)} to ${_formatDate(_toDate)}',
            ),
            pw.Text('Records: ${rows.length}'),
            pw.Text('Total Amount: ${_pdfMoney(total)}'),
            pw.SizedBox(height: 14),
            pw.TableHelper.fromTextArray(
              headers: const [
                'Date',
                'Category',
                'Founder',
                'Account',
                'Debit/Credit',
                'Amount',
                'Description',
              ],
              data: rows
                  .map(
                    (row) => [
                      _formatDate(_date(row)),
                      _relationName(row['categories']),
                      _relationName(row['founders']),
                      _relationName(row['accounts']),
                      row['direction'] == 'credit' ? 'Credit' : 'Debit',
                      _pdfMoney((row['amount'] as num?)?.toDouble() ?? 0),
                      row['description'] as String? ?? '',
                    ],
                  )
                  .toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              cellStyle: const pw.TextStyle(fontSize: 8),
            ),
          ],
        ),
      );

      final fileName =
          '${_report.name}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
      final saved = await PublicFileSaver().saveBytes(
        bytes: await document.save(),
        fileName: fileName,
        mimeType: 'application/pdf',
        subDir: 'TerraResin Reports',
      );
      if (mounted) {
        final message = saved?.isSuccess == true
            ? 'PDF saved to Downloads: ${saved?.fileName ?? fileName}'
            : 'PDF could not be saved.';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save PDF: $error')));
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Widget _errorState(String message, VoidCallback retry) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: retry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  DateTime _date(Map<String, dynamic> transaction) =>
      DateTime.tryParse(transaction['transaction_date'] as String? ?? '') ??
      DateTime.fromMillisecondsSinceEpoch(0);

  String _relationName(dynamic relation) {
    if (relation is Map) return relation['name'] as String? ?? '';
    return '';
  }

  String _formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

  String _pdfMoney(double amount) =>
      'INR ${NumberFormat.currency(locale: 'en_IN', symbol: '').format(amount)}';
}
