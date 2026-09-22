import 'package:supabase_flutter/supabase_flutter.dart';

abstract final class TerraRezynSupabaseClient {
  static SupabaseClient get instance => Supabase.instance.client;
}
