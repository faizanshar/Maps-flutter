import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
// import 'package:location/location.dart';

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  return await Geolocator.getCurrentPosition();
}

class Maps extends StatefulWidget {
  const Maps({Key? key}) : super(key: key);

  @override
  _MapsState createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  Completer<GoogleMapController> _controller = Completer();
  static const LatLng _latLng = const LatLng(-6.216417, 106.840148);
  MapType _mapType = MapType.normal;
  LatLng _lastMapPosition = _latLng;
  late String searchAdd;
  late LatLng currentPosition;
  // Location _location = Location();

  void getUserLocation() async {
    print('memulai Get User');
    var position = await GeolocatorPlatform.instance
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print("Latitude ${position.latitude}");
    print("Longitude ${position.longitude}");
    // setState(() {
      currentPosition = LatLng(position.latitude,position.longitude);
    // });
  }

  static final CameraPosition _position1 = CameraPosition(
      // bearing: 202.833,
      target: LatLng(-6.445179, 106.754945),
      zoom: 20.0);
  

  Future<void> _goToPosition() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_position1));
  }

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  _onMapType() {
    setState(() {
      _mapType =
          _mapType == MapType.normal ? MapType.satellite : MapType.normal;
    });
  }

  searchNavigate() async {
    final GoogleMapController controller = await _controller.future;

    locationFromAddress(searchAdd).then((value) {
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(value[0].latitude, value[0].longitude), zoom: 15.0)));
    });
  }

  void initState(){
    super.initState();
    _determinePosition();
    getUserLocation();
  }

  Widget buttonMap() {
    return FloatingActionButton(
      onPressed: _onMapType,
      backgroundColor: Colors.blue,
      child: Icon(
        Icons.map,
        size: 36.0,
      ),
    );
  }

  Widget buttonMapSearch() {
    return FloatingActionButton(
      onPressed: _goToPosition,
      backgroundColor: Colors.blue,
      child: Icon(
        Icons.location_searching,
        size: 36.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Maps"),
          backgroundColor: Colors.blue,
        ),
        body: Stack(
          children: <Widget>[
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition:
                // currentPosition != null ? 
                //   CameraPosition(target: currentPosition, zoom: 20.0) : 
                  CameraPosition(target: _latLng, zoom: 20.0),
              mapType: _mapType,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              onCameraMove: _onCameraMove,
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.topCenter,
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 50.0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.white,
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                            hintText: 'Enter Address',
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.only(left: 15.0, top: 15.0),
                            suffixIcon: IconButton(
                              onPressed: searchNavigate,
                              icon: Icon(Icons.search),
                              iconSize: 30.0,
                            )),
                        onChanged: (val) {
                          setState(() {
                            searchAdd = val;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Column(
                          children: [
                            buttonMap(),
                            SizedBox(
                              height: 15,
                            ),
                            buttonMapSearch()
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
