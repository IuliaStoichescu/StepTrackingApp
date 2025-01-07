import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'firebase_service.dart';

class ChartWidget extends StatelessWidget {
  final String title;
  final String dataKey;
  final String userId;

  ChartWidget({required this.title, required this.dataKey, required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<double>>(
      future: fetchWeeklyData(userId, dataKey),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print("Error fetching data: ${snapshot.error}");
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          print("No matching data found");
          return Center(child: Text("No data available for this week"));
        }

        final weeklyData = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            switch (value.toInt()) {
                              case 0:
                                return Text("Mon");
                              case 1:
                                return Text("Tue");
                              case 2:
                                return Text("Wed");
                              case 3:
                                return Text("Thu");
                              case 4:
                                return Text("Fri");
                              case 5:
                                return Text("Sat");
                              case 6:
                                return Text("Sun");
                            }
                            return Text("");
                          },
                        ),
                      ),
                    ),

                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(
                          weeklyData.length,
                              (index) => FlSpot(index.toDouble(), weeklyData[index]),
                        ),
                        isCurved: true,
                        barWidth: 4,
                        color: Colors.blue,
                        belowBarData: BarAreaData(show: true,
                          gradient: LinearGradient(
                              colors: [Colors.blue.withAlpha(77),
                             Colors.lightBlue.withAlpha(77)]),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
