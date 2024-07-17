import 'package:flutter/material.dart';
import 'dart:math';
class Game {
  final Color hiddenCard = Color.fromARGB(255, 255, 219, 0);
  List<Color>? gameColors;
  List<String>? gameImg;
  // List<Color> cards = [
   // Colors.green,
   // Colors.yellow,
   // Colors.yellow,
   // Colors.green,
   // Colors.blue,
   // Colors.blue
  //];
  final String hiddenCardpath = "assets/images/hidden.png";
  List<String> cards_list = [
    "assets/images/stop.png",
    "assets/images/stop.png",
    "assets/images/right.png",
    "assets/images/right.png",
    "assets/images/no_u_turn.png",
    "assets/images/no_u_turn.png",
    "assets/images/no_parking.png",
    "assets/images/no_parking.png",
    "assets/images/give_way.png",
    "assets/images/give_way.png",
    "assets/images/left_turn_prohibited.png",
    "assets/images/left_turn_prohibited.png",
    "assets/images/right_turn_prohibited.png",
    "assets/images/right_turn_prohibited.png",
    "assets/images/left.png",
    "assets/images/left.png",
  ];
  
  final int cardCount = 16;
  List<Map<int, String>> matchCheck = [];

  //methods
  void initGame() {
    gameColors = List.generate(cardCount, (index) => hiddenCard);
    gameImg = List.generate(cardCount, (index) => hiddenCardpath);
    shuffleCards();
  }


  void shuffleCards() {
    cards_list.shuffle(Random());
  }

}
