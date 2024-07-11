import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';
import 'games/spinwheel/lib/main.dart' as spinwheel;
import 'games/slot_game/lib/main.dart' as slot_game;
import 'games/memory_match/lib/main.dart' as memory_match;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GearUp Games',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VideoSplashScreen(),
    );
  }
}

class VideoSplashScreen extends StatefulWidget {
  @override
  _VideoSplashScreenState createState() => _VideoSplashScreenState();
}

class _VideoSplashScreenState extends State<VideoSplashScreen> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/splash_video.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller!.play();
        _controller!.setLooping(false);
        _controller!.addListener(checkVideo);
      });
  }

  void checkVideo() {
    if (_controller!.value.position == _controller!.value.duration) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => ArcadeHome(),
      ));
    }
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.black, // Set the background to black
          child: Center(
            child: _controller!.value.isInitialized
                ? AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            )
                : Container(),
          ),
        ),
      ),
    );
  }
}

class ArcadeHome extends StatefulWidget {
  @override
  _ArcadeHomeState createState() => _ArcadeHomeState();
}

class _ArcadeHomeState extends State<ArcadeHome> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    playMusic();
  }

  void playMusic() async {
    await _audioPlayer.setSource(AssetSource('music/background_music.mp3'));
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.setVolume(0.05);  // Sets the volume to 20%
    await _audioPlayer.resume();
  }

  void toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    _isMuted ? _audioPlayer.pause() : _audioPlayer.resume();
  }

  void navigateToGame(BuildContext context, Widget gameApp) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(0),  // Removes any default padding from the dialog
          child: Container(
            width: MediaQuery.of(context).size.width,  // Set width to fill the screen
            height: MediaQuery.of(context).size.height,  // Set height to fill the screen
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/splash_image.png'),
                fit: BoxFit.cover,  // Ensures the image covers the full container
              ),
            ),
          ),
        );
      },
    );
    await Future.delayed(Duration(seconds: 2));
    Navigator.of(context).pop(); // Close the image dialog
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => gameApp),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background_main.jpg"),
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
                  child: buildGameCarousel(context, [
                    buildGameButton(context, 'Spin&Win', 'assets/images/logo_1.png', spinwheel.MyApp()),
                    buildGameButton(context, 'GoldenSlots', 'assets/images/logo_2.png', slot_game.MyNewApp()),
                    buildGameButton(context, 'Match Master', 'assets/images/logo_3.png', memory_match.MyApp()),
                    buildGameButton(context, 'Drive Through', 'assets/images/logo_placeholder.png', null),
                  ]),
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
                      buildGameButton(context, 'Spin&Win', 'assets/images/logo_1.png', spinwheel.MyApp()),
                      buildGameButton(context, 'GoldenSlots', 'assets/images/logo_2.png', slot_game.MyNewApp()),
                      buildGameButton(context, 'Match Master', 'assets/images/logo_3.png', memory_match.MyApp()),
                      buildGameButton(context, 'Drive Through', 'assets/images/logo_placeholder.png', null),
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
          ],
        ),
      ),
    );
  }

  Widget buildGameCarousel(BuildContext context, List<Widget> gameButtons) {
    return Container(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: gameButtons.map((gameButton) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: gameButton,
        )).toList(),
      ),
    );
  }

  Widget buildGameButton(BuildContext context, String title, String imagePath, Widget? gameApp) {
    return GestureDetector(
      onTap: gameApp != null
          ? () => navigateToGame(context, gameApp)
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

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
