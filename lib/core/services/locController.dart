import 'package:geolocator/geolocator.dart';
import 'package:quizbit_2/core/services/locRepo.dart';
import 'package:quizbit_2/core/services/supabase_service.dart';
import 'package:quizbit_2/core/session/ProfileSession.dart';
import 'package:quizbit_2/models/userLocModel.dart';

class LocationController {
    final LocationRepository _locationRepository;
  LocationController() : _locationRepository = LocationRepository(SupabaseService().client);




   Future<UserLocation?> getCurrentUserLocation() async{
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if(!serviceEnabled){
      throw Exception("Location Services are not enabled");
    }

    permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
    }

    if(permission == LocationPermission.deniedForever){
      throw Exception("Permission permanently deniner. Please enable it from the settings");
    }

    Position position = await Geolocator.getCurrentPosition();

    return UserLocation(latitude: position.latitude, longitude: position.longitude);
  }




  saveLocation() async{
    print("GOT IT TILL HERE");
    final user = ProfileSession.profile;
    print(" ProfileSession.profile");
    print(user);
    if(user == null) return;
    final location = await getCurrentUserLocation();
print("GOT USER LOCATION");
print(location);
    if(location == null) return;
    
    await _locationRepository.updateUserLocation(user_id: user.user_id, lat: location.latitude, lng: location.longitude);
  }
}
