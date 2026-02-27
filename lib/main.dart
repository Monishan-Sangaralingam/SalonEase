import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salon_app/provider/user_provider.dart';
import 'package:salon_app/screens/introduction/spalsh_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Object? firebaseInitError;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    firebaseInitError = e;
  }

  runApp(MyApp(firebaseInitError: firebaseInitError));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.firebaseInitError});

  final Object? firebaseInitError;

  @override
  Widget build(BuildContext context) {
    if (firebaseInitError != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Salon app',
        home: FirebaseInitErrorScreen(error: firebaseInitError!),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(
          create: ((context) => UserProvider()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Salon app',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const SplashScreen(),
      ),
    );
  }
}

class FirebaseInitErrorScreen extends StatelessWidget {
  const FirebaseInitErrorScreen({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Firebase is not configured for this platform',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'The app failed during Firebase.initializeApp().\n'
                'On Web this commonly happens when FirebaseOptions are missing.',
              ),
              const SizedBox(height: 12),
              const Text(
                'Fix:\n'
                '1) Run: flutterfire configure\n'
                '2) Add the generated lib/firebase_options.dart\n'
                '3) Initialize with DefaultFirebaseOptions.currentPlatform',
              ),
              const SizedBox(height: 16),
              const Text('Error:'),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    error.toString(),
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
