import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/svg.dart';
import 'package:step_track_app/drawer_pages/change_profile.dart';
import 'package:step_track_app/drawer_pages/get_bmi.dart';
import 'package:step_track_app/drawer_pages/step_workout_videos.dart';
import 'main_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
        // Fetch both 'user_info' and 'profile/details' concurrently
        final userInfoRef = _firestore.collection('user_info').doc(user.uid);
        final profileRef =
        _firestore.collection('user_info').doc(user.uid).collection('profile').doc('details');

        final userInfoSnapshot = await userInfoRef.get();
        final profileSnapshot = await profileRef.get();

        String fetchedUsername = "User"; // Default fallback

        if (profileSnapshot.exists && profileSnapshot.data()?['username'] != null) {
          // Use username from 'profile/details' if it exists
          fetchedUsername = profileSnapshot.data()?['username'];
        } else if (userInfoSnapshot.exists && userInfoSnapshot.data()?['username'] != null) {
          // Fallback to 'user_info' username if 'profile/details' is empty
          fetchedUsername = userInfoSnapshot.data()?['username'];
        }

        setState(() {
          _username = fetchedUsername;
        });
      } else {
        setState(() {
          _username = "User not logged in";
        });
      }
    } catch (e) {
      print("Error fetching username: $e");
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
        iconTheme: IconThemeData(color: Colors.white),
        // Change drawer icon color
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
      endDrawer: Drawer(
        backgroundColor: Colors.black45,
        elevation: 2,
        shadowColor: Colors.white,
        width: 250,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox( // Wrap DrawerHeader in SizedBox for fixed height
              height: 250, // Adjust the height as needed
              child: DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.lightBlueAccent,
                ),
                child: FutureBuilder<List<DocumentSnapshot>>(
                  future: Future.wait([
                    _firestore.collection("user_info").doc(_auth.currentUser?.uid).get(), // Fetch email
                    _firestore
                        .collection("user_info")
                        .doc(_auth.currentUser?.uid)
                        .collection("profile")
                        .doc("details")
                        .get(), // Fetch profile data
                  ]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          "Failed to load profile",
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    if (!snapshot.hasData ||
                        !snapshot.data![0].exists ||
                        !snapshot.data![1].exists) {
                      return const Center(
                        child: Text(
                          "No profile data found",
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    // Extract data from both documents
                    final emailData = snapshot.data![0];
                    final profileData = snapshot.data![1];

                    final String email = emailData["email"] ?? "No email";
                    final String username = profileData["username"] ?? "User";
                    final String imageUrl =
                        profileData["imageUrl"] ?? "https://via.placeholder.com/150";

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(imageUrl),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis, // Prevent overflow
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis, // Prevent overflow
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.accessibility, color: Colors.white),
              title: const Text("Calculate BMI", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => GetBmi()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_collection_rounded, color: Colors.white),
              title: const Text("Videos", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => StepWorkoutVideos()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.create, color: Colors.white),
              title: const Text("Profile", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChangeProfile()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics, color: Colors.white),
              title: const Text("Reports", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainPage(initialTab: 2),
                  ),
                );
              },
            ),
          ],
        ),
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
            const SizedBox(height: 50),

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
            const SizedBox(height: 50),

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
