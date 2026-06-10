import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../providers/ride_provider.dart';
import '../../../providers/history_provider.dart';
import '../../../models/ride_history.dart';
import '../../../core/services/payment_service.dart';

class RideStatusCard extends StatefulWidget {
  const RideStatusCard({super.key});

  @override
  State<RideStatusCard> createState() => _RideStatusCardState();
}

class _RideStatusCardState extends State<RideStatusCard> {
  final PaymentService _paymentService = PaymentService();
  final TextEditingController _pickupController = TextEditingController(text: 'Current Location');
  final TextEditingController _destController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _paymentService.initialize(
      _handlePaymentSuccess,
      _handlePaymentError,
      _handleExternalWallet,
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment Successful!'), backgroundColor: Colors.green),
    );
    context.read<RideProvider>().resetRide();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}'), backgroundColor: Colors.red),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  @override
  void dispose() {
    _paymentService.dispose();
    _pickupController.dispose();
    _destController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $uri');
    }
  }

  Future<void> _makeCall(String number) async {
    await _launchUrl('tel:$number');
  }

  Future<void> _openWhatsApp(String number) async {
    await _launchUrl('https://wa.me/$number');
  }

  @override
  Widget build(BuildContext context) {
    final rideProvider = context.watch<RideProvider>();
    final historyProvider = context.read<HistoryProvider>();

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (rideProvider.status == RideStatus.idle) ...[
              const Text('Where are you going?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              TextField(
                controller: _pickupController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.my_location, color: Colors.green),
                  hintText: 'Pickup Location',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _destController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                  hintText: 'Destination',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  if (_destController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a destination')),
                    );
                    return;
                  }
                  rideProvider.setLocations(_pickupController.text, _destController.text);
                  rideProvider.setStatus(RideStatus.searching);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow.shade700,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Book a Ride', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ] else if (rideProvider.status == RideStatus.searching) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 10),
              const Text('Searching for nearby taxis...'),
              TextButton(
                onPressed: () => rideProvider.setStatus(RideStatus.idle),
                child: const Text('Cancel'),
              ),
              // Simulate finding a ride
              FutureBuilder(
                future: Future.delayed(const Duration(seconds: 3)),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      rideProvider.confirmRide('John Doe', 'KA 01 AB 1234');
                    });
                  }
                  return const SizedBox.shrink();
                },
              ),
            ] else if (rideProvider.status == RideStatus.confirmed) ...[
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(rideProvider.driverName ?? 'Driver'),
                subtitle: Text(rideProvider.carNumber ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.call, color: Colors.green), onPressed: () => _makeCall('1234567890')),
                    IconButton(icon: const Icon(Icons.message, color: Colors.blue), onPressed: () => _openWhatsApp('1234567890')),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => rideProvider.setStatus(RideStatus.ongoing),
                child: const Text('Start Ride'),
              ),
            ] else if (rideProvider.status == RideStatus.ongoing) ...[
              const Text('Ride in Progress...', style: TextStyle(fontWeight: FontWeight.bold)),
              const LinearProgressIndicator(),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  final ride = RideHistory(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    pickup: rideProvider.pickup,
                    destination: rideProvider.destination,
                    date: DateTime.now(),
                    fare: 150.0,
                    driverName: rideProvider.driverName ?? 'Unknown',
                  );
                  historyProvider.addRide(ride);
                  rideProvider.setStatus(RideStatus.completed);
                },
                child: const Text('Complete Ride'),
              ),
            ] else if (rideProvider.status == RideStatus.completed) ...[
              const Text('Ride Completed!', style: TextStyle(fontSize: 18, color: Colors.green)),
              const Icon(Icons.check_circle, color: Colors.green, size: 48),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _paymentService.openCheckout(150.0, '9876543210', 'user@example.com');
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                child: const Text('Pay ₹150.00'),
              ),
              TextButton(
                onPressed: () => rideProvider.resetRide(),
                child: const Text('Skip Payment (Demo)'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
