import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:slot_game/roll_slot.dart';
import 'package:slot_game/roll_slot_controller.dart';
import 'package:slot_game/scoreboard.dart'; 

class Assets {
  static const seventhIc = 'assets/images/777.svg';
  static const cherryIc = 'assets/images/cherry.svg';
  static const appleIc = 'assets/images/apple.svg';
  static const barIc = 'assets/images/bar.svg';
  static const coinIc = 'assets/images/coin.svg';
  static const crownIc = 'assets/images/crown.svg';
  static const lemonIc = 'assets/images/lemon.svg';
  static const watermelonIc = 'assets/images/watermelon.svg';
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roll Slot Machine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Slot Machine'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _rollSlotController = RollSlotController();
  final _rollSlotController1 = RollSlotController();
  final _rollSlotController2 = RollSlotController();
  final _scoreBoardKey = GlobalKey<ScoreBoardState>();
  final List<String> prizesList = [
    Assets.seventhIc,
    Assets.cherryIc,
    Assets.appleIc,
    Assets.barIc,
    Assets.coinIc,
    Assets.crownIc,
    Assets.lemonIc,
    Assets.watermelonIc,
  ];

  int spinCounter = 0;
  Random _random = Random();

  @override
  void initState() {
    super.initState();
  }

  void _updateScore() {
    final centerImages = [
      prizesList[_rollSlotController.centerIndex],
      prizesList[_rollSlotController1.centerIndex],
      prizesList[_rollSlotController2.centerIndex],
    ];
    _scoreBoardKey.currentState?.updateScore(centerImages);
    if (spinCounter == 2 || spinCounter == 2) {
      spinCounter = 0; // Reset the counter after the specific spins
    } else {
      spinCounter++;
    }
  }

  void _spinAllSlots() {
    int index = _random.nextInt(prizesList.length);
    bool shouldMatch = spinCounter == 2 || spinCounter == 2;

    _rollSlotController.animateRandomly(
      topIndex: shouldMatch ? index : _random.nextInt(prizesList.length),
      centerIndex: shouldMatch ? index : _random.nextInt(prizesList.length),
      bottomIndex: shouldMatch ? index : _random.nextInt(prizesList.length)
    );
    _rollSlotController1.animateRandomly(
      topIndex: shouldMatch ? index : _random.nextInt(prizesList.length),
      centerIndex: shouldMatch ? index : _random.nextInt(prizesList.length),
      bottomIndex: shouldMatch ? index : _random.nextInt(prizesList.length)
    );
    _rollSlotController2.animateRandomly(
      topIndex: shouldMatch ? index : _random.nextInt(prizesList.length),
      centerIndex: shouldMatch ? index : _random.nextInt(prizesList.length),
      bottomIndex: shouldMatch ? index : _random.nextInt(prizesList.length)
    );

    Timer(Duration(seconds: 3), () {
      _rollSlotController.stop();
      _rollSlotController1.stop();
      _rollSlotController2.stop();
      Future.delayed( Duration(seconds: 3), () {
            _updateScore();
            });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: null,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color.fromARGB(255, 255, 235, 119)),
          iconSize: 30.0,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Container(
                    height: 200,
                    width: 400,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Image.asset("assets/images/Slot MachineNEW.gif"),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 80,
                    width: 250,
                    child: ScoreBoard(key: _scoreBoardKey),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        width: 5,
                        color: Color.fromARGB(255, 255, 235, 119),
                      ),
                    ),
                    height: 200,
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        RollSlotWidget(prizesList: prizesList, rollSlotController: _rollSlotController),
                        RollSlotWidget(prizesList: prizesList, rollSlotController: _rollSlotController1),
                        RollSlotWidget(prizesList: prizesList, rollSlotController: _rollSlotController2),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ElevatedButton(
        onPressed: _spinAllSlots,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 255, 235, 119),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        ),
        child: Text('SPIN', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
    );
  }
}

class RollSlotWidget extends StatelessWidget {
  final List<String> prizesList;
  final RollSlotController rollSlotController;

  const RollSlotWidget({Key? key, required this.prizesList, required this.rollSlotController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(
            child: RollSlot(
              itemExtend: 115,
              rollSlotController: rollSlotController,
              children: prizesList.map((e) => BuildItem(asset: e)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class BuildItem extends StatelessWidget {
  final String asset;

  const BuildItem({Key? key, required this.asset}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Color(0xff2f5d62).withOpacity(.2),
            offset: Offset(5, 5),
          ),
          BoxShadow(
            color: Color(0xff2f5d62).withOpacity(.2),
            offset: Offset(-5, -5),
          ),
        ],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xff2f5d62)),
      ),
      alignment: Alignment.center,
      child: SvgPicture.asset(asset, key: Key(asset)),
    );
  }
}
