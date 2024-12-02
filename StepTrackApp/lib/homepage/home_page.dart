import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health/health.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart'; // Import the sensors package for accelerometer

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Variables for accelerometer data
  double _accelerometerX = 0.0;
  double _accelerometerY = 0.0;
  double _accelerometerZ = 0.0;

  String username = "User"; // Default username
  bool isLoading = true;

  // Variables for step counting
  int _steps = 0;
  double _lastY = 0.0;
  double _threshold = 15.0; // Sensitivity threshold for detecting steps
  int _stepTarget = 10000; // Default target (10,000 steps)

  @override
  void initState() {
    super.initState();
    fetchUsername(); // Fetch username when MainPage loads

    // Listen to accelerometer events for detecting steps
    accelerometerEvents.listen((AccelerometerEvent event) {
      _processAccelerometerData(event);
      setState(() {
        _accelerometerX = event.x;
        _accelerometerY = event.y;
        _accelerometerZ = event.z;
      });
    });
  }

  // Fetch the username from Firestore
  Future<void> fetchUsername() async {
    try {
      User? user = FirebaseAuth.instance.currentUser; // Get logged-in user
      if (user != null) {
        String uid = user.uid;

        // Fetch user's document from Firestore
        DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (userDoc.exists) {
          setState(() {
            username = userDoc['username'] ?? "User"; // Update username
            isLoading = false; // Stop loading
          });
        }
      }
    } catch (e) {
      print("Error fetching username: $e");
      setState(() {
        isLoading = false; // Stop loading even on error
      });
    }
  }

  // Method to process accelerometer data and detect steps
  void _processAccelerometerData(AccelerometerEvent event) {
    double y = event.y;

    // Check for significant movement on the Y-axis to detect a step
    if (y - _lastY > _threshold) {
      setState(() {
        _steps++; // Increment step count
      });
    }

    // Update the last Y value for the next comparison
    _lastY = y;
  }

  // Method to show a dialog for setting step target
  void _setStepTarget() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int tempTarget = _stepTarget; // Temporary variable to hold the input

        return AlertDialog(
          title: Text('Set Step Target'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Enter Step Target',
              hintText: 'e.g., 10000',
            ),
            onChanged: (value) {
              tempTarget = int.tryParse(value) ?? 0;
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  _stepTarget = tempTarget;
                });
                Navigator.of(context).pop();
              },
              child: Text('Set Target'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = (_steps / _stepTarget); // Calculate progress based on steps and target

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          elevation: 8,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Icon(Icons.person, color: Colors.white), // Profile Icon
              SizedBox(width: 8),
              isLoading
                  ? CircularProgressIndicator(color: Colors.white) // Loading Spinner
                  : Text(
                "Hi $username",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Display the step count
              Text('Steps: $_steps', style: TextStyle(fontSize: 30)),
              SizedBox(height: 20),

              // Circular Progress Bar
              CircularProgressIndicator(
                value: progress > 1.0 ? 1.0 : progress, // Prevent progress exceeding 100%
                strokeWidth: 10,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              SizedBox(height: 20),

              // Display progress percentage
              Text(
                'Progress: ${(progress * 100).toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),

              // Button to set step target
              ElevatedButton(
                onPressed: _setStepTarget,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue
                ),
                child: Text('Set Step Target',style: TextStyle(color: Colors.white),),
              ),
              SizedBox(height: 20),

              // Display the accelerometer data (X, Y, Z values)
              Text('Accelerometer Data:', style: TextStyle(fontSize: 20)),
              Text('X: $_accelerometerX', style: TextStyle(fontSize: 18)),
              Text('Y: $_accelerometerY', style: TextStyle(fontSize: 18)),
              Text('Z: $_accelerometerZ', style: TextStyle(fontSize: 18)),

              // Hint for user to move the device
              SizedBox(height: 20),
              Text(
                'Move your device to start counting steps!',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}