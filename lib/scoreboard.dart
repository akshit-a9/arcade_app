import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Required for Firestore access

class ScoreBoard extends StatefulWidget {
  const ScoreBoard({Key? key}) : super(key: key);

  @override
  ScoreBoardState createState() => ScoreBoardState();
}

class ScoreBoardState extends State<ScoreBoard> {
  int _score = 0;
  bool isMuted = false;
  final AudioPlayer _you_winAudioplayer = AudioPlayer();
  final AudioPlayer _failAudioplayer = AudioPlayer();

  Map<String, dynamic> rewards = {};
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    _fetchRewards();
    _you_winAudioplayer.setSourceUrl('sounds/you_win.mp3');
    _failAudioplayer.setSourceUrl('sounds/fail.mp3');
  }

  void resetScore() {
    setState(() {
      _score = 0; // Reset the score
    });
  }

  void _updateVolume() {
    double volume = isMuted ? 0.0 : 1.0;
    _you_winAudioplayer.setVolume(volume);
    _failAudioplayer.setVolume(volume);
  }

  Future<void> _fetchRewards() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('slot machine rewards').get();
      List<Map<String, dynamic>> fetchedItems = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          "name": data['name'] ?? "No Name",
          "value": data['value'] ?? 0,
          "image": data['image'] ?? "https://media.giphy.com/media/RAquh63pTB2PerLhud/giphy.gif?cid=790b7611j2jvza4jigug2tb539his7mp1nwrvnkq3lvpzrva&rid=giphy.gif&ct=s",
          "coupon": data['coupon'] ?? "No Coupon"
        };
      }).toList();

      setState(() {
        items = fetchedItems.isNotEmpty ? fetchedItems : [
          {"name": "Better Luck next time", "value": 0, "image": "https://media.giphy.com/media/RAquh63pTB2PerLhud/giphy.gif?cid=790b7611j2jvza4jigug2tb539his7mp1nwrvnkq3lvpzrva&rid=giphy.gif&ct=s", "coupon": "No Coupon"},
          {"name": "10 Points", "value": 10, "image":"https://www.freepnglogos.com/uploads/flipkart-logo-image-0.png", "coupon": "FLIPKART10"},
          {"name": "20 Points", "value": 20, "image":"https://www.freepnglogos.com/uploads/logo-myntra-png/myntra-vector-logo-0.png", "coupon": "MYNTRA20"},
        ];
      });
    } catch (e) {
      print('Failed to fetch rewards: $e');
      // Handle fetch error by using default values
      setState(() {
        items = [
          {"name": "Better Luck next time", "value": 0, "image": "https://media.giphy.com/media/RAquh63pTB2PerLhud/giphy.gif?cid=790b7611j2jvza4jigug2tb539his7mp1nwrvnkq3lvpzrva&rid=giphy.gif&ct=s", "coupon": "No Coupon"},
          {"name": "10 Points", "value": 10, "image":"https://www.freepnglogos.com/uploads/flipkart-logo-image-0.png", "coupon": "FLIPKART10"},
          {"name": "20 Points", "value": 20, "image":"https://www.freepnglogos.com/uploads/logo-myntra-png/myntra-vector-logo-0.png", "coupon": "MYNTRA20"},
        ];
      });
    }
  }

  void updateScore(List<String> images) {
    Map<String, int> imageCounts = {};
    for (String image in images) {
      imageCounts[image] = (imageCounts[image] ?? 0) + 1;
    }

    int points = 0;
    bool isWinner = false;
    String message;

    if (imageCounts.values.any((count) => count == 3)) {
      if (imageCounts.entries.any((entry) => entry.key == 'assets/images/777.svg' && entry.value == 3)) {
        points = 50;
        message = "Congratulations! You won 50 points!";
        isWinner = true;
      } else {
        points = 10;
        message = "Congratulations! You won 10 points!";
        isWinner = true;
      }
    } else {
      points = 0;
      message = "Better luck next time!";
      isWinner = false;
    }

    setState(() {
      _score += points;
      if (!isMuted) {
        if (isWinner) {
          _you_winAudioplayer.seek(Duration.zero);
          _you_winAudioplayer.play(AssetSource('sounds/you_win.mp3'));
        } else {
          _failAudioplayer.seek(Duration.zero);
          _failAudioplayer.play(AssetSource('sounds/fail.mp3'));
        }
      }
    });

    // Show alert dialog with results
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(isWinner ? "You Won!" : "Try Again!"),
            content: Text(message),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('OK')
              )
            ],
          );
        }
    );
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 50,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(100.0),
          topRight: Radius.circular(100.0),
        ),
        border: Border(
          top: BorderSide(width: 5.0, color: Color.fromARGB(255, 255, 235, 119)),
          left: BorderSide(width: 5.0, color: Color.fromARGB(255, 255, 235, 119)),
          right: BorderSide(width: 5.0, color: Color.fromARGB(255, 255, 235, 119)),
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 255, 217, 0),
            blurRadius: 20.0,
            spreadRadius: 5.0,
            blurStyle: BlurStyle.inner,
          ),
        ],
      ),
      child: Center(
        child: Text(
          'Score: $_score',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 235, 119),
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
