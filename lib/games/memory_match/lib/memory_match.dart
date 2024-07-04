import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:memory_match/ad_mod_service.dart';
import 'package:memory_match/components/info_card.dart';
import 'package:memory_match/utils/game_utils.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //setting text style
  TextStyle whiteText = TextStyle(color: Colors.white);
  bool hideTest = false;
  Game _game = Game();
  final _clickAudioplayer = AudioPlayer();
  final _noMatchAudioplayer = AudioPlayer();
  final _winningAudioplayer = AudioPlayer();
  final _completeAudioplayer = AudioPlayer();
  late ConfettiController _confettiController;

  int tapCount = 0; 
  bool isMuted = false; // Variable to track mute state

  //game stats
  int tries = 0;
  int score = 0;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _game.initGame();
    _clickAudioplayer.setSourceUrl('sounds/click.mp3'); 
    _noMatchAudioplayer.setSourceUrl('sounds/NO!.mp3');
    _winningAudioplayer.setSourceUrl('sounds/positive game win.mp3');
    _completeAudioplayer..setSourceUrl('sounds/level-passed.mp3');  // Preload the sound
    _noMatchAudioplayer.setVolume(0.5);
    _confettiController = ConfettiController();
    _createInterstitialAd();
  }

void _createInterstitialAd(){
  InterstitialAd.load(
    adUnitId: AdMobService.interstitialAdUnitId!,
    request: const AdRequest(),
    adLoadCallback: InterstitialAdLoadCallback(
      onAdLoaded: (ad) => _interstitialAd = ad,
      onAdFailedToLoad: (LoadAdError error) => _interstitialAd = null,
      ),
  );
}

  @override
  void dispose() {
    _confettiController.dispose(); // Dispose ConfettiController
    super.dispose();
  }

  void resetGame() {
    setState(() {
      tries = 0;
      score = 0;
      _game.initGame();
      _game.shuffleCards();
    });
  }

  void showMatchDialog(String imagePath) {
    if (!isMuted) {
      _winningAudioplayer.seek(Duration.zero);
      _winningAudioplayer.play(AssetSource('sounds/positive game win.mp3'));
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 255, 219, 0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(imagePath),
              SizedBox(height: 10),
              Text(
                imagePath.split('/').last.split('.').first,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ), // Extracting the image name
            ],
          ),
        );
      },
    );

    Future.delayed( Duration(seconds: 3), () {
      Navigator.of(context).pop();
    });
  }

  void showWinnerDialog() {
    Future.delayed(Duration(seconds: 4), () {
      if (!isMuted) {
        _winningAudioplayer.seek(Duration.zero);
        _winningAudioplayer.play(AssetSource('sounds/level-passed.mp3'));
      }
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(0), // Remove default padding
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/yay.webp"),
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                ],
                numberOfParticles: 100, // Increase intensity
                gravity: 1.0, // Adjust gravity effect
                emissionFrequency: 1.0, // Adjust emission frequency
                maxBlastForce: 100, 
              ),
              ],
            ),
          );
        },
      );

       _confettiController.play();

      Future.delayed(Duration(seconds: 3), () {
        Navigator.of(context).pop();
        _confettiController.stop();
        _showInterstitialAd();
        resetGame(); // Reset the game after showing the dialog
      });
    });
  }

  void _showInterstitialAd(){
    if(_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _createInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _createInterstitialAd();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 38, 53, 93), //background colour
      appBar: AppBar(
        title: null,
        backgroundColor: Color.fromARGB(255, 38, 53, 93),
         leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color.fromARGB(255, 255, 219, 0)),
          iconSize: 30.0,
          onPressed: () {
            // Add your navigation logic here
            Navigator.pop(context); // Example: Return to the previous screen
            // Navigator.pushNamed(context, '/home'); // Example: Navigate to the home screen if using named routes
          },
        ),
        actions: [
          IconButton(
            icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up  , color: Color.fromARGB(255, 255, 219, 0)),
            iconSize: 30.0,
            onPressed: () {
              setState(() {
                isMuted = !isMuted;
              });
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(child: Image.asset("assets/images/logo.gif")),
          Container(
            height: 160,
            width: 500,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                info_card("Tries", "$tries"),
                info_card("Score", "$score"),
              ],
            ),
          ),
          Container(
            height: 360,
            width: 360,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Color.fromARGB(255, 25, 43, 94),
              border: Border.all(
                color: Color.fromARGB(255, 5, 22, 68), // Color.fromARGB(255, 5, 22, 68) ,
                width: 1,
              ),
              boxShadow: [
                const BoxShadow(
                  color: Color.fromARGB(255, 5, 22, 68),
                  blurRadius: 10.0,
                  spreadRadius: 2.0,
                ),
              ],
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.width,
              width: MediaQuery.of(context).size.width,
              child: GridView.builder(
                itemCount: _game.gameImg!.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                ),
                padding: EdgeInsets.all(16.0),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      tapCount++;
                      if(tapCount % 2 != 0 && !isMuted){
                        // Play click sound
                         _clickAudioplayer.seek(Duration.zero);
                        _clickAudioplayer.play(AssetSource('sounds/click.mp3'));
                      }

                      // Check if the card is already revealed or matched
                      if (_game.gameImg![index] == _game.hiddenCardpath && _game.matchCheck.length < 2) {
                        setState(() {
                          _game.gameImg![index] = _game.cards_list[index];
                          _game.matchCheck.add({index: _game.cards_list[index]});
                          tries++; // Increment tries counter on every valid tap
                        });

                        if (_game.matchCheck.length == 2) {
                          // Check if both selected cards are the same
                          if (_game.matchCheck[0].values.first == _game.matchCheck[1].values.first) {
                            // Cards are a match
                            score += 100;
                            showMatchDialog(_game.matchCheck[0].values.first);
                            _game.matchCheck.clear(); // Clear match check for the next pair

                            // Check if the game is won
                            if (score == 800) {
                              showWinnerDialog();
                            }
                          } else {
                            // Cards do not match, hide them after a delay
                            Future.delayed(Duration(milliseconds: 500), () {
                              setState(() {
                                _game.gameImg![_game.matchCheck[0].keys.first] = _game.hiddenCardpath;
                                _game.gameImg![_game.matchCheck[1].keys.first] = _game.hiddenCardpath;
                                _game.matchCheck.clear(); // Clear match check for the next pair
                              });
                              if (!isMuted) {
                                _noMatchAudioplayer.seek(Duration.zero);
                                _noMatchAudioplayer.play(AssetSource('sounds/NO!.mp3'));
                              }
                            });
                          }
                        } else if (_game.matchCheck.length > 2) {
                          // This scenario should not occur; clear match check if more than 2 cards are somehow selected
                          _game.matchCheck.clear();
                        }
                      } else {
                        // Vibrate the phone if the card is already revealed
                        Vibration.vibrate(duration: 500);
                        if (!isMuted) {
                          _noMatchAudioplayer.seek(Duration.zero);
                          _noMatchAudioplayer.play(AssetSource('sounds/NO!.mp3'));
                        }
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: _game.hiddenCard, // Use hidden card color
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: Color.fromARGB(255, 255, 143, 0),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromARGB(255, 255, 143, 0),
                            spreadRadius: 2.0,
                          ),
                        ],
                        image: DecorationImage(
                          image: AssetImage(_game.gameImg![index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(
            height: 15.0,
          ),
          ElevatedButton(
            onPressed: resetGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 255, 143, 0),
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0), // Adjust padding for button size
              minimumSize: Size(150, 50), // Minimum size for the button // Pastel yellow button color
            ),
            child: Text(
              "Reset Game",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20), // White text color
            ),
          ),
          SizedBox(
            height: 15,
          )
        ],
      ),
    );
  }
}

