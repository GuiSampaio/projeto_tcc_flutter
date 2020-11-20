import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:location/location.dart';
import 'package:rota_segura/model/user_model.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // geo.Position _localPessoa;
  Completer<GoogleMapController> _controller = Completer();
  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  CameraPosition _posicaoCamera =
      CameraPosition(target: LatLng(-23.562436, -46.655005), zoom: 18);

  _recuperaUltimaLocalizacaoConhecida() async {
    geo.Position position = await geo.Geolocator()
        .getLastKnownPosition(desiredAccuracy: geo.LocationAccuracy.high);

    setState(() {
      if (position != null) {
        return LatLng(position.latitude, position.longitude);
      }
    });
  }

  _movimentarCamera(CameraPosition cameraPosition) async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  _adicionarListenerLocalizacao() {
    var geolocator = geo.Geolocator();
    var locationOptions = geo.LocationOptions(
        accuracy: geo.LocationAccuracy.high, distanceFilter: 10);
    geolocator
        .getPositionStream(locationOptions)
        .listen((geo.Position position) {
      setState(() {
        _posicaoCamera = CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 18);
        _movimentarCamera(_posicaoCamera);
      });
    });
  }

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
    LocationData currentLocation;

    try {
      currentLocation = await location.getLocation();
    } on Exception {
      currentLocation = null;
    }

    _movimentarCamera(CameraPosition(
      bearing: 0,
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
      zoom: 17.0,
    ));
  }

  @override
  void initState() {
    super.initState();
    _adicionarListenerLocalizacao();
    if(UserModel.of(context).isLoggedIn()){
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _posicaoCamera,
              onMapCreated: _onMapCreated,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.white),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            icon: Container(
                              margin: EdgeInsets.only(left: 10),
                              width: 10,
                              height: 25,
                              child: Icon(
                                Icons.location_on,
                                color: Colors.blue,
                              ),
                            ),
                            hintText: "Pesquise aqui",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(left: 15, top: 0),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 50.0,
                          height: 50.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage("images/person.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22.0),
        visible: true,
        curve: Curves.bounceIn,
        children: [
          SpeedDialChild(
            child: Icon(Icons.location_on, color: Colors.white),
            backgroundColor: Colors.blue,
            onTap: () {
              _currentLocation();
            },
            label: 'Meu Local',
            labelStyle: TextStyle(fontWeight: FontWeight.w500),
            labelBackgroundColor: Colors.white,
          ),
          SpeedDialChild(
            child: Icon(Icons.report, color: Colors.white),
            backgroundColor: Colors.redAccent,
            onTap: () {
              Navigator.pushNamed(context, "/reportscreen");
            },
            label: 'Reportar Local',
            labelStyle: TextStyle(fontWeight: FontWeight.w500),
            labelBackgroundColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
