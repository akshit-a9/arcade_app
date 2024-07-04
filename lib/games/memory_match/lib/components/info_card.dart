import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

Widget info_card(String title, String info) {
  return Expanded(
    child: Container(
      margin: EdgeInsets.all(26.0),
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 26.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color.fromARGB(255, 255, 143, 0),
        border: Border.all(
                color: Color.fromARGB(255, 25, 43, 94),//Color.fromARGB(255, 5, 22, 68) ,
                width: 1,
              ),
              boxShadow: [
                const BoxShadow(
                          color: Color.fromARGB(255, 25, 43, 94),  
                          blurRadius: 10.0,
                          spreadRadius: 5.0,
                        ),
                      ], 
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 6.0,
          ),
          Text(
            info,
            style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 34.0, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}
