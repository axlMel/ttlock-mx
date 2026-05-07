import 'package:flutter/material.dart';
import '../services/lock_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List locks = [];
  bool isLoading = true;
  late String token;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    token = ModalRoute.of(context)!.settings.arguments as String;
    fetchLocks();
  }

  Future<void> fetchLocks() async {
    final data = await LockService().getLocks(token);
    setState(() {
      locks = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis cerraduras'),),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : locks.isEmpty
          ? const Center(child: Text('No hay cerraduras'))
          : ListView.builder(
              itemCount: locks.length,
              itemBuilder: (context, index) {
                final lock = locks[index];
                return ListTile(
                  title: Text(lock['lockName'] ?? 'Sin nombre'),
                  subtitle: Text('ID ${lock['lockId']}'),
                );
              },
            ),
    );
  }
}
