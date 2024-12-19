import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
class BmiCalculator{
  BmiCalculator({required this.height,required this.weight});
  final int height;
  final int weight;

  double _bmi=0.0;

  String calculateBMI(){
    _bmi = weight / pow(height/100, 2);
    return _bmi.toStringAsFixed(1);
  }

  String getResult(){
    if(_bmi>=25){
      return 'Over-Weight';
    }
    else if(_bmi >18.5){
      return 'Normal';
    }
    else{
      return 'Under-Weight';
    }
  }

  Color getResultColor() {
    if (_bmi >= 25) {
      return Colors.red; // Red for Over-Weight
    } else if (_bmi > 18.5) {
      return Colors.green; // Green for Normal
    } else {
      return Colors.orange; // Orange for Under-Weight
    }
  }

  String getStepRecommendation() {
    if (_bmi >= 40) {
      return 'Your BMI indicates that you are in the severely obese range. It is recommended to start with low-impact activities like walking for 4,000–6,000 steps per day and gradually increase. Consulting a healthcare professional is strongly advised. 💪';
    } else if (_bmi >= 35) {
      return 'Your BMI indicates that you are in the obese class II range. Aim for 6,000–8,000 steps per day as a manageable target. Consider pairing this with dietary changes. 💡';
    } else if (_bmi >= 30) {
      return 'Your BMI indicates that you are in the obese class I range. Start with 8,000–10,000 steps per day to encourage gradual weight loss and maintain heart health. 🏃‍♂️';
    } else if (_bmi >= 25) {
      return 'Your BMI indicates that you are in the overweight range. Aiming for 10,000–12,000 steps per day can help improve your fitness level and maintain a healthy weight. 💪';
    } else if (_bmi >= 18.5) {
      return 'Your BMI is in the normal range. Maintaining 7,000–8,000 steps per day is ideal for overall health and well-being. Keep up the good work! ☺';
    } else if (_bmi >= 16) {
      return 'Your BMI indicates that you are in the mildly underweight range. Aim for 5,000–6,000 steps per day and focus on a calorie-dense, nutritious diet to regain a healthy weight. 🥗';
    } else if (_bmi >= 15) {
      return 'Your BMI indicates that you are in the moderately underweight range. Start with light activities, like 3,000–5,000 steps per day, and work with a nutritionist to improve your weight. 💡';
    } else {
      return 'Your BMI indicates that you are in the severely underweight range. Focus on rest, a healthy diet, and low-impact activities like gentle walking, aiming for 2,000–3,000 steps per day as a start. Consulting a healthcare professional is recommended. ☹';
    }
  }

}
