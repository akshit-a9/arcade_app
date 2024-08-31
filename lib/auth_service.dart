import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register with email and password
  Future<User?> registerWithEmailAndPassword(String email, String password, String username) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      // Add user information to Firestore
      await _initializeUserInFirestore(userCredential.user!.uid, username, email);

      return userCredential.user;
    } catch (error) {
      print('Registration failed: $error');
      return null;
    }
  }

  // Login with email and password
  Future<User?> loginWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Fetch and return user data
      await _initializeUserInFirestore(userCredential.user!.uid, null, email);

      return userCredential.user;
    } catch (error) {
      print('Login failed: $error');
      return null;
    }
  }

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // User canceled the sign-in

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Initialize user data in Firestore
      await _initializeUserInFirestore(userCredential.user!.uid, googleUser.displayName ?? '', googleUser.email);

      return userCredential.user;
    } catch (error) {
      print('Sign in with Google failed: $error');
      return null;
    }
  }

  // Initialize user data in Firestore
  Future<void> _initializeUserInFirestore(String uid, String? username, String email) async {
    try {
      DocumentReference userDoc = _firestore.collection('users').doc(uid);
      DocumentSnapshot docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        // If the document doesn't exist, create it with initial values
        await userDoc.set({
          'username': username ?? 'Anonymous',  // If username is null, set a default
          'email': email,
          'coins': 1000,  // Default coins
          'points': 0,
        });
      } else {
        // If the document exists, update the user's information (if necessary)
        await userDoc.update({
          'username': username ?? docSnapshot['username'],
          'email': email,
        });
      }
    } catch (e) {
      print('Error initializing user in Firestore: $e');
    }
  }

  // Fetch user data from Firestore
  Future<Map<String, dynamic>?> fetchUserData(String uid) async {
    try {
      DocumentReference userDoc = _firestore.collection('users').doc(uid);
      DocumentSnapshot docSnapshot = await userDoc.get();

      if (docSnapshot.exists) {
        return docSnapshot.data() as Map<String, dynamic>;
      } else {
        print('User data does not exist');
        return null;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  // Sign out the user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await GoogleSignIn().signOut();
    } catch (e) {
      print('Sign out failed: $e');
    }
  }

  // Get the current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
