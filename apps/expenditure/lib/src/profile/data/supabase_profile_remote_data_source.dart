import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';
import 'profile_remote_data_source.dart';

class SupabaseProfileRemoteDataSource implements ProfileRemoteDataSource {
  SupabaseProfileRemoteDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<UserProfile?> getProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return UserProfile.fromMap(response);
  }

  @override
  Future<UserProfile> updateProfile(UserProfile profile) async {
    final response = await _client
        .from('profiles')
        .update({
          'first_name': profile.firstName,
          'last_name': profile.lastName,
          'display_name': profile.displayName,
          'phone': profile.phone,
          'avatar_url': profile.avatarUrl,
          'locale': profile.locale,
          'timezone': profile.timezone,
          'date_format': profile.dateFormat,
          'number_format': profile.numberFormat,
          'is_active': profile.isActive,
        })
        .eq('id', profile.id)
        .select()
        .single();

    return UserProfile.fromMap(response);
  }
}
