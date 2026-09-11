import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const EcoTrackApp());
}

class EcoTrackApp extends StatelessWidget {
  const EcoTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoTrack',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int ecoPoints = 0;

  @override
  void initState() {
    super.initState();
    loadPoints();
  }

  Future<void> loadPoints() async {
    final preferences = await SharedPreferences.getInstance();
    final savedPoints = preferences.getInt('ecoPoints') ?? 0;

    setState(() {
      ecoPoints = savedPoints;
    });
  }

  Future<void> addPoints(int points) async {
    final newTotal = ecoPoints + points;

    setState(() {
      ecoPoints = newTotal;
    });

    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt('ecoPoints', newTotal);
  }

  Future<void> resetPoints() async {
    setState(() {
      ecoPoints = 0;
    });

    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt('ecoPoints', 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoTrack'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.eco,
              size: 90,
              color: Colors.green,
            ),
            const SizedBox(height: 10),
            const Text(
              'Make every action count!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Your Eco Points',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      '$ecoPoints',
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => addPoints(10),
              icon: const Icon(Icons.recycling),
              label: const Text('I recycled today  +10'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => addPoints(15),
              icon: const Icon(Icons.directions_walk),
              label: const Text('I walked instead of driving  +15'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => addPoints(5),
              icon: const Icon(Icons.water_drop),
              label: const Text('I saved water  +5'),
            ),
            const SizedBox(height: 15),
            TextButton.icon(
              onPressed: resetPoints,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset points'),
            ),
          ],
        ),
      ),
    );
  }
}