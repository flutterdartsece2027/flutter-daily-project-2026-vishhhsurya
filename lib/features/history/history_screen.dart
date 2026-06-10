import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/history_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>().history;

    return Scaffold(
      appBar: AppBar(title: const Text('Ride History')),
      body: history.isEmpty
          ? const Center(child: Text('No rides yet'))
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final ride = history[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text('${ride.pickup} to ${ride.destination}'),
                    subtitle: Text(DateFormat('dd MMM yyyy, hh:mm a').format(ride.date)),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('₹${ride.fare}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          onPressed: () => context.read<HistoryProvider>().deleteRide(ride.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
