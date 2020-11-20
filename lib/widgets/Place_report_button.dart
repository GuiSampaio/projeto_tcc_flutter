import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class PlaceReportButton extends StatefulWidget {
  final Completer<GoogleMapController> controller;
  PlaceReportButton(this.controller);

  @override
  _PlaceReportButtonState createState() => _PlaceReportButtonState(controller);
}

class _PlaceReportButtonState extends State<PlaceReportButton>
    with TickerProviderStateMixin {
      
  final Completer<GoogleMapController> controller;
  _PlaceReportButtonState(this.controller);

  @override
  Widget build(BuildContext context) {
    Completer<GoogleMapController> _controller = Completer();
    void _currentLocation() async {
      var location = new Location();
      bool _serviceEnabled;
      PermissionStatus _permissionGranted;

      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        }
      }
      final GoogleMapController controller = await _controller.future;
      LocationData currentLocation;

      try {
        currentLocation = await location.getLocation();
      } on Exception {
        currentLocation = null;
      }

      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 0,
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: 17.0,
        ),
      ));
    }

    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22.0),
      visible: true,
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
          child: Icon(Icons.location_on, color: Colors.white),
          backgroundColor: Colors.blue,
          onTap: () {
            setState(() {
              _currentLocation();
            });
          },
          label: 'Meu Local',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.white,
        ),
        SpeedDialChild(
          child: Icon(Icons.dangerous, color: Colors.white),
          backgroundColor: Colors.redAccent,
          onTap: () => print('Reportar Local'),
          label: 'Reportar Local',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.white,
        ),
        /*SpeedDialChild(
          child: Icon(Icons.keyboard_voice, color: Colors.white),
          backgroundColor: Colors.blue,
          onTap: () => print('THIRD CHILD'),
          labelWidget: Container(
            color: Colors.blue,
            margin: EdgeInsets.only(right: 10),
            padding: EdgeInsets.all(6),
            child: Text('Custom Label Widget'),
          ),
        ),*/
      ],
    );
  }
}
