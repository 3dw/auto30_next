import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:auto30_next/core/config/app_config.dart';
import 'package:auto30_next/core/theme/app_theme.dart';
import 'package:auto30_next/features/auth/presentation/providers/auth_provider.dart';
import 'package:auto30_next/core/providers/theme_provider.dart';
import 'package:auto30_next/core/providers/flag_status_provider.dart';
import 'package:auto30_next/core/config/firebase_options.dart';
import 'package:auto30_next/core/config/app_router.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const MyApp());
  } catch (e, stackTrace) {
    debugPrint('Error initializing Firebase: $e');
    debugPrint('StackTrace: $stackTrace');
    // Show error UI with more details
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Error initializing app:'),
                Text(e.toString(), style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                Text(stackTrace.toString(),
                    style: const TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FlagStatusProvider()),
        // Add other providers here
      ],
      child: Consumer2<AuthProvider, ThemeProvider>(
        builder: (context, authProvider, themeProvider, _) {
          final router = AppRouter.createRouter(authProvider);
          
          return MaterialApp.router(
            title: AppConfig.appName,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
