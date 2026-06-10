import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/ride_provider.dart';
import 'widgets/ride_status_card.dart';
import '../history/history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _mapController;
  static const LatLng _center = LatLng(12.9716, 77.5946); // Bangalore

  final Set<Marker> _markers = {
    const Marker(
      markerId: MarkerId('driver1'),
      position: LatLng(12.9720, 77.5950),
      infoWindow: InfoWindow(title: 'Taxi 1'),
      icon: BitmapDescriptor.defaultMarker, // Should be car icon
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Taxi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.yellow.shade700),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(radius: 30, child: Icon(Icons.person, size: 40)),
                  SizedBox(height: 10),
                  Text('John Doe', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Ride History'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
            ),
            ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text('Support Website'),
              onTap: () async {
                final Uri url = Uri.parse('https://flutter.dev'); // Replace with your support site
                if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                  throw Exception('Could not launch $url');
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => _mapController = controller,
            initialCameraPosition: const CameraPosition(
              target: _center,
              zoom: 14.0,
            ),
            markers: _markers,
          ),
          const Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: RideStatusCard(),
          ),
        ],
      ),
    );
  }
}
