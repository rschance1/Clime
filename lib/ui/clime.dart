import 'package:flutter/material.dart';
import 'package:clime/util/utils.dart' as utils;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Clime extends StatefulWidget {
  @override
  _ClimeState createState() => _ClimeState();
}

class _ClimeState extends State<Clime> {
  String _cityEntered;

  Future _goToNextScreen(BuildContext context) async {
    Map results = await Navigator.of(context)
        .push(new MaterialPageRoute<Map>(builder: (BuildContext context) {
      return new ChangeCity();
    }));

    if (results != null && results.containsKey('enter')) {
      _cityEntered = results['enter'];
      //   debugPrint(results['enter'].toString());
    }
  }

  void showStuff() async {
    Map data = await getWeather(utils.appId, utils.defaultCity);
    print(data.toString());
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Clime'),
        backgroundColor: Colors.red,
        actions: <Widget>[
          new IconButton(
              icon: new Icon(Icons.menu),
              onPressed: () {
                _goToNextScreen(context);
              })
        ],
      ),
      //body of application
      //adding image to background
      body: new Stack(
        children: <Widget>[
          new Center(
            child: new Image.asset(
              'images/umbrella.png',
              height: 1200.0,
              width: 500.0,
              fit: BoxFit.fill,
            ),
          ),
          //container for showing text on top of image
          new Container(
            alignment: Alignment.topRight,
            margin: const EdgeInsets.fromLTRB(0.0, 10.9, 20.9, 0.0),
            child: new Text(
              '${_cityEntered == null ? utils.defaultCity : _cityEntered}',
              style: cityStyle(),
            ),
          ),
          new Container(
            alignment: Alignment.center,
            child: new Image.asset('images/light_rain.png'),
          ),

          //container which will have our weather data
          new Container(
            child: updateTempWidget(_cityEntered),
          )
        ],
      ),
    );
  }
}

//api call to retrieve our weather data
Future<Map> getWeather(String appId, String city) async {
  String apiUrl =
      "http://api.openweathermap.org/data/2.5/weather?q=$city&appid=${utils.appId}&units=imperial";
  http.Response response = await http.get(apiUrl);
  return json.decode(response.body);
}

//future api calls with changes to weather data api
Widget updateTempWidget(String city) {
  return new FutureBuilder(
      future: getWeather(utils.appId, city == null ? utils.defaultCity : city),
      builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
        //where we get all of the Json data, we setup widgets etc...
        if (snapshot.hasData) {
          Map content = snapshot.data;
          return new Container(
            margin: const EdgeInsets.fromLTRB(50.0, 260.0, 0.0, 0.0),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new ListTile(
                  title: new Text(
                    content['main']['temp'].toString() + " F",
                    style: new TextStyle(
                        fontStyle: FontStyle.normal,
                        fontSize: 50.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ),
                  subtitle: new ListTile(
                    title: new Text(
                      "Humidity: ${content['main']['humidity'].toString()}\n"
                          "Min: ${content['main']['temp_min'].toString()} F\n"
                          "Max: ${content['main']['temp_max'].toString()} F",
                      style: extraData(),
                    ),
                  ),
                )
              ],
            ),
          );
        } else {
          return new Container();
        }
      });
}

class ChangeCity extends StatelessWidget {
  var _cityFieldController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.red,
        title: new Text('Change City'),
        centerTitle: true,
      ),
      body: new Stack(
        children: <Widget>[
          new Center(
            child: new Image.asset(
              'images/white_snow.png',
              width: 500.00,
              height: 1200.0,
              fit: BoxFit.fill,
            ),
          ),
          new ListView(
            children: <Widget>[
              new ListTile(
                title: new TextField(
                  decoration: new InputDecoration(
                    hintText: 'Enter City',
                  ),
                  controller: _cityFieldController,
                  keyboardType: TextInputType.text,
                ),
              ),
              new ListTile(
                title: new FlatButton(
                    onPressed: () {
                      if (_cityFieldController.text.isEmpty) {
                        Fluttertoast.showToast(
                            msg: "Enter a city",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIos: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white);
                      } else {
                        Navigator.pop(
                            context, {'enter': _cityFieldController.text});
                      }
                    },
                    textColor: Colors.white,
                    color: Colors.redAccent,
                    child: new Text('Get Weather')),
              )
            ],
          )
        ],
      ),
    );
  }
}

TextStyle cityStyle() {
  return new TextStyle(
      color: Colors.white, fontSize: 22.9, fontStyle: FontStyle.italic);
}

TextStyle tempStyle() {
  return new TextStyle(
      color: Colors.white, fontStyle: FontStyle.normal, fontSize: 50.0);
}

TextStyle extraData() {
  return new TextStyle(
      color: Colors.white,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w500,
      fontSize: 20.0);
}
