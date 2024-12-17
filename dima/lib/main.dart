import 'package:dima/managers/provider/navigation_provider.dart';
import 'package:dima/managers/provider/rebuild_provider.dart';
import 'package:dima/pages/home_page.dart';
import 'package:dima/pages/auth_page.dart';
import 'package:dima/pages/user_init_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'managers/controllers/article_controller.dart';
import 'firebase_options.dart';
import 'managers/provider/userEdit_provider.dart';

List<String> nameCategories = [
  'general',
  'sports',
  'entertainment',
  'health',
  'business',
  'technology'
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ArticleController()),
        ChangeNotifierProvider(create: (context) => UserEditProvider()),
        ChangeNotifierProvider(create: (_) => RebuildNotifier()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthPage(), // Map the '/' route to AuthPage
        HomePage.routeName: (context) => const HomePage(),
        // Add other routes here
        UserInitPage.routeName: (context) => const UserInitPage(),
      },
    );
  }
}
