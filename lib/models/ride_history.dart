class RideHistory {
  final String id;
  final String pickup;
  final String destination;
  final DateTime date;
  final double fare;
  final String driverName;

  RideHistory({
    required this.id,
    required this.pickup,
    required this.destination,
    required this.date,
    required this.fare,
    required this.driverName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pickup': pickup,
      'destination': destination,
      'date': date.toIso8601String(),
      'fare': fare,
      'driverName': driverName,
    };
  }

  factory RideHistory.fromMap(Map<String, dynamic> map) {
    return RideHistory(
      id: map['id'],
      pickup: map['pickup'],
      destination: map['destination'],
      date: DateTime.parse(map['date']),
      fare: map['fare'],
      driverName: map['driverName'],
    );
  }
}
