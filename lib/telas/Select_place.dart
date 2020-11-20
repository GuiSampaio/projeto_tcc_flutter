import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:location/location.dart';
import 'package:rota_segura/model/user_model.dart';

class SelectPlace extends StatefulWidget {
  @override
  _SelectPlace createState() => _SelectPlace();
}

class _SelectPlace extends State<SelectPlace> {
  // geo.Position _localPessoa;
  Completer<GoogleMapController> _controller = Completer();
  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  CameraPosition _posicaoCamera =
      CameraPosition(target: LatLng(-23.562436, -46.655005), zoom: 18);

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

  Set<Marker> _marcadores = {};
  List<geo.Placemark> _listaEnderecos = [];

  _adicionarMarcador(LatLng latLng) async {
    _marcadores = {};
    _listaEnderecos = await geo.Geolocator()
        .placemarkFromCoordinates(latLng.latitude, latLng.longitude);

    if (_listaEnderecos != null && _listaEnderecos.length > 0) {
      geo.Placemark endereco = _listaEnderecos[0];
      String rua = endereco.thoroughfare;

      Marker marcador = Marker(
        markerId: MarkerId("marcador-${latLng.latitude}-${latLng.longitude}"),
        position: latLng,
        infoWindow: InfoWindow(title: rua),
      );
      setState(() {
        _marcadores.add(marcador);
        //Salvar Viagem no Firebase
        //Map<String, dynamic> viagem = Map();
        //viagem["titulo"] = rua;
        //viagem["latitude"] = latLng.latitude;
        //viagem["longitude"] = latLng.longitude;

        //FirebaseFirestore.instance.collection("viagens").add(viagem);
      });
      //   }
    }
  }

  @override
  void initState() {
    super.initState();
    _currentLocation();
    _adicionarListenerLocalizacao();
    if (UserModel.of(context).isLoggedIn()) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Selecionar um Local"),
      ),
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
              onLongPress: _adicionarMarcador,
              markers: _marcadores,
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
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _marcadores.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                _sendDataBack(context);
              },
              label: Text('Confirmar Local'),
              icon: Icon(Icons.check),
              backgroundColor: Colors.blue,
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // get the text in the TextField and send it back to the FirstScreen
  void _sendDataBack(BuildContext context) {
    //Marker textToSendBack = _marcador;
    Navigator.pop(context, _listaEnderecos);
  }
}
