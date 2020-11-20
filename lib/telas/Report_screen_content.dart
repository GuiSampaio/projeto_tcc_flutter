import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:rota_segura/data/crimes.dart';
import 'package:rota_segura/data/tipo_crime.dart';
import 'package:rota_segura/model/report_model.dart';
import 'package:rota_segura/telas/Select_place.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:date_format/date_format.dart';

class ReportScreenContent extends StatefulWidget {
  @override
  _ReportScreenContentState createState() => _ReportScreenContentState();
}

class _ReportScreenContentState extends State<ReportScreenContent> {
  final _dataController = TextEditingController();
  final _localController = TextEditingController();
  final _horaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  var _selectValueTipoDeCrime;
  var _tiposDeCrime = List<DropdownMenuItem>();

  var _selectValueCrime;
  var _crime = List<DropdownMenuItem>();

  var dateMaskFormatter = new MaskTextInputFormatter(mask: "##/##/####");

  _loadTiposCrimes() async {
    var tipoCrimes = await ReportModel.of(context).getTipoCrime();
    tipoCrimes.forEach((TipoCrime tipo) {
      setState(() {
        _tiposDeCrime.add(DropdownMenuItem(
          child: Text(tipo.tipo),
          value: tipo.cid,
        ));
      });
    });
  }

  _loadCrimes(value) async {
    var crimes = await ReportModel.of(context).getCrimes(value);
    crimes.forEach((Crimes crime) {
      setState(() {
        _crime.add(DropdownMenuItem(
          child: Text(crime.descricao),
          value: crime.cid,
        ));
      });
    });
  }

  Marker _local;

  _recuperarLocalMarcador(BuildContext context) async {
    final List<Placemark> _listaEnderecos = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => SelectPlace()));

    if (_listaEnderecos != null && _listaEnderecos.length > 0) {
      Placemark endereco = _listaEnderecos[0];
      String rua = endereco.thoroughfare;
      /*Position pos = endereco.position;

      Marker marcador = Marker(
        markerId: MarkerId("marcador-${pos.latitude}-${pos.longitude}"),
        position: LatLng(pos.latitude, pos.longitude),
        infoWindow: InfoWindow(title: rua),
      );*/

      setState(() {
        _localController.text = rua;
      });
    }
  }

  DateTime selectedDate = DateTime.now();
  // TextEditingController _date = new TextEditingController();

  Future<Null> _selectDate(BuildContext context) async {
    DateFormat formatter =
        DateFormat('dd/MM/yyyy'); //specifies day/month/year format

    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2019, 1),
        lastDate: DateTime(2021));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        _dataController.value = TextEditingValue(
            text: formatter.format(
                picked)); //Use formatter to format selected date and assign to text field
      });
  }

  String _hour, _minute, _time;

  String dateTime;

  DateTime selectedDateTime = DateTime.now();

  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null)
      setState(() {
        selectedTime = picked;
        _hour = selectedTime.hour.toString();
        _minute = selectedTime.minute.toString();
        _time = _hour + ' : ' + _minute;
        _horaController.text = _time;
        String hora = formatDate(
            DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute)
                .toLocal(),
            [
              hh,
              ':',
              nn,
              "",
            ]).toString();
        _horaController.text = DateFormat.Hm().format(DateTime.parse(hora));
      });
  }

  _reportar(){

    //FirebaseFirestore.instance.collection("reportes").add(map);
  }

  @override
  void initState() {
    super.initState();
    _loadTiposCrimes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body:
          ScopedModelDescendant<ReportModel>(builder: (context, child, model) {
        if (model.isLoading)
          return Center(
            child: CircularProgressIndicator(),
          );

        return Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField(
                    decoration: InputDecoration(border: InputBorder.none),
                    value: _selectValueTipoDeCrime,
                    items: _tiposDeCrime,
                    hint: Text("Selecione o Tipo de Crime"),
                    onChanged: (value) {
                      setState(() {
                        _selectValueTipoDeCrime = value;
                        print(_selectValueTipoDeCrime);
                        _selectValueCrime = null;
                        _crime = List<DropdownMenuItem>();
                      });
                      _loadCrimes(value);
                    }),
              ),
              SizedBox(
                height: 16.0,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField(
                    decoration: InputDecoration(border: InputBorder.none),
                    hint: Text("Selecione o Crime"),
                    value: _selectValueCrime,
                    items: _crime,
                    onChanged: (value) {
                      setState(() {
                        _selectValueCrime = value;
                        print(_selectValueCrime);
                      });
                    }),
              ),
              SizedBox(
                height: 16.0,
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: new BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 15, right: 15, top: 5, bottom: 5),
                        child: TextFormField(
                          textAlign: TextAlign.left,
                          controller: _localController,
                          decoration: InputDecoration(
                            hintText: "Selecione Local",
                            border: InputBorder.none,
                          ),
                          validator: (text) {
                            //if (text.isEmpty) return "Nome inválido!";
                          },
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10.0),
                    width: 50,
                    height: 50,
                    child: IconButton(
                      alignment: Alignment.center,
                      onPressed: () {
                        _recuperarLocalMarcador(context);
                      },
                      color: Colors.blue,
                      icon: Icon(Icons.location_searching),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 16.0,
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: new BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 15, right: 15, top: 5, bottom: 5),
                        child: TextFormField(
                          inputFormatters: [dateMaskFormatter],
                          controller: _dataController,
                          decoration: InputDecoration(
                              hintText: "Data do Ocorrido",
                              border: InputBorder.none),
                          keyboardType: TextInputType.datetime,
                          validator: (text) {
                            if (text.isEmpty || !text.contains("@"))
                              return "E-mail inválido";
                          },
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10.0),
                    width: 50,
                    height: 50,
                    child: IconButton(
                      alignment: Alignment.center,
                      onPressed: () {
                        _selectDate(context);
                      },
                      color: Colors.blue,
                      icon: Icon(Icons.calendar_today),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 16.0,
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: new BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 15, right: 15, top: 5, bottom: 5),
                        child: TextFormField(
                          controller: _horaController,
                          decoration: InputDecoration(
                              hintText: "Hora do Ocorrido",
                              border: InputBorder.none),
                          keyboardType: TextInputType.emailAddress,
                          validator: (text) {
                            if (text.isEmpty || !text.contains("@"))
                              return "E-mail inválido";
                          },
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10.0),
                    width: 50,
                    height: 50,
                    child: IconButton(
                      alignment: Alignment.center,
                      onPressed: () {
                        _selectTime(context);
                        print(_horaController.text);
                      },
                      color: Colors.blue,
                      icon: Icon(Icons.alarm),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 16.0,
              ),
              SizedBox(
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: BorderSide(color: Colors.grey),
                  ),
                  child: Text(
                    "Reportar",
                    style: TextStyle(fontSize: 18.0),
                  ),
                  textColor: Colors.black,
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    _reportar;
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
