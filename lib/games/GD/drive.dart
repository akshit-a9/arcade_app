import 'package:flutter/material.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

class DriveControls extends StatefulWidget {
  final Function(double, double, double, Set<String>) onMoveButtonPressed;
  final Function(Function) onStopMovement;

  DriveControls({required this.onMoveButtonPressed, required this.onStopMovement});

  @override
  _DriveControlsState createState() => _DriveControlsState();
}

class _DriveControlsState extends State<DriveControls> {
  Set<String> pressedButtons = {};
  late Function(double, double, double, Set<String>) _onMoveButtonPressed;
  double currentRotation = 0;
  bool _isMoving = false;
  late AudioPlayer _engineaudioPlayer;
  late AudioPlayer _reverseaudioPlayer;

  @override
  void initState() {
    super.initState();
    _onMoveButtonPressed = widget.onMoveButtonPressed;
    _engineaudioPlayer = AudioPlayer();
    _reverseaudioPlayer = AudioPlayer();
    _loadAndPlayAudio();
    _engineaudioPlayer.setVolume(0.25);
    _reverseaudioPlayer.setVolume(0.25);

    widget.onStopMovement(_stopMovement);
  }

  void _loadAndPlayAudio() async {
    await _engineaudioPlayer.setSource(AssetSource('sounds/engine.mp3'));
    await _reverseaudioPlayer.setSource(AssetSource('sounds/reverse.mp3'));
  }

  void _startMoving() {
    if (_isMoving) return;

    _isMoving = true;
    _moveContinuously();
  }

  void _stopMovement() {
    setState(() {
      pressedButtons.clear();
      _isMoving = false;
    });
  }

  void _moveContinuously() {
    if (!_isMoving) return;

    double latOffset = 0;
    double lngOffset = 0;
    double rotation = currentRotation;

    if (pressedButtons.contains('left')) {
      rotation = (currentRotation - 2) % 360;
    }
    if (pressedButtons.contains('right')) {
      rotation = (currentRotation + 2) % 360;
    }

    currentRotation = rotation;

    if (pressedButtons.contains('up')) {
      final double rad = currentRotation * (pi / 180.0);
      latOffset += 0.000005 * cos(rad);
      lngOffset += 0.000005 * sin(rad);
    }
    if (pressedButtons.contains('down')) {
      final double rad = currentRotation * (pi / 180.0);
      latOffset -= 0.000005 * cos(rad);
      lngOffset -= 0.000005 * sin(rad);
    }

    _onMoveButtonPressed(latOffset, lngOffset, rotation, pressedButtons);

    Future.delayed(Duration(milliseconds: 50), _moveContinuously); // Increase update frequency
  }

  void _onButtonPress(String direction) {
    setState(() {
      pressedButtons.add(direction);
      if (direction == 'up') {
        _engineaudioPlayer.play(AssetSource('sounds/engine.mp3'));
      }
      if (direction == 'down') {
        _reverseaudioPlayer.play(AssetSource('sounds/reverse.mp3'));
      }
      _startMoving();
    });
  }

  void _onButtonRelease(String direction) {
    setState(() {
      pressedButtons.remove(direction);
      if (direction == 'up') {
        _engineaudioPlayer.stop();
      }
      if (direction == 'down') {
        _reverseaudioPlayer.stop();
      }
      if (pressedButtons.isEmpty) {
        _isMoving = false;
      }
    });
  }

  @override
  void dispose() {
    _engineaudioPlayer.dispose();
    _reverseaudioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTapDown: (_) => _onButtonPress('left'),
          onTapUp: (_) => _onButtonRelease('left'),
          child: Container(
             height: 60,
            width: 60,
            child: Image.asset("assets/images/gleft.png"),
          ),
        ),
        GestureDetector(
          onTapDown: (_) => _onButtonPress('right'),
          onTapUp: (_) => _onButtonRelease('right'),
          child: Container(
            height: 60,
            width: 60,
            child: Image.asset("assets/images/gright.png"),
          ),
        ),
        GestureDetector(
          onTapDown: (_) => _onButtonPress('down'),
          onTapUp: (_) => _onButtonRelease('down'),
          child: Container(
            height: 60,
            width: 60,
            child: Image.asset("assets/images/backward.png"),
          ),
        ),
        GestureDetector(
          onTapDown: (_) => _onButtonPress('up'),
          onTapUp: (_) => _onButtonRelease('up'),
          child:  Container(
            height: 100,
            width: 60,
              child: Image.asset("assets/images/forward.png"),
            ),
        ),
      ],
    );
  }
}
