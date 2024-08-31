import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class RadioPlayerWithImages extends StatefulWidget {
  @override
  _RadioPlayerWithImagesState createState() => _RadioPlayerWithImagesState();
}

class _RadioPlayerWithImagesState extends State<RadioPlayerWithImages> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<String> _imagePaths = [];
  PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;
  bool _isBuffering = false; // To track buffering state

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _loadImages();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    try {
      await _audioPlayer.setUrl("https://stream.zeno.fm/unljzfckvmwuv");
      _audioPlayer.play();
      _audioPlayer.playerStateStream.listen((state) {
        bool isCurrentlyBuffering = state.processingState == ProcessingState.buffering ||
            state.processingState == ProcessingState.loading;
        if (isCurrentlyBuffering != _isBuffering) {
          setState(() {
            _isBuffering = isCurrentlyBuffering;
          });
        }
      });
    } catch (e) {
      print('Error initializing the stream: $e');
    }
  }

  Future<void> _loadImages() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    final List<String> paths = manifestMap.keys
        .where((String key) => key.contains('assets/posters/'))
        .toList();

    setState(() {
      _imagePaths = paths;
    });
  }

  void _pauseMusic() {
    _audioPlayer.pause();
  }

  void _resumeMusic() {
    _audioPlayer.play();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      int nextPage = _currentPage < _imagePaths.length - 1 ? _currentPage + 1 : 0;
      _pageController.animateToPage(
        nextPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
      _currentPage = nextPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Amo Radio', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          if (_isBuffering)
            LinearProgressIndicator(),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _imagePaths.length,
              itemBuilder: (context, index) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    color: Colors.black,
                  ),
                  child: Image.asset(_imagePaths[index], fit: BoxFit.contain),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _pauseMusic,
            child: Text('Pause FM'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black,
            ),
          ),
          ElevatedButton(
            onPressed: _resumeMusic,
            child: Text('Resume FM'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
