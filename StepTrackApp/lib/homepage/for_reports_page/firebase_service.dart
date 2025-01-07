import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<double>> fetchWeeklyData(String userId, String metric) async {
  print("Fetching data for userId: $userId and metric: $metric");

  // Query Firestore for documents within the current week
  final snapshot = await FirebaseFirestore.instance
      .collection('user_info')
      .doc(userId)
      .collection('track_activity')
      .orderBy('timestamp', descending: false) // Remove the `where` filter for debugging
      .get();

  /*print("Fetched all documents: ${snapshot.docs.length}");
  for (var doc in snapshot.docs) {
    print("Document data: ${doc.data()}");
  }*/
  print("Start of the week: ${getStartOfWeek()}");


  // Log the number of documents fetched
  print("Fetched ${snapshot.docs.length} documents");

  // Initialize weekly data map (0 = Monday, ..., 6 = Sunday)
  Map<int, double> weeklyData = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};

  for (var doc in snapshot.docs) {
    final timestamp = doc['timestamp'] as Timestamp?;
    final dynamic rawValue = doc[metric]; // Use dynamic to handle int/double

    if (timestamp == null || rawValue == null) {
      print("Skipping document with missing data for timestamp or metric $metric: ${doc.id}");
      continue;
    }

    // Convert int to double if necessary
    final value = rawValue is int ? rawValue.toDouble() : rawValue as double;

    final weekday = timestamp.toDate().weekday - 1; // Convert to 0-based (0 = Monday)
    weeklyData[weekday] = (weeklyData[weekday] ?? 0) + value;

    print("Updated weeklyData: $weeklyData");
  }


  print("Processed weekly data: $weeklyData");
  return weeklyData.values.toList();
}

DateTime getStartOfWeek() {
  final now = DateTime.now();
  return now.subtract(Duration(days: now.weekday - 1)); // Start of the current week
}

