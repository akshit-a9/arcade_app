import 'package:flutter/material.dart';
import 'games/spinwheel/lib/main.dart' as spinwheel;
import 'games/slot_game/lib/main.dart' as slot_game;
import 'package:arcade_app/games/spinwheel/lib/spinthewheel.dart';
import 'package:arcade_app/games/slot_game/lib/roll_slot.dart';
import 'package:arcade_app/games/slot_game/lib/roll_slot_controller.dart';
import 'package:arcade_app/games/slot_game/lib/scoreboard.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arcade App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ArcadeHome(),
    );
  }
}

class ArcadeHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Arcade App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => spinwheel.SpinWheel()),
                );
              },
              child: Text('Play Spinwheel Game'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => slot_game.SlotGame()),
                );
              },
              child: Text('Play Slot Game'),
            ),
          ],
        ),
      ),
    );
  }
}
