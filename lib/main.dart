import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:nearbycreds/firebase_options.dart';
import 'package:nearbycreds/src/core/app_router.dart';


void main() async{
  // runApp(const MainApp());
    WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
   

  // Initialize Firebase App Check with a debug provider for development
  // await FirebaseAppCheck.instance.activate();
  
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
   return MaterialApp.router(
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      title: 'NearbyCreds',
      theme: ThemeData(primarySwatch: Colors.indigo),
    );
  }
}
