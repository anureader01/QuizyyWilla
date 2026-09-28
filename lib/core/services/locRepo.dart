import 'package:supabase_flutter/supabase_flutter.dart';

class LocationRepository{
    final SupabaseClient _client;
  LocationRepository(this._client);


  updateUserLocation({
    required String user_id,
    required double lat,
    required double lng,
  }) async {
    print("USER ID");
    print(user_id);
    print("POINT($lng, $lat)");
    await _client.from("profile").update(({
      "location" : "POINT($lng $lat)"
    })).eq("user_id", user_id);
  }

}
