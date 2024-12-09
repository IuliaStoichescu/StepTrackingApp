import 'package:flutter/material.dart';

class SessionManager extends ChangeNotifier {
  bool _isSessionActive = false;
  int _stepGoal = 5000;
  int _steps = 0;
  double _distance = 0.0; // in kilometers
  double _calories = 0.0;
  Duration _timeElapsed = Duration.zero;

  bool get isSessionActive => _isSessionActive;
  int get stepGoal => _stepGoal;
  int get steps => _steps;
  double get distance => _distance;
  double get calories => _calories;
  Duration get timeElapsed => _timeElapsed;

  void startSession(int stepGoal) {
    _isSessionActive = true;
    _stepGoal = stepGoal;
    _steps = 0;
    _distance = 0.0;
    _calories = 0.0;
    _timeElapsed = Duration.zero;
    notifyListeners();
  }

  void updateSession({required int steps, required double distance, required Duration time}) {
    _steps = steps;
    _distance = distance;
    _calories = _steps * 0.04; // Calories burned: 0.04 per step
    _timeElapsed = time;
    notifyListeners();
  }

  void stopSession() {
    _isSessionActive = false;
    notifyListeners();
  }

  void resetSession() {
    _steps = 0;
    _distance = 0.0;
    _calories = 0.0;
    _timeElapsed = Duration.zero;
    notifyListeners();
  }

}
