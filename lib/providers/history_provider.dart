import 'package:flutter/material.dart';
import '../models/ride_history.dart';

class HistoryProvider with ChangeNotifier {
  final List<RideHistory> _history = [];

  List<RideHistory> get history => List.unmodifiable(_history);

  void addRide(RideHistory ride) {
    _history.insert(0, ride);
    notifyListeners();
  }

  void deleteRide(String id) {
    _history.removeWhere((ride) => ride.id == id);
    notifyListeners();
  }

  void updateRide(RideHistory updatedRide) {
    final index = _history.indexWhere((ride) => ride.id == updatedRide.id);
    if (index != -1) {
      _history[index] = updatedRide;
      notifyListeners();
    }
  }
}
