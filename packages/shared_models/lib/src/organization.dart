class Organization {
  const Organization({
    required this.id,
    required this.name,
    this.legalName,
    this.organizationType = 'company',
    this.countryCode = 'IN',
    this.currencyCode = 'INR',
    this.timezone = 'Asia/Kolkata',
    this.locale = 'en-IN',
    this.dateFormat = 'dd/MM/yyyy',
    this.numberFormat = 'en-IN',
    this.isActive = true,
  });

  final String id;
  final String name;
  final String? legalName;
  final String organizationType;
  final String countryCode;
  final String currencyCode;
  final String timezone;
  final String locale;
  final String dateFormat;
  final String numberFormat;
  final bool isActive;

  factory Organization.fromMap(Map<String, dynamic> map) {
    return Organization(
      id: map['id'] as String,
      name: map['name'] as String,
      legalName: map['legal_name'] as String?,
      organizationType: map['organization_type'] as String? ?? 'company',
      countryCode: map['country_code'] as String? ?? 'IN',
      currencyCode: map['currency_code'] as String? ?? 'INR',
      timezone: map['timezone'] as String? ?? 'Asia/Kolkata',
      locale: map['locale'] as String? ?? 'en-IN',
      dateFormat: map['date_format'] as String? ?? 'dd/MM/yyyy',
      numberFormat: map['number_format'] as String? ?? 'en-IN',
      isActive: map['is_active'] as bool? ?? true,
    );
  }
}
