import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController _mapController;
  Location _location = Location();
  late LocationData _currentLocation;
  Set<Marker> _markers = {};
  List<LatLng> _polylineCoordinates = [];

  @override
  void initState() {
    super.initState();
    _initCurrentLocation();
    _startLocationUpdates();
  }


  Future<void> _initCurrentLocation() async {
    try {
      _currentLocation = await _location.getLocation();
      _updateMarker(_currentLocation);
    } catch (e) {
      print("Error getting location: $e");
    }
  }


  void _startLocationUpdates() {
    const tenSeconds = const Duration(seconds: 10);
    Timer.periodic(tenSeconds, (Timer t) async {
      try {
        _currentLocation = await _location.getLocation();
        setState(() {
          _updateMarker(_currentLocation);
          _updatePolyline(_currentLocation);
        });
      } catch (e) {
        print("Error getting location: $e");
      }
    });
  }

  void _updateMarker(LocationData locationData) {
    LatLng latLng = LatLng(locationData.latitude!, locationData.longitude!);
    _markers.clear();
    _markers.add(Marker(
      markerId: MarkerId("myLocation"),
      position: latLng,
      infoWindow: InfoWindow(
        title: "My current location",
        snippet:
        "${locationData.latitude}, ${locationData.longitude}",
      ),
    ));
    _moveCamera(latLng);
  }


  void _updatePolyline(LocationData locationData) {
    _polylineCoordinates.add(LatLng(
      locationData.latitude!,
      locationData.longitude!,
    ));
  }


  void _moveCamera(LatLng latLng) {
    _mapController.animateCamera(CameraUpdate.newLatLng(latLng));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Real Time Locaiton Tracker"),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: LatLng(0, 0),
          zoom: 15,
        ),
        markers: _markers,
        polylines: {
          Polyline(
            polylineId: PolylineId("route"),
            points: _polylineCoordinates,
            color: Colors.blue,
            width: 5,
          ),
        },
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          _mapController = controller;
        },
      ),
    );
  }
}
