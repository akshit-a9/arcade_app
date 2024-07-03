import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import this if you need access to the Assets class for the image constants

class ScoreBoard extends StatefulWidget {
  const ScoreBoard({Key? key}) : super(key: key);

  @override
  ScoreBoardState createState() => ScoreBoardState();
}

class ScoreBoardState extends State<ScoreBoard> {
  int _score = 0;
  

  Map<String, dynamic> rewards= {};
  List<Map<String, dynamic>> items = [];


  @override
  void initState() {
    super.initState();
    _fetchRewards();
  }


  Future<void> _fetchRewards() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Rewards').get();
      List<Map<String, dynamic>> fetchedItems = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          "name": data['name'] ?? "No Name",
          "value": data['value'] ?? 0,
          "image": data['image'] ?? "https://media.giphy.com/media/RAquh63pTB2PerLhud/giphy.gif?cid=790b7611j2jvza4jigug2tb539his7mp1nwrvnkq3lvpzrva&ep=v1_stickers_search&rid=giphy.gif&ct=s",
          "coupon": data['coupon'] ?? "No Coupon"
        };
      }).toList();

      if (fetchedItems.isEmpty) {
        fetchedItems = [
          {"name": "Better Luck next time", "value": 0, "image": "https://media.giphy.com/media/RAquh63pTB2PerLhud/giphy.gif?cid=790b7611j2jvza4jigug2tb539his7mp1nwrvnkq3lvpzrva&ep=v1_stickers_search&rid=giphy.gif&ct=s", "coupon": "No Coupon"},
          {"name": "10 Points", "value": 10, "image":"https://www.freepnglogos.com/images/flipkart-logo-39907.html", "coupon": "FLIPKART10"},
          {"name": "20 Points", "value": 20, "image":"https://www.freepnglogos.com/images/logo-myntra-41464.html", "coupon": "MYNTRA20"},
        ];
      }

      setState(() {
        items = fetchedItems;
      });
    } catch (e) {
      print('Failed to fetch rewards: $e');
      setState(() {
        items = [
          {"name": "Better Luck next time", "value": 0, "image": "https://media.giphy.com/media/RAquh63pTB2PerLhud/giphy.gif?cid=790b7611j2jvza4jigug2tb539his7mp1nwrvnkq3lvpzrva&ep=v1_stickers_search&rid=giphy.gif&ct=s", "coupon": "No Coupon"},
          {"name": "10 Points", "value": 10, "image":"https://www.freepnglogos.com/images/flipkart-logo-39907.html", "coupon": "FLIPKART10"},
          {"name": "20 Points", "value": 20, "image":"https://www.freepnglogos.com/images/logo-myntra-41464.html", "coupon": "MYNTRA20"},
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
    if (imageCounts.values.any((count) => count == 3)) {
      points = imageCounts.entries.any((entry) => entry.key == Assets.seventhIc && entry.value == 3) ? 20 : 10;
      print("Image match $points");
    } else {
      points = 0;
      print('no match');
    }

    setState(() {
      _score += points;
      // Map the score directly to the reward
      if (_score == 0) {
        rewards = items.firstWhere((item) => item['value'] == 0, /*orElse: () => {"name": "Better Luck next time", "value": 0, "image": "https://media.giphy.com/media/RAquh63pTB2PerLhud/giphy.gif?cid=790b7611j2jvza4jigug2tb539his7mp1nwrvnkq3lvpzrva&ep=v1_stickers_search&rid=giphy.gif&ct=s"}*/);
      } else if (_score == 10) {
        rewards = items.firstWhere((item) => item['value'] == 10,/* orElse: () => {"name": "10 Points (coupon not visible)", "value": 10, "image":"https://www.freepnglogos.com/images/flipkart-logo-39907.html"}*/);
      } else if (_score == 20) {
        rewards = items.firstWhere((item) => item['value'] == 20,/* orElse: () => {"name": "20 Points (coupon not visible)", "value": 20, "image":"https://www.freepnglogos.com/images/logo-myntra-41464.html"}*/);
      } else {
        rewards = {"name": "Better Luck next time", "value": 0, "image": "https://media.giphy.com/media/RAquh63pTB2PerLhud/giphy.gif?cid=790b7611j2jvza4jigug2tb539his7mp1nwrvnkq3lvpzrva&ep=v1_stickers_search&rid=giphy.gif&ct=s"};
      }
    });

    print("Updated score: $_score. Reward: ${rewards['name']}, Value: ${rewards['value']}");

    if (rewards['value'] == 0 || rewards['name'].toLowerCase().contains('better luck next time')) {
      print('better luck next time: $_score');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Better luck next time!"),
          backgroundColor: Colors.red,
        ),
      );
    } else if (_score == rewards['value']) {
      print('wow you won: $_score');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("You just won point worth ${rewards['value']}!"),
          backgroundColor: Colors.green,
        ),
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_score == 0)
                Image.network(
                  rewards['image'],
                  width: 100,
                  height: 100,
                  errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                    return Image.network(
                      "https://media.giphy.com/media/RAquh63pTB2PerLhud/giphy.gif?cid=790b7611j2jvza4jigug2tb539his7mp1nwrvnkq3lvpzrva&ep=v1_stickers_search&rid=giphy.gif&ct=s",
                      width: 100,
                      height: 100,
                    );
                  },
                ),
                
              SizedBox(height: 10),

              Text(rewards['name'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (_score != 0) ...[
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Coupon: ${rewards['coupon']}",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: rewards['coupon']));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Coupon copied to clipboard!"),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _score = 0;            //_score = 0;  to reset score to 0 after every spin
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
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
            blurRadius:20.0,
            spreadRadius: 5.0,
            blurStyle: BlurStyle.inner,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
         /* Image.asset("assets/images/icon.png"),*/
         /* Text(
            'Spin',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ), 
          Text(
            '$_score',
            style: TextStyle(
              color: Color.fromARGB(255, 255, 235, 119),
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),*/
        ],
      ),
    );
  }
}
