import 'package:flutter/material.dart';
import 'games/spinwheel/lib/main.dart' as spinwheel;
import 'games/slot_game/lib/main.dart' as slot_game;
import 'games/memory_match/lib/main.dart' as memory_match;

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
                  MaterialPageRoute(builder: (context) => spinwheel.MyApp()),
                );
              },
              child: Text('Play Spinwheel Game'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => slot_game.MyNewApp()),
                );
              },
              child: Text('Play Slot Game'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => memory_match.MyApp()), // Add the new game
                );
              },
              child: Text('Play Memory Match Game'),
            ),
          ],
        ),
      ),
    );
  }
}
