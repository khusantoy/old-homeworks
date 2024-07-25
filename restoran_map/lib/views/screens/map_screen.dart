import 'package:dars_12/controllers/restaurants_cubit.dart';
import 'package:dars_12/services/google_search_service.dart';
import 'package:dars_12/services/location_services.dart';
import 'package:dars_12/states/cubit_states.dart';
import 'package:dars_12/views/widgets/add_restaurant_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import 'package:location/location.dart';
import 'package:dars_12/models/restaurant.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController myController;
  final textController = TextEditingController();
  final LocationServices locationServices = LocationServices();
  final locationController = Location();
  Map<PolylineId, Polyline> polylines = {};

  String? locationName;

  List<LatLng> points = [];

  double? lat;
  double? lng;
  LatLng curPlace = const LatLng(41.2856806, 69.2034646);
  MapType mapType = MapType.normal;
  Set<Marker> markers = {};
  LatLng? latLng;
  List<Restaurant> restaurants = [];
  Restaurant? restaurant;
  bool markerTapCheck = false;
  bool mapTapCheck = false;

  void onMapCreated(GoogleMapController controller) {
    myController = controller;
  }

  Future<void> fetchLocation() async {
    locationController.onLocationChanged.listen((currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          curPlace =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
        });
      }
    });
  }

  Future<List<LatLng>> getPolylinePoints() async {
    final polylinePoints = PolylinePoints();

    final result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: 'AIzaSyDxcIfLomcjjZW7DEVOUpmzSCX1x1cgj9I',
        request: PolylineRequest(
            origin: PointLatLng(curPlace.latitude, curPlace.longitude),
            destination: PointLatLng(lat!, lng!),
            mode: TravelMode.walking));

    if (result.points.isNotEmpty) {
      return result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
    } else {
      return [];
    }
  }

  Future<void> generatePolyline(List<LatLng> pooints) async {
    const id = PolylineId("polyline");

    final polyline = Polyline(
        polylineId: id, color: Colors.blueAccent, points: pooints, width: 5);
    setState(() {
      polylines[id] = polyline;
    });
  }

  Future<void> initializeMap() async {
    await fetchLocation();
    final points = await getPolylinePoints();
    generatePolyline(points);
  }

  @override
  void initState() {
    super.initState();

    final restaurantsCubit = BlocProvider.of<RestaurantsCubit>(context);
    restaurantsCubit.stream.listen((state) {
      if (state is LoadedState) {
        setState(() {
          restaurants = state.restaurants;
        });
      }
    });

    // Load the initial data if necessary
    if (restaurantsCubit.state is LoadedState) {
      restaurants = (restaurantsCubit.state as LoadedState).restaurants;
    } else {}
    for (var i = 0; i < restaurants.length; i++) {
      markers.add(Marker(
        markerId: MarkerId(restaurants[i].id),
        position: restaurants[i].latLng,
        icon: BitmapDescriptor.defaultMarker,
        onTap: () {
          lat = restaurants[i].latLng.latitude;
          lng = restaurants[i].latLng.longitude;
          restaurant = restaurants[i];
          markerTapCheck = true;
          setState(() {});
        },
      ));
    }
    init();
  }

  void init() async {
    curPlace = await locationServices.getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onTap: (LatLng location) async {
              GeocodingService geocodingService = GeocodingService(
                  apiKey: "cc8ca831-bc74-4ae4-ad76-186813085a45");
              String? locationNameLocal =
                  await geocodingService.getAddressFromCoordinates(
                      location.latitude, location.longitude);
              setState(() {
                markerTapCheck = false;
                mapTapCheck = true;
                latLng = LatLng(location.latitude, location.longitude);
                locationName = locationNameLocal;
                markers.clear();
                markers.add(
                  Marker(
                    markerId: const MarkerId("restaurant"),
                    position: LatLng(location.latitude, location.longitude),
                    icon: BitmapDescriptor.defaultMarker,
                  ),
                );
              });
            },
            polylines: Set<Polyline>.of(polylines.values),
            markers: markers,
            mapType: mapType,
            initialCameraPosition: CameraPosition(target: curPlace, zoom: 10),
            onMapCreated: onMapCreated,
          ),
          Positioned(
            top: 120,
            right: 20,
            child: DropdownButton(
              icon: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.amber,
                  ),
                  child: const Icon(
                    Icons.map,
                    color: Colors.white,
                  )),
              items: [
                DropdownMenuItem(
                  value: MapType.normal,
                  child:
                      TextButton(onPressed: () {}, child: const Text("Normal")),
                ),
                DropdownMenuItem(
                  value: MapType.satellite,
                  child: TextButton(
                      onPressed: () {}, child: const Text("Sputnik")),
                ),
                DropdownMenuItem(
                  value: MapType.terrain,
                  child: TextButton(
                      onPressed: () {}, child: const Text("Terrain")),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  mapType = value!;
                });
              },
            ),
          ),
          Positioned(
            top: 40,
            child: Container(
              color: Colors.grey.shade200,
              margin: const EdgeInsets.all(20),
              height: 50,
              width: 370,
              child: GooglePlacesAutoCompleteTextFormField(
                  itmClick: (prediction) async {
                    textController.text = prediction.description!;
                    curPlace = await locationServices.getCurrentLocation();
                    setState(() {});

                    // textController.selection = TextSelection.fromPosition(TextPosition(offset: prediction.description!.length));
                  },
                  isLatLngRequired: true,
                  getPlaceDetailWithLatLng: (postalCodeResponse) {
                    setState(() {
                      lat = double.parse(postalCodeResponse.lat!);
                      lng = double.parse(postalCodeResponse.lng!);
                    });
                  },
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            textController.clear();
                            lat = null;
                            lng = null;
                          });
                        },
                        icon: const Icon(
                          Icons.clear,
                        ),
                      ),
                      border: const OutlineInputBorder(),
                      hintText: "Search"),
                  textEditingController: textController,
                  googleAPIKey: 'AIzaSyDxcIfLomcjjZW7DEVOUpmzSCX1x1cgj9I'),
            ),
          ),
          if (mapTapCheck)
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 150,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AddRestaurantDialog(
                          locationName: locationName!,
                          latLng: latLng!,
                        );
                      },
                    );
                  },
                  child: const Text(
                    "Add Location",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          if (markerTapCheck == true)
            Positioned(
                bottom: 70,
                left: 30,
                child: Container(
                  width: 350,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white),
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 150,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20)),
                        clipBehavior: Clip.hardEdge,
                        child: Image.file(
                          restaurant!.imageFile,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              restaurant!.name,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              restaurant!.phoneNumber,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              restaurant!.location,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ))
        ],
      ),
      floatingActionButton: lat != null
          ? FloatingActionButton(
              backgroundColor: Colors.amber,
              onPressed: () {
                if (lat != null && lng != null) {
                  initializeMap();
                }
              },
              child: const Icon(
                Icons.navigation_rounded,
                color: Colors.white,
              ),
            )
          : null,
    );
  }
}
