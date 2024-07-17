import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'spinWheel.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform
  // );
  MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SpinWheel(),
        debugShowCheckedModeBanner: false
    );
  }
}
