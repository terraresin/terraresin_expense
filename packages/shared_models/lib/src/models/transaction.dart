enum TransactionType {
  bankDeposit,
  bankWithdrawal,
  companyExpense,
  chequePayment,
  personalExpense,
  founderContribution,
  reimbursement,
}

enum PaymentMethod { bankTransfer, cash, cheque, upi, other }

class Transaction {
  const Transaction({
    required this.id,
    required this.transactionDate,
    required this.type,
    required this.amount,
    required this.description,
    this.accountId,
    this.category,
    this.paymentMethod,
    this.chequeNumber,
    this.chequeDate,
    this.referenceNumber,
    this.createdBy,
    this.notes,
    this.direction,
    this.partyName,
    this.accountName,
  });

  final String id;
  final DateTime transactionDate;
  final TransactionType type;
  final double amount;
  final String description;
  final String? accountId;
  final String? category;
  final PaymentMethod? paymentMethod;
  final String? chequeNumber;
  final DateTime? chequeDate;
  final String? referenceNumber;
  final String? createdBy;
  final String? notes;

  // Database schema specific extensions
  final String? direction;
  final String? partyName;
  final String? accountName;

  bool get isCheque =>
      type == TransactionType.chequePayment ||
      paymentMethod == PaymentMethod.cheque;

  bool get affectsBankBalance {
    return type == TransactionType.bankDeposit ||
        type == TransactionType.bankWithdrawal ||
        type == TransactionType.companyExpense ||
        type == TransactionType.chequePayment ||
        type == TransactionType.reimbursement ||
        type == TransactionType.founderContribution;
  }

  bool get isCompanyExpense {
    return type == TransactionType.companyExpense ||
        type == TransactionType.chequePayment;
  }

  bool get isPersonalExpense => type == TransactionType.personalExpense;

  bool get isFounderContribution => type == TransactionType.founderContribution;

  bool get isReimbursement => type == TransactionType.reimbursement;

  factory Transaction.fromMap(Map<String, dynamic> map) {
    final typeStr = map['transaction_type'] as String?;
    TransactionType tType = TransactionType.companyExpense;
    if (typeStr != null) {
      for (final val in TransactionType.values) {
        if (val.name == typeStr) {
          tType = val;
          break;
        }
      }
    }

    final pMethodStr = map['payment_method'] as String?;
    PaymentMethod? pMethod;
    if (pMethodStr != null) {
      for (final val in PaymentMethod.values) {
        if (val.name == pMethodStr) {
          pMethod = val;
          break;
        }
      }
    }

    String? accName;
    String? accId;
    if (map['accounts'] is Map) {
      accName = map['accounts']['name'] as String?;
      accId = map['accounts']['id'] as String?;
    }

    return Transaction(
      id: map['id'] as String? ?? '',
      transactionDate: map['transaction_date'] != null
          ? DateTime.parse(map['transaction_date'] as String)
          : DateTime.now(),
      type: tType,
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      description: map['description'] as String? ?? '',
      accountId: accId ?? map['account_id'] as String?,
      category: map['category'] as String?,
      paymentMethod: pMethod,
      chequeNumber: map['cheque_number'] as String?,
      chequeDate: map['cheque_date'] != null
          ? DateTime.parse(map['cheque_date'] as String)
          : null,
      referenceNumber: map['reference_number'] as String?,
      createdBy: map['created_by'] as String?,
      notes: map['notes'] as String?,
      direction: map['direction'] as String?,
      partyName: map['party_name'] as String?,
      accountName: accName,
    );
  }
}
