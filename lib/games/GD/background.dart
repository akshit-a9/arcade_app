import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import '../../coins.dart';
import 'navigation/routes.dart';
import 'pointer.dart';
import 'drive.dart';
import 'dart:math';
import 'dart:async';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  LocationData? currentLocation;
  LatLng? startLatLng;
  LatLng? destinationLatLng;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  PointerManager? pointerManager;
  List<LatLng> _path = [];
  Timer? _timer;
  String? _totalDistance;
  bool _routeCreated = false;
  LatLng? _lastValidPosition;
  double _distanceTravelled = 0;
  int _score = 0;
  int points = 0;
  Function? stopMovement;
  MapType _currentMapType = MapType.satellite;


  static const LatLng _initialPosition = LatLng(37.7749, -122.4194);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (currentLocation != null) {
      mapController?.animateCamera(CameraUpdate.newLatLng(
        LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
      ));
    }
    // Delay the navigation to the search window by 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      _navigateToRoutesScreen();
    });
  }

  @override
  void initState() {
    super.initState();
    _requestPermissionAndLocation();
  }

  void _requestPermissionAndLocation() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }

    if (await Permission.location.isGranted) {
      await _getCurrentLocation();
    } else {
      print("Location permission denied");
    }
  }

  Future<void> _getCurrentLocation() async {
    Location location = Location();
    try {
      currentLocation = await location.getLocation();
      await _initializePointer();

      setState(() {
        if (currentLocation != null && mapController != null) {
          mapController?.animateCamera(CameraUpdate.newLatLng(
            LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
          ));
        }
      });

      location.onLocationChanged.listen((LocationData loc) {
        setState(() {
          currentLocation = loc;
        });
      });
    } catch (e) {
      print("Failed to get location: $e");
    }
  }

  Future<void> _initializePointer() async {
    final icon = await BitmapDescriptor.asset(
      ImageConfiguration(size: Size(20, 30)),
      'assets/images/cars.png',
    );

    setState(() {
      pointerManager = PointerManager(
        Pointer(
          position: currentLocation != null
              ? LatLng(currentLocation!.latitude!, currentLocation!.longitude!)
              : _initialPosition,
          rotation: 0,
          icon: icon,
        ),
      );
    });

    _updatePointerMarker();
  }

  void _updatePointerMarker() {
    if (pointerManager != null) {
      setState(() {
        _markers.removeWhere((marker) => marker.markerId == MarkerId('pointer'));
        _markers.add(Marker(
          markerId: MarkerId('pointer'),
          position: pointerManager!.pointer.position,
          icon: pointerManager!.pointer.icon,
          rotation: pointerManager!.pointer.rotation,
        ));
      });
    }
  }

  Future<LatLng?> getNearestRoad(LatLng location) async {
    const String ROADS_API_KEY = "AIzaSyCRgj3hKMal8dn-XLU9gZDHtBY010lvwzI";
    String baseURL = 'https://roads.googleapis.com/v1/nearestRoads';
    String request = '$baseURL?points=${location.latitude},${location.longitude}&key=$ROADS_API_KEY';
    var response = await http.get(Uri.parse(request));
    var data = json.decode(response.body);

    if (data['snappedPoints'] != null && data['snappedPoints'].isNotEmpty) {
      var snappedLocation = data['snappedPoints'][0]['location'];
      return LatLng(snappedLocation['latitude'], snappedLocation['longitude']);
    }

    return null;
  }

  bool _isPositionOnPath(LatLng position) {
    const double threshold = 0.0001; // Adjust for tolerance
    for (LatLng point in _path) {
      if ((position.latitude - point.latitude).abs() < threshold &&
          (position.longitude - point.longitude).abs() < threshold) {
        return true;
      }
    }
    return false;
  }

  void _movePointer(double latOffset, double lngOffset, double rotation, Set<String> pressedButtons) {
    if (pointerManager != null) {
      LatLng currentPos = pointerManager!.pointer.position;
      LatLng newPos = LatLng(currentPos.latitude + latOffset, currentPos.longitude + lngOffset);

      if (_routeCreated && !_isPositionOnPath(newPos)) {
        if (stopMovement != null) stopMovement!();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('CRASHED'),
              content: Text('Closely Follow the Polylines'),
              actions: <Widget>[
                TextButton(
                  child: Text('Restart'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _resetPointerToStart();
                  },
                ),
              ],
            );
          },
        );
      } else {
        _lastValidPosition = newPos;
        _distanceTravelled += haversineDistance(currentPos, newPos);
        _score = (_distanceTravelled / 10).floor();

        setState(() {
          pointerManager!.pointer = Pointer(
            position: newPos,
            rotation: rotation,
            icon: pointerManager!.pointer.icon,
          );
          _updatePointerMarker();
        });

        mapController?.animateCamera(CameraUpdate.newLatLng(newPos));

        if (_routeCreated &&
            (newPos.latitude - destinationLatLng!.latitude).abs() < 0.0001 &&
            (newPos.longitude - destinationLatLng!.longitude).abs() < 0.0001) {
          if (stopMovement != null) stopMovement!();
          _routeCreated = false;
          _path.clear();
          _showDestinationReachedDialog();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Destination reached!')),
          );
        }
      }
    }
  }

  void _showDestinationReachedDialog() {
    transferPoints();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Congratulations!'),
          content: Text('You have reached your destination.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _resetPointerToStart() {
    transferPoints();
    setState(() {
      pointerManager!.pointer = Pointer(
        position: startLatLng!,
        rotation: 0,
        icon: pointerManager!.pointer.icon,
      );
      _distanceTravelled = 0;
      _score = 0;
      _updatePointerMarker();
    });

    mapController?.animateCamera(CameraUpdate.newLatLng(startLatLng!));
  }

  void _navigateToRoutesScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoutesScreen(
          mapController: mapController,
          initialStartLatLng: startLatLng,
          initialDestinationLatLng: destinationLatLng,
        ),
      ),
    );

    if (result != null) {
      LatLng? newStartLatLng = result['start'];
      LatLng? newDestinationLatLng = result['destination'];

      if (newStartLatLng != null && newDestinationLatLng != null) {
        newStartLatLng = await getNearestRoad(newStartLatLng) ?? newStartLatLng;
        newDestinationLatLng = await getNearestRoad(newDestinationLatLng) ?? newDestinationLatLng;
      }

      setState(() {
        startLatLng = newStartLatLng;
        destinationLatLng = newDestinationLatLng;
        _routeCreated = true;
        _lastValidPosition = newStartLatLng;
        _distanceTravelled = 0;
        _score = 0;
        _updateMarkers();
        _getRoutes();
        if (startLatLng != null) {
          pointerManager?.pointer = Pointer(
            position: startLatLng!,
            rotation: 0,
            icon: pointerManager!.pointer.icon,
          );
          mapController?.animateCamera(
            CameraUpdate.newLatLng(
              LatLng(pointerManager!.pointer.position.latitude, pointerManager!.pointer.position.longitude),
            ),
          );
          _updatePointerMarker();
        }
      });
    }
  }

  void _updateMarkers() {
    setState(() {
      _markers.clear();
      if (startLatLng != null) {
        _markers.add(Marker(
          markerId: MarkerId('start'),
          position: startLatLng!,
          infoWindow: InfoWindow(title: 'Start Location'),
        ));
      }
      if (destinationLatLng != null) {
        _markers.add(Marker(
          markerId: MarkerId('destination'),
          position: destinationLatLng!,
          infoWindow: InfoWindow(title: 'Destination Location'),
        ));
      }
    });
  }

  Future<void> _getRoutes() async {
    if (startLatLng == null || destinationLatLng == null) {
      return;
    }

    const String DIRECTIONS_API_KEY = "AIzaSyCRgj3hKMal8dn-XLU9gZDHtBY010lvwzI";
    String baseURL = 'https://maps.googleapis.com/maps/api/directions/json';
    String request = '$baseURL?origin=${startLatLng!.latitude},${startLatLng!.longitude}&destination=${destinationLatLng!.latitude},${destinationLatLng!.longitude}&alternatives=true&key=$DIRECTIONS_API_KEY';
    var response = await http.get(Uri.parse(request));
    var data = json.decode(response.body);
    print('Directions API response data: $data');

    if (data['status'] == 'OK') {
      _polylines.clear();
      _path.clear();
      for (var route in data['routes']) {
        List<LatLng> polylineCoordinates = [];
        var points = decodePolyline(route['overview_polyline']['points']);
        for (var point in points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }

        polylineCoordinates = _interpolatePoints(polylineCoordinates, 50);

        _totalDistance = route['legs'][0]['distance']['text'];

        var polyline = Polyline(
          polylineId: PolylineId(route['summary']),
          points: polylineCoordinates,
          color: Colors.blue,
          width: 5,
        );

        _polylines.add(polyline);
        _path.addAll(polylineCoordinates);
      }

      for (LatLng coord in _path) {
        print('Path coordinate: ${coord.latitude}, ${coord.longitude}');
      }

      setState(() {});
    } else {
      print('Error getting directions: ${data['status']}');
    }
  }

  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polyline.add(LatLng((lat / 1E5), (lng / 1E5)));
    }

    return polyline;
  }

  List<LatLng> _interpolatePoints(List<LatLng> points, int numInterpolatedPoints) {
    List<LatLng> interpolatedPoints = [];

    for (int i = 0; i < points.length - 1; i++) {
      LatLng start = points[i];
      LatLng end = points[i + 1];

      interpolatedPoints.add(start);

      for (int j = 1; j <= numInterpolatedPoints; j++) {
        double fraction = j / (numInterpolatedPoints + 1);
        double lat = start.latitude + (end.latitude - start.latitude) * fraction;
        double lng = start.longitude + (end.longitude - start.longitude) * fraction;
        interpolatedPoints.add(LatLng(lat, lng));
      }
    }

    interpolatedPoints.add(points.last);
    return interpolatedPoints;
  }

  double haversineDistance(LatLng pos1, LatLng pos2) {
    const double R = 6371000;
    double lat1 = pos1.latitude * pi / 180;
    double lon1 = pos1.longitude * pi / 180;
    double lat2 = pos2.latitude * pi / 180;
    double lon2 = pos2.longitude * pi / 180;

    double dlat = lat2 - lat1;
    double dlon = lon2 - lon1;

    double a = sin(dlat / 2) * sin(dlat / 2) +
        cos(lat1) * cos(lat2) * sin(dlon / 2) * sin(dlon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  void _toggleMapType() {
    setState(() {
      _currentMapType = (_currentMapType == MapType.satellite) ? MapType.normal : MapType.satellite;
    });
  }


  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Drive Around'),
        actions: [
          IconButton(
            icon: Icon(_currentMapType == MapType.satellite
                ? Icons.satellite_alt
                : Icons.remove_red_eye_sharp),
            onPressed: _toggleMapType,
          ),
          IconButton(
            icon: Icon(Icons.directions),
            onPressed: _navigateToRoutesScreen,
          ),
        ],
      ),
      body: currentLocation == null
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 25.0,
              ),
              //mapType: MapType.satellite,
              //mapType: MapType.normal,
              mapType: _currentMapType,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: _markers,
              polylines: _polylines,
            ),
          ),
          if (_totalDistance != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text('Total Distance: $_totalDistance'),
                  Text('Score: $_score'),
                ],
              ),
            ),
          DriveControls(
            onMoveButtonPressed: _movePointer,
            onStopMovement: (stopFunction) {
              stopMovement = stopFunction;
            },
          ),
        ],
      ),
    );
  }

  void transferPoints() {
    points = _score * 10;
    CoinManager.addPoints(points).then((_) {
      // Here, you can add any follow-up actions after the points are successfully added.
      print("Points transferred successfully!");
    });
  }
}