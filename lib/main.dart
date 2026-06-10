import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/splash/splash_screen.dart';
import 'providers/ride_provider.dart';
import 'providers/history_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RideProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
      ],
      child: const TaxiApp(),
    ),
  );
}

class TaxiApp extends StatelessWidget {
  const TaxiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Taxi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow.shade700),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
