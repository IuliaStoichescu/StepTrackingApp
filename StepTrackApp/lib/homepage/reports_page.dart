import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'for_reports_page/chart_widget.dart';

User? get currentUser => FirebaseAuth.instance.currentUser;

class ReportsPage extends StatelessWidget {
  ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = currentUser?.uid ?? "";

    return DefaultTabController(
      length: 4, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Weekly Reports - Track Your Progress",
            style: TextStyle(color: Colors.white),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blue,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0), // Adjust padding here
              child: Icon(
                size: 30,
                Icons.trending_up, // Replace with your preferred icon
                color: Colors.white, // White color for the icon
              ),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.directions_walk), text: "Steps"),
              Tab(icon: Icon(Icons.timeline), text: "Distance"),
              Tab(icon: Icon(Icons.local_fire_department), text: "Calories"),
              Tab(icon: Icon(Icons.timer), text: "Time"),
            ],
            indicatorColor: Colors.green[200], // Highlight the selected tab
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
          ),
        ),
        body: TabBarView(
          children: [
            ChartWidget(title: "Steps Per Week", dataKey: "steps", userId: userId),
            ChartWidget(title: "Distance Per Week", dataKey: "distance", userId: userId),
            ChartWidget(title: "Calories Burned Per Week", dataKey: "calories", userId: userId),
            ChartWidget(title: "Time Spent Walking Per Week", dataKey: "time", userId: userId),
          ],
        ),
      ),
    );
  }
}
