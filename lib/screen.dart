import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'games/SM/roll_slot.dart';
import 'games/SM/roll_slot_controller.dart';
import 'scoreboard.dart';
import 'package:audioplayers/audioplayers.dart';
import 'coins.dart'; // Assuming coins.dart handles coin management
import 'main.dart' as maine;

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

class Slot extends StatelessWidget {
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
      routes: {
        'ArcadeHome': (context) => maine.ArcadeHome(),
      },
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
  bool isMuted = false;
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
  final _slotspinAudioplayer = AudioPlayer();

  int spinCounter = 0;
  Random _random = Random();

  @override
  void initState() {
    super.initState();
    _slotspinAudioplayer.setSourceUrl('sounds/slotspin.mp3');
    _updateVolume();
  }

  void _updateVolume() {
    double volume = isMuted ? 0.0 : 1.0;
    _slotspinAudioplayer.setVolume(volume);
  }

  void _updateScore() {
    final centerImages = [
      prizesList[_rollSlotController.centerIndex],
      prizesList[_rollSlotController1.centerIndex],
      prizesList[_rollSlotController2.centerIndex],
    ];
    _scoreBoardKey.currentState?.updateScore(centerImages);
    if (spinCounter == 7) {
      spinCounter = 0; // Reset the counter after the specific spins
    } else {
      spinCounter++;
    }
  }

  void _spinAllSlots() async {
    if (spinCounter == 0) {
      _performSpin();
    } else {
      bool confirmed = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Spin the Slot Machine'),
          content: Text('It will cost 30 coins to spin the slot machine. Do you want to proceed?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Proceed'),
            ),
          ],
        ),
      );

      if (confirmed) {
        bool hasEnoughCoins = await CoinManager.deductCoins(30);
        if (!hasEnoughCoins) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Not Enough Coins'),
              content: Text('You do not have enough coins to spin the slot machine.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
          );
          return;
        }
        _performSpin();
      }
    }
  }

  void _performSpin() {
    _slotspinAudioplayer.seek(Duration.zero);
    _slotspinAudioplayer.play(AssetSource('sounds/slotspin.mp3'));
    int index = _random.nextInt(prizesList.length);
    bool shouldMatch = spinCounter == 7; // every 7th spin is a sure shot reward

    _rollSlotController.animateRandomly(
      topIndex: shouldMatch ? index : _random.nextInt(prizesList.length),
      centerIndex: shouldMatch ? index : _random.nextInt(prizesList.length),
      bottomIndex: shouldMatch ? index : _random.nextInt(prizesList.length),
    );
    _rollSlotController1.animateRandomly(
      topIndex: shouldMatch ? index : _random.nextInt(prizesList.length),
      centerIndex: shouldMatch ? index : _random.nextInt(prizesList.length),
      bottomIndex: shouldMatch ? index : _random.nextInt(prizesList.length),
    );
    _rollSlotController2.animateRandomly(
      topIndex: shouldMatch ? index : _random.nextInt(prizesList.length),
      centerIndex: shouldMatch ? index : _random.nextInt(prizesList.length),
      bottomIndex: shouldMatch ? index : _random.nextInt(prizesList.length),
    );

    Timer(Duration(seconds: 3), () {
      _rollSlotController.stop();
      _rollSlotController1.stop();
      _rollSlotController2.stop();
      Future.delayed(Duration(seconds: 3), () {
        _updateScore();
      });
    });
    spinCounter++;
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
          onPressed: () {
            // This will pop until 'ArcadeHome' is found; if not found, clear all and push it
            Navigator.of(context).popUntil((route) => false); // Clears the entire stack
            Navigator.pushNamed(context, 'ArcadeHome'); // Pushes ArcadeHome as the only route
          },
        ),
        actions: [
          IconButton(
            icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up, color: Colors.white),
            onPressed: () {
              setState(() {
                isMuted = !isMuted;
                _updateVolume();  // Update volume each time the mute state changes
              });
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 0, bottom: 50),
              child: Column(
                children: [
                  Container(
                    height: 200,
                    width: 400,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Image.asset("assets/images/SlotMachineTemp.gif"),
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: ElevatedButton(
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
