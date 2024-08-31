import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CoinManager {
  static const String _coinKey = 'coins';
  static const String _pointsKey = 'points';
  static const int _initialCoins = 1000;
  static const int _coinCostPerGame = 50;
  static const int _pointsPerCoin = 10; // Define how many points are needed for one coin

  // Initialize the user's coins and points, checking Firestore first
  static Future<void> initializeUserCoins() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is logged in, sync with Firestore
      await initializeUserCoinsWithFirestore(user.uid);
    } else {
      // No user logged in, initialize with default values
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool hasInitialized = prefs.getBool('initialized') ?? false;
      if (!hasInitialized) {
        await prefs.setInt(_coinKey, _initialCoins);
        await prefs.setInt(_pointsKey, 0);
        await prefs.setBool('initialized', true);
      }
    }
  }

  static Future<void> initializeUserCoinsWithFirestore(String uid) async {
    DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(uid);

    DocumentSnapshot docSnapshot = await userDoc.get();
    if (!docSnapshot.exists) {
      // If the document doesn't exist, create it with initial values
      await userDoc.set({
        _coinKey: _initialCoins,
        _pointsKey: 0,
      });
    }

    // Sync the local storage with Firestore values
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int firestoreCoins = (docSnapshot.data() as Map<String, dynamic>? ?? {})[_coinKey] ?? _initialCoins;
    int firestorePoints = (docSnapshot.data() as Map<String, dynamic>? ?? {})[_pointsKey] ?? 0;

    await prefs.setInt(_coinKey, firestoreCoins);
    await prefs.setInt(_pointsKey, firestorePoints);
  }

  static Future<int> getCoinBalance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_coinKey) ?? _initialCoins;
  }

  static Future<int> getPointsBalance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_pointsKey) ?? 0;
  }

  static Future<bool> deductCoinsForGame() async {
    return await deductCoins(_coinCostPerGame);
  }

  static Future<bool> deductCoins(int amount) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentCoins = prefs.getInt(_coinKey) ?? _initialCoins;
    if (currentCoins >= amount) {
      int newBalance = currentCoins - amount;
      await prefs.setInt(_coinKey, newBalance);

      // Update Firestore if the user is logged in
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          _coinKey: newBalance,
        });
      }

      return true;
    }
    return false;
  }

  static Future<void> addCoins(int coins) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentCoins = prefs.getInt(_coinKey) ?? _initialCoins;
    int newBalance = currentCoins + coins;
    await prefs.setInt(_coinKey, newBalance);

    // Update Firestore if the user is logged in
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        _coinKey: newBalance,
      });
    }
  }

  static Future<void> addPoints(int points) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentPoints = prefs.getInt(_pointsKey) ?? 0;
    int newPoints = currentPoints + points;
    await prefs.setInt(_pointsKey, newPoints);

    // Update Firestore if the user is logged in
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        _pointsKey: newPoints,
      });
    }

    print("Points updated to: $newPoints"); // Debug statement
  }

  static Future<bool> convertPointsToCoins(int pointsToDeduct, int coinsToAdd) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentPoints = prefs.getInt(_pointsKey) ?? 0;
    int currentCoins = prefs.getInt(_coinKey) ?? _initialCoins;

    if (currentPoints >= pointsToDeduct) {
      int newPoints = currentPoints - pointsToDeduct;
      int newCoins = currentCoins + coinsToAdd;

      await prefs.setInt(_pointsKey, newPoints);
      await prefs.setInt(_coinKey, newCoins);

      // Update Firestore if the user is logged in
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          _pointsKey: newPoints,
          _coinKey: newCoins,
        });
      }

      print("Converted $pointsToDeduct points to $coinsToAdd coins.");
      return true;
    } else {
      print("Not enough points to convert to coins.");
      return false;
    }
  }
}
