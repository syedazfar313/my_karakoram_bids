import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/projects_provider.dart'; // Add this import
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const KarakoramBidsApp());
}

class KarakoramBidsApp extends StatelessWidget {
  const KarakoramBidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => ProjectsProvider(),
        ), // Added ProjectsProvider
      ],
      child: MaterialApp(
        title: 'Karakoram Bids',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme, // Centralized theme
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.generateRoute, // Dynamic routes
      ),
    );
  }
}
