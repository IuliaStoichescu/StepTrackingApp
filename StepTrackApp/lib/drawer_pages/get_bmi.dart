import 'package:flutter/material.dart';

class GetBmi extends StatelessWidget {
  const GetBmi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent[100],
        title: Text("Calculate BMI"),
      ),
    );
  }
}
