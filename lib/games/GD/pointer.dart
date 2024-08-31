import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Pointer {
  LatLng position;
  double rotation;
  BitmapDescriptor icon;

  Pointer({required this.position, required this.rotation, required this.icon});
}

class PointerManager {
  Pointer pointer;

  PointerManager(this.pointer);

  Marker get pointerMarker => Marker(
        markerId: MarkerId('pointer'),
        position: pointer.position,
        icon: pointer.icon,
        rotation: pointer.rotation,
      );

  void movePointer(double latOffset, double lngOffset, double rotation) {
    pointer = Pointer(
      position: LatLng(pointer.position.latitude + latOffset, pointer.position.longitude + lngOffset),
      rotation: rotation,
      icon: pointer.icon,
    );
  }
}
