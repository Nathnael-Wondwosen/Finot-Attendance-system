import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/screens/main_navigation_screen.dart';
import 'core/theme.dart';
import 'presentation/providers/theme_provider.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeStateProvider);

    return MaterialApp(
      title: 'Finot Attendance System',
      theme: AppTheme.buildDynamicTheme(themeState),
      themeMode: themeState.themeMode,
      darkTheme: AppTheme.buildDynamicDarkTheme(themeState),
      debugShowCheckedModeBanner: false,
      home:
          const MainScreen(), // Use a main screen that contains bottom navigation
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainNavigationScreen();
  }
}
