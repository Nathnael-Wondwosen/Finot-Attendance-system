import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/ui_components.dart';
import '../../core/typography.dart';
import '../../core/responsive_layout.dart';
import '../../domain/entities/class_entity.dart';
import '../providers/app_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  List<ClassEntity> _classes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAndSyncClasses();
  }

  Future<void> _loadAndSyncClasses() async {
    // Check if widget is still mounted before updating state
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // First check if we're online and sync classes from remote
      final syncService = ref.read(syncServiceProvider);
      final isOnline = await syncService.isOnline();

      if (isOnline) {
        // Download all classes and their students from remote
        await syncService.downloadAllClasses();
      }

      // Get classes from local storage (either newly synced or cached)
      final classRepository = ref.read(classRepositoryProvider);
      final classes = await classRepository.getClasses();

      // Check if widget is still mounted before updating state
      if (mounted) {
        setState(() {
          _classes = classes;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Check if widget is still mounted before updating state
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading classes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _loadAndSyncClasses,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to Attendance System',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Select a class to take attendance',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _classes.isEmpty
                      ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.class_, size: 80, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No classes available',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Connect to internet to download classes from the server',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                      : RefreshIndicator(
                        onRefresh: _loadAndSyncClasses,
                        child: ListView.builder(
                          itemCount: _classes.length,
                          itemBuilder: (context, index) {
                            final classEntity = _classes[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                title: Text(
                                  classEntity.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  'ID: ${classEntity.serverId}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  // Navigate to main navigation and select the class selection tab
                                  Navigator.pushNamed(
                                    context,
                                    '/main-navigation',
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
