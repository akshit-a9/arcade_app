import 'package:flutter/material.dart';
import 'background.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _requestPermission();
  runApp(MyApp());
}

Future<void> _requestPermission() async {
  await Permission.location.request();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Maps Background',
      home: MapScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
