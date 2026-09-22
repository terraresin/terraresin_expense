class TransactionCategory {
  const TransactionCategory({
    required this.id,
    required this.name,
    this.description,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String? description;
  final bool isActive;
}
