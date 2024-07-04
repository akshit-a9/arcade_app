import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';

class AdMobService{
  static String? get interstitialAdUnitId {
  if (Platform.isAndroid){
    return "ca-app-pub-3940256099942544/1033173712";
  } else if (Platform.isIOS) {
      return "ca-app-pub-3940256099942544/4411468910";
    }else if (Platform.isWindows) {
      return "ca-app-pub-3940256099942544/4411468910";
    }
     else {
      throw UnsupportedError("Unsupported platform");
    }
}

 

}