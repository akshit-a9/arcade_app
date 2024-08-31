import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'auth_service.dart';
import 'firebase_options.dart';
import 'coins.dart';
import 'screen.dart' as slot_game;
import 'games/SW/spinwheel.dart' as spinwheel;
import 'memory_match.dart' as memory_match;
import 'games/GD/main.dart' as google_driving;
import 'games/fm.dart' as fm;
import 'shop.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GearUp Games',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
        textTheme: TextTheme(
          headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          labelLarge: TextStyle(color: Colors.white),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blueAccent,
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      home: AuthPage(), // Start with the authentication page
      routes: {'/arcade_home': (context) => ArcadeHome()},
    );
  }
}

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final AuthService _authService = AuthService();
  bool _isLogin = true;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _username = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Welcome to GearUp Games!', style: Theme.of(context).textTheme.headlineMedium),
                SizedBox(height: 20),
                if (!_isLogin)
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(color: Colors.grey[300]),
                    ),
                    style: TextStyle(color: Colors.grey[300]),
                    validator: (val) => val!.isEmpty ? 'Enter a username' : null,
                    onChanged: (val) => setState(() => _username = val),
                  ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.grey[300]),
                  ),
                  style: TextStyle(color: Colors.grey[300]),
                  validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                  onChanged: (val) => setState(() => _email = val),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.grey[300]),
                  ),
                  style: TextStyle(color: Colors.grey[300]),
                  validator: (val) => val!.length < 6 ? 'Enter a password 6+ chars long' : null,
                  obscureText: true,
                  onChanged: (val) => setState(() => _password = val),
                ),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isLoading = true;
                      });

                      User? user;
                      if (_isLogin) {
                        // Log in the user
                        user = await _authService.loginWithEmailAndPassword(_email, _password);
                      } else {
                        // Register the user
                        user = await _authService.registerWithEmailAndPassword(_email, _password, _username);
                      }

                      if (user != null) {
                        await handleUserSignIn(user);
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ArcadeHome()));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isLogin ? 'Login failed' : 'Registration failed')));
                      }

                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                  child: Text(_isLogin ? 'Login' : 'Sign Up'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    textStyle: TextStyle(fontSize: 18),
                    backgroundColor: Colors.blueAccent, // Updated from primary to backgroundColor
                  ),
                ),
                TextButton(
                  child: Text(_isLogin ? 'Create an account' : 'Already have an account? Log in'),
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white70, // Updated from primary to foregroundColor
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    // Skip sign-in, proceed as guest
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ArcadeHome()));
                  },
                  child: Text('Continue as Guest'),
                  style: TextButton.styleFrom(foregroundColor: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> handleUserSignIn(User user) async {
    Map<String, dynamic>? userData = await _authService.fetchUserData(user.uid);
    if (userData != null) {
      print('User data fetched successfully');
      print('Coins: ${userData['coins']}');
      print('Points: ${userData['points']}');
      // You can now use this data to update your UI or application state
    } else {
      print('No user data found');
    }
  }
}

class ArcadeHome extends StatefulWidget {
  @override
  _ArcadeHomeState createState() => _ArcadeHomeState();
}

class _ArcadeHomeState extends State<ArcadeHome> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMuted = false;
  int _coins = 1000;
  int _points = 0;
  Timer? _timer;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    updateBalances();
    startBalanceUpdater();
  }

  void toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    _isMuted ? _audioPlayer.pause() : _audioPlayer.resume();
  }

  void showInstructions(BuildContext context, String gameTitle, String instructions, Widget gameApp) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(gameTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Cost: 50 Coins'),
            SizedBox(height: 10),
            Text(instructions),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              navigateToGame(context, gameApp);
            },
            child: Text('Play'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void navigateToGame(BuildContext context, Widget gameApp) async {
    bool hasEnoughCoins = await CoinManager.deductCoinsForGame();
    if (!hasEnoughCoins) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Not Enough Coins'),
          content: Text('You do not have enough coins to play this game. Please buy more coins.'),
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
    // Continue with game navigation if there are enough coins
    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => gameApp));
    updateBalances(); // Update balances to reflect coin deduction
  }

  void updateBalances() async {
    _coins = await CoinManager.getCoinBalance();
    _points = await CoinManager.getPointsBalance();
    setState(() {});
  }

  void startBalanceUpdater() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      updateBalances();
    });
  }

  void signOut() async {
    await _authService.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => AuthPage()));
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exit Game'),
        content: Text('Are you sure you want to exit?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: Text('Yes'),
          ),
        ],
      ),
    ) ??
        false;
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/BM.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              CustomScrollView(
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 50),
                        Center(
                          child: Text(
                            'Arcade',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Flexible(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/Rupee.png',
                                    width: 40,
                                    height: 40,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.error, color: Colors.red, size: 40); // Handle error
                                    },
                                  ),
                                  SizedBox(width: 10), // Space between icon and text
                                  Flexible(
                                    child: Text(
                                      '$_coins',
                                      style: TextStyle(color: Colors.white, fontSize: 24),
                                      overflow: TextOverflow.ellipsis, // Handle text overflow
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => ShopCoins())),
                                    child: Image.asset(
                                      'assets/images/money_bag.png',
                                      width: 80,  // Adjust width as needed
                                      height: 80, // Adjust height as needed
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(Icons.error, color: Colors.red, size: 40); // Handle error
                                      },
                                    ),
                                  ),
                                  Text(
                                    'Shop',
                                    style: TextStyle(color: Colors.white, fontSize: 18), // Adjust font size as needed
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/coin.png',
                                    width: 40,
                                    height: 40,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.error, color: Colors.red, size: 40); // Handle error
                                    },
                                  ),
                                  SizedBox(width: 10), // Space between icon and text
                                  Flexible(
                                    child: Text(
                                      '$_points',
                                      style: TextStyle(color: Colors.white, fontSize: 24),
                                      overflow: TextOverflow.ellipsis, // Handle text overflow
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.all(16.0),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'Featured Games',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildGameButton(context, 'GoldenSlots', 'assets/images/logo_2.png', 'Match symbols to win big!', slot_game.Slot()),
                          SizedBox(width: 15),
                          buildGameButton(context, 'DriveQuest', 'assets/images/logo_placeholder.png', 'Drive through obstacles to reach the finish line!', google_driving.MyApp()),
                          SizedBox(width: 15),
                          buildGameButton(context, 'Amo Radio', 'assets/images/fm.png', 'Let us get the FM started and set the mood just right', fm.RadioPlayerWithImages()),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.all(16.0),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'All Games',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(8.0),
                    sliver: SliverGrid.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      children: [
                        buildGameButton(context, 'Spin&Win', 'assets/images/logo_1.png', 'Spin the wheel to win prizes!', spinwheel.SpinWheel()),
                        buildGameButton(context, 'GoldenSlots', 'assets/images/logo_2.png', 'Match symbols to win big!', slot_game.Slot()),
                        buildGameButton(context, 'Match Master', 'assets/images/logo_3.png', 'Match cards to win points!', memory_match.HomeScreen()),
                        buildGameButton(context, 'DriveQuest', 'assets/images/logo_placeholder.png', 'Drive through obstacles to reach the finish line!', google_driving.MyApp()),
                        buildGameButton(context, 'Amo Radio', 'assets/images/fm.png', '', fm.RadioPlayerWithImages()),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 40,
                right: 10,
                child: IconButton(
                  icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up),
                  color: Colors.white,
                  onPressed: toggleMute,
                  iconSize: 30,
                ),
              ),
              Positioned(
                top: 40,
                left: 10,
                child: IconButton(
                  icon: Icon(Icons.logout),
                  color: Colors.white,
                  onPressed: signOut,
                  iconSize: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildGameButton(BuildContext context, String title, String imagePath, String instructions, Widget? gameApp) {
    return GestureDetector(
      onTap: gameApp != null
          ? () => showInstructions(context, title, instructions, gameApp)
          : null,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Image.asset(imagePath, width: 100, height: 100),
          ),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
