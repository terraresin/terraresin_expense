enum ReportType {
  allTransactions,
  bankDeposits,
  bankWithdrawals,
  companyExpenses,
  chequePayments,
  personalExpenses,
  founderOutstanding,
  bankStatement,
}

class ReportFilter {
  const ReportFilter({
    this.fromDate,
    this.toDate,
    this.reportType = ReportType.allTransactions,
    this.accountId,
    this.categoryId,
    this.projectId,
  });

  final DateTime? fromDate;
  final DateTime? toDate;
  final ReportType reportType;

  /// Optional bank or personal account filter.
  final String? accountId;

  /// Optional expense category filter.
  final String? categoryId;

  /// Optional project filter.
  final String? projectId;

  bool get isAllDates => fromDate == null && toDate == null;

  ReportFilter copyWith({
    DateTime? fromDate,
    DateTime? toDate,
    ReportType? reportType,
    String? accountId,
    String? categoryId,
    String? projectId,
  }) {
    return ReportFilter(
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      reportType: reportType ?? this.reportType,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      projectId: projectId ?? this.projectId,
    );
  }
}
