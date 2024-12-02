import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:sensors_plus/sensors_plus.dart';

class TrackPage extends StatefulWidget {
  @override
  _TrackPageState createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  // Map and location-related variables
  GoogleMapController? _mapController;
  Location _location = Location();
  Set<Polyline> _polylines = {};
  List<LatLng> _routeCoords = [];
  LatLng? _currentLocation;

  // Tracking variables
  int _steps = 0;
  double _totalDistance = 0.0; // in km
  double _caloriesBurned = 0.0;
  Stopwatch _stopwatch = Stopwatch();
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;
  double _lastY = 0.0;
  double _threshold = 15.0;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _startAccelerometerListener();
    _stopwatch.start();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _accelerometerSubscription.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  // Initialize location tracking
  Future<void> _initializeLocation() async {
    bool _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) return;
    }

    PermissionStatus _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) return;
    }

    _location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _currentLocation = LatLng(
            currentLocation.latitude ?? 0.0, currentLocation.longitude ?? 0.0);
        _routeCoords.add(_currentLocation!);

        if (_routeCoords.length > 1) {
          // Calculate distance between the last two points
          _totalDistance += _calculateDistance(
              _routeCoords[_routeCoords.length - 2], _routeCoords.last);
        }

        // Update polyline on the map
        _polylines.add(
          Polyline(
            polylineId: PolylineId('route'),
            visible: true,
            points: _routeCoords,
            color: Colors.purple,
            width: 4,
          ),
        );
      });
    });
  }

  // Start listening to accelerometer data for step counting
  void _startAccelerometerListener() {
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      if (event.y - _lastY > _threshold) {
        setState(() {
          _steps++;
        });
      }
      _lastY = event.y;
    });
  }

  // Calculate distance between two coordinates in kilometers
  double _calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371; // Earth radius in kilometers
    double dLat = _degToRad(end.latitude - start.latitude);
    double dLon = _degToRad(end.longitude - start.longitude);

    double a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_degToRad(start.latitude)) *
            cos(_degToRad(end.latitude)) *
            (sin(dLon / 2) * sin(dLon / 2));

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degToRad(double degree) {
    return degree * (pi / 180);
  }

  // Calculate calories burned based on distance and steps
  double _calculateCalories() {
    return _steps * 0.04; // Approximation: 0.04 kcal per step
  }

  // Format time for display
  String _formatTime(int milliseconds) {
    int seconds = (milliseconds / 1000).floor();
    int minutes = (seconds / 60).floor();
    int hours = (minutes / 60).floor();

    String formattedTime =
        "${hours.toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}";
    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    _caloriesBurned = _calculateCalories();

    return Scaffold(
      // Gradient AppBar
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [Colors.green, Colors.teal, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              "Track",
              style: TextStyle(color: Colors.white, fontSize: 30),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation ?? LatLng(0.0, 0.0),
              zoom: 16,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            polylines: _polylines,
          ),

          // Bottom stats panel
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard("Steps", _steps.toString(), Icons.directions_walk, Colors.blue),
                      _buildStatCard("Time", _formatTime(_stopwatch.elapsedMilliseconds), Icons.timer, Colors.orange),
                      _buildStatCard("Calories", _caloriesBurned.toStringAsFixed(1), Icons.local_fire_department, Colors.red),
                      _buildStatCard("Distance", "${_totalDistance.toStringAsFixed(2)} km", Icons.map, Colors.green),
                    ],
                  ),
                  SizedBox(height: 10),

                  // Gradient Stop Button
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _stopwatch.stop();
                        });

                        // Stop Tracking Logic
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                      ).copyWith(
                        backgroundColor: MaterialStateProperty.resolveWith(
                              (states) => null,
                        ),
                        foregroundColor: MaterialStateProperty.all(Colors.white),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green, Colors.teal, Colors.lightBlueAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            "Stop",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build stat cards
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Text(
          title,
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}
