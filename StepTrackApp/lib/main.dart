import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:step_track_app/drawer_pages/get_bmi.dart';
import 'package:step_track_app/homepage/main_page.dart';
import 'package:step_track_app/logsign/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:step_track_app/homepage/track_page.dart';
import 'package:step_track_app/session/session_manager.dart';
import 'first_page.dart';
import 'homepage/home_page.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
      ChangeNotifierProvider(
        create: (_) => SessionManager(),
        child: const MyApp(),
      ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: FirstPage(),
        routes: {
          '/login': (context)=>Login(),
          '/mainPage': (context)=>MainPage(),
          '/trackPage': (context)=>TrackPage(),
          '/homePage': (context)=>HomePage(),
          '/getBmi' : (context)=>GetBmi()
        },
    );
  }
}




