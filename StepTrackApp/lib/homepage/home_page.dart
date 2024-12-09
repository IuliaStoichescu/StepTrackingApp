import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../session/session_manager.dart';
import 'main_page.dart';
import 'track_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _stepGoalController = TextEditingController();

  String _username = "Loading...";
  int _stepGoal = 5000; // Default step goal
  int _currentSteps = 0; // Steps recorded during the session
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchUsername();
    _stepGoalController.text = _stepGoal.toString(); // Initialize text field
  }

  Future<void> _fetchUsername() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('user_info').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          setState(() {
            _username = doc.data()!['username'] ?? "User";
          });
        } else {
          setState(() {
            _username = "No username found";
          });
        }
      } else {
        setState(() {
          _username = "User not logged in";
        });
      }
    } catch (e) {
      setState(() {
        _username = "Error fetching username";
      });
    }
  }

  void _updateStepGoal() {
    try {
      final int newGoal = int.parse(_stepGoalController.text);
      if (newGoal > 0) {
        setState(() {
          _stepGoal = newGoal;
        });
      } else {
        _showError("Please enter a positive number for the step goal.");
      }
    } catch (e) {
      _showError("Invalid input. Please enter a valid number.");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _startSession() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainPage(initialTab: 1),
      ),
    );

    if (result != null && result is int) {
      setState(() {
        _currentSteps = result;
        _progress = (_currentSteps / _stepGoal).clamp(0.0, 1.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.person, color: Colors.white), // Replace with your desired icon
          onPressed: () {
            // Add functionality for the icon if needed
            print("Icon tapped");
          },
        ),
        title: Text(
          "Hi, $_username!",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.lightBlueAccent,
        elevation: 1,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Progress Indicator Section
            Column(
              children: [
                Stack(
                  alignment: Alignment.center, // Center the SVG in the CircularProgressIndicator
                  children: [
                    SizedBox(
                      width: 200, // Adjust the size of the circle
                      height: 200, // Adjust the size of the circle
                      child: CircularProgressIndicator(
                        value: _progress,
                        strokeWidth: 10.0, // Thicker stroke
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation(Colors.green),
                        semanticsLabel: 'Step Progress',
                        semanticsValue: "${(_progress * 100).toStringAsFixed(1)}%",
                      ),
                    ),
                    // Add the SVG inside the circle
                    SvgPicture.asset(
                      'assets/svg_files/shoe-prints-solid.svg',
                      width: 50,
                      height: 50,
                    ),
                  ],
                ),



                const SizedBox(height: 20),
                Text(
                  "${_currentSteps.toString()} / ${_stepGoal.toString()} steps",
                  style: const TextStyle(
                    fontSize: 24, // Larger font size
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${(_progress * 100).toStringAsFixed(1)}% of Goal",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 90),

            // Set Your Step Goal Section
            Column(
              children: [
                Text(
                  "Set Your Step Goal:",
                  style: const TextStyle(
                    fontSize: 22,
                    //fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _stepGoalController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Enter your step goal",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.green, Colors.teal, Colors.lightBlueAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20), // Rounded corners
                      ),
                      child: ElevatedButton(
                        onPressed: _updateStepGoal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent, // Makes button background transparent
                          shadowColor: Colors.transparent, // Removes shadow for better gradient look
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40), // Match the gradient corners
                          ),
                        ),
                        child: const Text(
                          "Set Goal",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // White text
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ],
            ),
            const SizedBox(height: 100),

            // Start Session Button
            ElevatedButton(
              onPressed: _startSession,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                backgroundColor: Colors.lightBlueAccent,
                minimumSize: const Size(200, 50), // Adjust width to 200px and height to 50px
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min, // Make the button fit the content size
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.directions_walk, // Replace with your desired icon
                    color: Colors.white, // Icon color
                  ),
                  const SizedBox(width: 8), // Add spacing between the icon and text
                  const Text(
                    "Start Session",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
