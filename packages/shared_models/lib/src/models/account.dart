enum AccountType { bank, personal }

enum AccountOwner { company, chaitanya, srikanth, krishnaChaitanya }

class Account {
  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.owner,
    this.bankName,
    this.accountNumber,
    this.isActive = true,
  });

  final String id;
  final String name;
  final AccountType type;
  final AccountOwner owner;

  /// Used only for bank accounts.
  final String? bankName;

  /// Optional account number.
  ///
  /// For security, the application should normally display only
  /// the last few digits.
  final String? accountNumber;

  final bool isActive;

  bool get isBank => type == AccountType.bank;

  bool get isPersonal => type == AccountType.personal;

  bool get isCompanyAccount => owner == AccountOwner.company;
}
