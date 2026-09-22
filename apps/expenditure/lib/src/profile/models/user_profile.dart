class UserProfile {
  const UserProfile({
    required this.id,
    this.firstName,
    this.lastName,
    this.displayName,
    this.phone,
    this.avatarUrl,
    this.locale,
    this.timezone,
    this.dateFormat,
    this.numberFormat,
    this.isActive = true,
  });

  final String id;
  final String? firstName;
  final String? lastName;
  final String? displayName;
  final String? phone;
  final String? avatarUrl;
  final String? locale;
  final String? timezone;
  final String? dateFormat;
  final String? numberFormat;
  final bool isActive;

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      firstName: map['first_name'] as String?,
      lastName: map['last_name'] as String?,
      displayName: map['display_name'] as String?,
      phone: map['phone'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      locale: map['locale'] as String?,
      timezone: map['timezone'] as String?,
      dateFormat: map['date_format'] as String?,
      numberFormat: map['number_format'] as String?,
      isActive: map['is_active'] as bool? ?? true,
    );
  }
}
