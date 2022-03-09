import 'package:amazon/util/current_location.dart';
import 'package:amazon/util/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({Key? key}) : super(key: key);

  @override
  _MapsScreenState createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  Set<Marker> _markers = {};
  Position? currentLocation;      //store the current location and user tapped location from map(latitude and longitude)
  TextEditingController mapTextController = TextEditingController();
  GoogleMapController? mapControllerView;
  void _onMapCreated(GoogleMapController controller) {
    mapControllerView = controller; //save the controller for animating and moving the camera and for other functionalities
    setMarkers(); 
  }

  @override
  Widget build(BuildContext context) {
    // get the current user location using the geolocation packageand save the location in the variable
    
    getCurrentLocationService().then(     
      (value) async {
        if (currentLocation == null) {
          currentLocation = value;
          setTextLocation();
          setMarkers();
        }
      },
    ).onError<ApiExceptionCustom>((error, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.black,
          content: Text(
            error.msg,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          )));
    });
    return Scaffold(
        appBar: AppBar(
          title: const Text("Delivery Location"),
        ),
        body: Column(
          children: [
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      controller: mapTextController,
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 2.0, color: Colors.orangeAccent)),
                          prefixIcon: Icon(Icons.location_city,
                              color: Colors.orangeAccent)),
                      enabled: false,
                      maxLines: null,
                      minLines: null,
                      expands: true,
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context, currentLocation);
                      },
                      icon: Icon(
                        Icons.save,
                        size: 35,
                      ))
                ],
              ),
            ),
            Expanded(
              flex: 8,
              child: GoogleMap(
                //use the ontap function to get the location of the tapped point from the map
                  onTap: (latLng) {
                    currentLocation = Position(
                        longitude: latLng.longitude,
                        latitude: latLng.latitude,
                        timestamp: DateTime.now(),
                        accuracy: 0.0,
                        altitude: 0.0,
                        heading: 0.0,
                        speed: 0.0,
                        speedAccuracy: 0.0);
                    setTextLocation();
                    setMarkers();
                  },
                  onMapCreated: _onMapCreated,
                  markers: _markers,
                  initialCameraPosition:
                      CameraPosition(target: getLatLng(), zoom: 14)),
            ),
          ],
        ));
  }

  LatLng getLatLng() => currentLocation != null
      ? LatLng(
          currentLocation?.latitude ?? 0.0, currentLocation?.longitude ?? 0.0)
      : const LatLng(10.850516, 76.271080);

  void setTextLocation() async {
    LatLng location = getLatLng();
    List<Placemark> placemarks =
        await placemarkFromCoordinates(location.latitude, location.longitude);
    mapTextController.text = placemarks != null && placemarks.length > 0
        ? '${placemarks[1].street ?? placemarks[0].street} ${placemarks[1].subLocality ?? placemarks[0].subLocality} ${placemarks[1].locality ?? placemarks[0].locality} ${placemarks[1].postalCode ?? placemarks[0].postalCode}'
        : 'unnamed';
  }

  void setMarkers() {
    //move the map when a user tap on the map giving the current location 
    mapControllerView
        ?.animateCamera(CameraUpdate.newLatLngZoom(getLatLng(), 14));
        //remove existing markers and add the new marker with the user tapped area
    _markers.clear();
    _markers.add(Marker(
      markerId: MarkerId('id-1'),
      position: getLatLng(),
      infoWindow: InfoWindow(title: '', snippet: ''),
    ));
    setState(() {});
  }
}
