import 'package:flutter/material.dart';

enum RideStatus { searching, confirmed, ongoing, completed, idle }

class RideProvider with ChangeNotifier {
  RideStatus _status = RideStatus.idle;
  RideStatus get status => _status;

  void setStatus(RideStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }

  // Add more ride details like driver info, car details, etc.
  String? driverName;
  String? carNumber;
  String pickup = 'Current Location';
  String destination = '';

  void setLocations(String p, String d) {
    pickup = p;
    destination = d;
    notifyListeners();
  }

  void confirmRide(String name, String car) {
    driverName = name;
    carNumber = car;
    setStatus(RideStatus.confirmed);
  }

  void resetRide() {
    driverName = null;
    carNumber = null;
    setStatus(RideStatus.idle);
  }
}
