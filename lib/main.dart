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
  List<String> activityHistory = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final preferences = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      ecoPoints = preferences.getInt('ecoPoints') ?? 0;
      activityHistory =
          preferences.getStringList('activityHistory') ?? [];
    });
  }

  Future<void> addActivity(String activity, int points) async {
    final now = DateTime.now();

    final time =
        '${now.day}/${now.month}/${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';

    final newEntry = '$activity|+$points points|$time';

    setState(() {
      ecoPoints += points;
      activityHistory.insert(0, newEntry);
    });

    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt('ecoPoints', ecoPoints);
    await preferences.setStringList(
      'activityHistory',
      activityHistory,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$activity added! You earned $points points.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> resetData() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setInt('ecoPoints', 0);
    await preferences.setStringList('activityHistory', []);

    setState(() {
      ecoPoints = 0;
      activityHistory = [];
    });
  }

  Future<void> confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset EcoTrack?'),
          content: const Text(
            'This will delete your points and activity history.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await resetData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoTrack'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: confirmReset,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset data',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.eco,
              size: 65,
              color: Colors.green,
            ),
            const Text(
              'Make every action count!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Your Eco Points',
                      style: TextStyle(fontSize: 17),
                    ),
                    Text(
                      '$ecoPoints',
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: () {
                addActivity('Recycled today', 10);
              },
              icon: const Icon(Icons.recycling),
              label: const Text('I recycled today  +10'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                addActivity('Walked instead of driving', 15);
              },
              icon: const Icon(Icons.directions_walk),
              label: const Text('I walked instead of driving  +15'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                addActivity('Saved water', 5);
              },
              icon: const Icon(Icons.water_drop),
              label: const Text('I saved water  +5'),
            ),
            const SizedBox(height: 18),
            const Text(
              'Recent Activities',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: activityHistory.isEmpty
                  ? const Center(
                child: Text(
                  'No activities yet.\nComplete an action to begin!',
                  textAlign: TextAlign.center,
                ),
              )
                  : ListView.builder(
                itemCount: activityHistory.length,
                itemBuilder: (context, index) {
                  final parts =
                  activityHistory[index].split('|');

                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(parts[0]),
                      subtitle: Text(parts[2]),
                      trailing: Text(
                        parts[1],
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}