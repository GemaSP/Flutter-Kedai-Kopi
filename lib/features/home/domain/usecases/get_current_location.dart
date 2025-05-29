import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class GetCurrentLocation {
  Future<String> execute() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      return '${placemarks.first.street}, ${placemarks.first.locality}, ${placemarks.first.subAdministrativeArea}';
    } catch (e) {
      throw Exception("Failed to get location: $e");
    }
  }
}
