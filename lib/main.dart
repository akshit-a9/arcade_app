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
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background_main.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 50),
            Text(
              'Arcade',
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: EdgeInsets.all(20),
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: <Widget>[
                  buildGameButton(context, 'Spin&Win', 'assets/images/logo_1.png', spinwheel.MyApp()),
                  buildGameButton(context, 'GoldenSlots', 'assets/images/logo_2.png', slot_game.MyNewApp()),
                  buildGameButton(context, 'Match Master', 'assets/images/logo_3.png', memory_match.MyApp()),
                  buildGameButton(context, 'Drive Through', 'assets/images/logo_placeholder.png', null), // Placeholder for future game
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGameButton(BuildContext context, String title, String imagePath, Widget? gameApp) {
    return GestureDetector(
      onTap: gameApp != null
          ? () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => gameApp),
        );
      }
          : null,
      child: Card(
        color: Colors.transparent,
        elevation: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(imagePath, width: 80, height: 80),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
