import 'package:intl/intl.dart';

final NumberFormat _indianCurrency = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 2,
);

final NumberFormat _indianNumber = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '',
  decimalDigits: 2,
);

String formatIndianCurrency(num amount) => _indianCurrency.format(amount);

String formatIndianNumber(num amount) => _indianNumber.format(amount).trim();
