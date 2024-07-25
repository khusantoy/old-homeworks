import 'dart:io';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class Restaurant {
  String id;
  String name;
  String phoneNumber;
  String location;
  LatLng latLng;
  File imageFile;

  Restaurant(
      {required this.id,
      required this.name,
      required this.phoneNumber,
      required this.location,
      required this.latLng,
      required this.imageFile});
}
