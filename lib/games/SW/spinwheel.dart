import 'dart:io';
import 'package:arcade_app/coins.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdHelper {
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3940256099942544/1033173712";
    } else if (Platform.isIOS) {
      return "ca-app-pub-3940256099942544/4411468910";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }
}

class SpinWheel extends StatefulWidget {
  const SpinWheel({Key? key}) : super(key: key);

  @override
  State<SpinWheel> createState() => _SpinWheelState();
}

class _SpinWheelState extends State<SpinWheel> {
  final selected = BehaviorSubject<int>();
  Map<String, dynamic> rewards = {};
  List<Map<String, dynamic>> items = [];
  String buttonText = "SPIN";
  bool isMuted = false;
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  int maxFailedLoadAttempts = 3;
  int totalPoints = 0;
  final _controller = ConfettiController(duration: Duration(seconds: 2));
  final player1 = AudioPlayer();
  final player2 = AudioPlayer();
  final player3 = AudioPlayer();
  int clickCount = 0;

  @override
  void initState() {
    super.initState();
    _createInterstitialAd();
    _fetchRewards();
    _resetPoints();
    player1.setSource(AssetSource('sounds/wheel2.mp3'));
    player2.setSource(AssetSource('sounds/win.mp3'));
    player3.setSource(AssetSource('sounds/lose.mp3'));
    _updateVolume();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _updateVolume() {
    double volume = isMuted ? 0.0 : 1.0;
    player1.setVolume(volume);
    player2.setVolume(volume);
    player3.setVolume(volume);
  }

  void _updatePoints(int points) async {
    totalPoints += points;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalPoints', totalPoints);
    setState(() {});
  }

  void _resetPoints() async {
    totalPoints = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalPoints', totalPoints);
    setState(() {});
  }

  Future<void> _fetchRewards() async {
    List<Map<String, dynamic>> predefinedRewards = [
      {"name": "10 Points", "value": 10},
      {"name": "20 Points", "value": 20},
      {"name": "30 Points", "value": 30},
      {"name": "40 Points", "value": 40},
      {"name": "50 Points", "value": 50},
      {"name": "100 Points", "value": 100},
      {"name": "200 Points", "value": 200},
      {"name": "300 Points", "value": 300},
      {"name": "400 Points", "value": 400},
      {"name": "500 Points", "value": 500},
    ];

    items = (predefinedRewards..shuffle()).take(5).toList();

    setState(() {});
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          print('$ad loaded');
          _interstitialAd = ad;
          _numInterstitialLoadAttempts = 0;
          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error.');
          _numInterstitialLoadAttempts += 1;
          _interstitialAd = null;
          if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
            _createInterstitialAd();
          }
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
        setState(() {
          buttonText = "SPIN";
        });
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
        setState(() {
          buttonText = 'SPIN';
        });
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  void _handleButtonClick() async {
    if (clickCount == 0) {
      _spinWheel();
    } else {
      bool confirmed = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Spin the Wheel'),
          content: Text('It will cost 30 coins to spin the wheel. Do you want to proceed?'),
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
        if (hasEnoughCoins) {
          _spinWheel();
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Not Enough Coins'),
              content: Text('You do not have enough coins to spin the wheel.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  void _spinWheel() {
    setState(() {
      player1.play(AssetSource('sounds/wheel2.mp3'));
      selected.add(Fortune.randomInt(0, items.length));
      clickCount++;
    });
  }

  List<Color> _colors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
  ];

  Color _getColor(int index) {
    return _colors[index % _colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: Text("Total Points: $totalPoints", style: TextStyle(color: Colors.yellow)),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Color.fromARGB(255, 255, 235, 119)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up, color: Color.fromARGB(255, 255, 219, 0)),
                iconSize: 30.0,
                onPressed: () {
                  setState(() {
                    isMuted = !isMuted;
                    _updateVolume();
                  });
                },
              ),
            ],
          ),
          body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 0.0),
                  child: Image.asset(
                    'assets/images/Spinwheel.gif',
                    height: 100,
                    width: 320,
                  ),
                ),
                if (items.isEmpty)
                  CircularProgressIndicator()
                else
                  if (items.length > 1)
                    SizedBox(
                      height: 300,
                      child: FortuneWheel(
                        selected: selected.stream,
                        animateFirst: false,
                        items: [
                          for (int i = 0; i < items.length; i++) ...<
                              FortuneItem>{
                            FortuneItem(
                              style: FortuneItemStyle(
                                color: _getColor(i),
                                borderColor: Colors.black,
                                borderWidth: 3,
                              ),
                              child: Text(
                                items[i]['name'],
                                style: TextStyle(fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            ),
                          },
                        ],
                        onAnimationEnd: () {
                          player1.pause();
                          setState(() {
                            rewards = items[selected.value];
                          });
                          if (rewards['value'] > 0) {
                            _updatePoints(rewards['value']);
                            _controller.play();
                            player2.play(AssetSource('sounds/win.mp3'));
                            CoinManager.addPoints(rewards['value']).then((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("You just won ${rewards['name']}! Total points now updated."),
                                  backgroundColor: Colors.blueAccent,
                                ),
                              );
                            });
                          } else {
                            player3.play(AssetSource('sounds/lose.mp3'));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Better luck next time!"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                ),
                                backgroundColor: Colors.deepPurpleAccent,
                                contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
                                content: Container(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(height: 10),
                                      Text(
                                        rewards['name'] ?? "No Name",
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Close", style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        indicators: <FortuneIndicator>[
                          FortuneIndicator(
                            alignment: Alignment.center,
                            child: RoundIndicator(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: _handleButtonClick,
                  child: Container(
                    height: 50,
                    width: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.pink, Colors.orange],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 3,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        buttonText,
                        style: TextStyle(color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        ConfettiWidget(
          confettiController: _controller,
          blastDirectionality: BlastDirectionality.explosive,
          numberOfParticles: 100,
        ),
      ],
    );
  }
}

class RoundIndicator extends StatelessWidget {
  final Color color;

  const RoundIndicator({Key? key, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white12,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '▲',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
