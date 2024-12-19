import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:step_track_app/drawer_pages/youtube_player/player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// Enum for difficulty levels
enum WorkoutDifficulty { easy, medium, hard }

// Video lists for each difficulty level
final easyVideos = [
  'https://youtu.be/-oISWIJjKws?si=uksFCAXrnV-ynXm1',
  'https://youtu.be/mCeFdXQtj5E?si=6mctTn2DzRnbtOCc',
];

final mediumVideos = [
  'https://youtu.be/htNphBVfl4w?si=vcEbdIr3k_8xCcf7',
  'https://youtu.be/Gykh4bBT_4s?si=EFLObPFuwh7gpAc1',
  'https://youtu.be/Nc_NZ3PXhE8?si=aqvGMUeC-Z1sFvAH',
];

final hardVideos = [
  'https://youtu.be/cAAB2yjlwhI?si=Rdvl55Tq-MFo9G_7',
];

class StepWorkoutVideos extends StatefulWidget {
  const StepWorkoutVideos({super.key});

  @override
  State<StepWorkoutVideos> createState() => _StepWorkoutVideosState();
}

class _StepWorkoutVideosState extends State<StepWorkoutVideos> {
  // Current selected difficulty
  WorkoutDifficulty? selectedDifficulty;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFC8E6C9),Color(0xFFBBDEFB), Color(0xFFE1BEE7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Main content
        Scaffold(
          backgroundColor: Colors.transparent, // Make the Scaffold background transparent
          appBar: AppBar(
            elevation: 8,
            centerTitle: true,
            title: Text(
              "Walking Workouts",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.blue[200],
            iconTheme: const IconThemeData(
              color: Colors.white, // Changes the back arrow color to white
            ),
          ),
          body: selectedDifficulty == null
              ? _buildSelectionScreen() // Show selection screen
              : _buildVideoListScreen(), // Show videos based on selection
        ),
      ],
    );
  }

  // Widget to build the selection screen
  Widget _buildSelectionScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie animation at the top
          SizedBox(
            height: 200,
            child: Lottie.asset('assets/animations/workout.json'), // Add your Lottie file here
          ),
          SizedBox(height: 20),

          // Text below the Lottie animation
          Text(
            "Choose your type of step workout",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 40),

          // Difficulty buttons
          _buildDifficultyButton("Easy Workouts", WorkoutDifficulty.easy),
          SizedBox(height: 30),
          _buildDifficultyButton("Medium Workouts", WorkoutDifficulty.medium),
          SizedBox(height: 30),
          _buildDifficultyButton("Hard Workouts", WorkoutDifficulty.hard),
        ],
      ),
    );
  }

  // Helper method to build a difficulty button
  Widget _buildDifficultyButton(String text, WorkoutDifficulty difficulty) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedDifficulty = difficulty; // Set the selected difficulty
        });
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        backgroundColor: Colors.blue[200],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }

  // Widget to build the video list screen
  Widget _buildVideoListScreen() {
    final videoList = _getVideosByDifficulty(selectedDifficulty!);

    return Stack(
      children: [
        // List of videos
        ListView.builder(
          itemCount: videoList.length,
          itemBuilder: (context, index) {
            final videoID = YoutubePlayer.convertUrlToId(videoList[index]);

            return InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Player(videoID: videoID!),
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    YoutubePlayer.getThumbnail(videoId: videoID!),
                  ),
                ),
              ),
            );
          },
        ),

        // Back arrow in the bottom-left corner
        Positioned(
          bottom: 20,
          left: 20,
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                selectedDifficulty = null; // Reset the selection
              });
            },
            backgroundColor: Colors.blue[200],
            mini: true, // Make the button small
            child: Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
      ],
    );
  }

  // Helper method to get videos by difficulty
  List<String> _getVideosByDifficulty(WorkoutDifficulty difficulty) {
    switch (difficulty) {
      case WorkoutDifficulty.easy:
        return easyVideos;
      case WorkoutDifficulty.medium:
        return mediumVideos;
      case WorkoutDifficulty.hard:
        return hardVideos;
    }
  }
}
