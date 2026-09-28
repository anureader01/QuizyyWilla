import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client  = Supabase.instance.client;

 SupabaseClient get client => _client;
}

