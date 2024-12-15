import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vector_math/vector_math.dart' as math;

class TrackPage extends StatefulWidget {
  const TrackPage({Key? key}) : super(key: key);

  @override
  State<TrackPage> createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  GoogleMapController? _mapController;
  Location _location = Location();
  Set<Polyline> _polylines = {};
  List<LatLng> _routeCoords = [];
  LatLng? _currentLocation;

  int _steps = 0;
  double _totalDistance = 0.0; // in kilometers
  double _caloriesBurned = 0.0;
  Stopwatch _stopwatch = Stopwatch();
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;
  double _lastY = 0.0;
  double _threshold = 10.0;

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

  Future<void> _initializeLocation() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    _location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _currentLocation = LatLng(
          currentLocation.latitude ?? 0.0,
          currentLocation.longitude ?? 0.0,
        );
        _routeCoords.add(_currentLocation!);

        if (_routeCoords.length > 1) {
          _totalDistance += _calculateDistance(
            _routeCoords[_routeCoords.length - 2],
            _routeCoords.last,
          );
        }

        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            visible: true,
            points: _routeCoords,
            color: Colors.purple,
            width: 4,
          ),
        );
      });
    });
  }

  void _startAccelerometerListener() {
    double previousMagnitude = 0.0;
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      final acceleration = math.Vector3(event.x,event.y,event.z);
      double magnitude = acceleration.length;//sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      if (magnitude > _threshold) {
        setState(() {
          _steps++;
        });
      }
      previousMagnitude = magnitude;
    });
  }


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

  double _calculateCalories() {
    return _steps * 0.04;
  }

  Future<void> _saveSession() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('user_info').doc(user.uid).collection('track_activity').add({
        'steps': _steps,
        'time': _stopwatch.elapsedMilliseconds,
        'calories': _caloriesBurned,
        'distance': _totalDistance,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Session Saved Successfully")),
    );

    Navigator.pop(context, _steps); // Return steps to HomePage
  }

  String _formatTime(int milliseconds) {
    int seconds = (milliseconds / 1000).floor();
    int minutes = (seconds / 60).floor();
    int hours = (minutes / 60).floor();

    return "${hours.toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    _caloriesBurned = _calculateCalories();

    return Scaffold(
      body: Stack(
        children: [
          // Google Map widget
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation ?? const LatLng(0.0, 0.0),
              zoom: 16,
            ),
            onMapCreated: (controller) => _mapController = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            polylines: _polylines,
          ),
          // Bottom panel with stats and button
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
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
              child: Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard("Steps", _steps.toString(),
                            Icons.directions_walk_outlined, Colors.blue),
                        _buildStatCard(
                          "Time",
                          _formatTime(_stopwatch.elapsedMilliseconds),
                          Icons.timer,
                          Colors.orange,
                        ),
                        _buildStatCard(
                          "Calories",
                          _caloriesBurned.toStringAsFixed(1),
                          Icons.local_fire_department,
                          Colors.red,
                        ),
                        _buildStatCard(
                          "Distance",
                          "${_totalDistance.toStringAsFixed(2)} km",
                          Icons.map,
                          Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Modified Button
                    Align(
                      alignment: Alignment.center, // Center the button
                      child: SizedBox(
                        width: 200, // Set a specific width for the button
                        child: ElevatedButton(
                          onPressed: _saveSession,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            backgroundColor: Colors.blue, // Single color for the button
                          ),
                          child: const Text(
                            "Stop and Save",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}