import 'dart:html';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather_icons/weather_icons.dart';
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int value = 89;
  String temp = "";
  String humidity_value = "";
  String carbon_mono = "";
  String pm_two_point_five = "";
  String other = "";
  Future<void> getDataValue() async {
    http.Response response = await http.get(Uri.parse(
        'https://api.thingspeak.com/channels/1513754/feeds.json?results=2'));
    if (response.statusCode == 200) {
      var data = response.body;
      print("data value is $data");
      var decoded_data = jsonDecode(data);

      setState(() {
        temp = "39";
        humidity_value = "3";
        carbon_mono = "100";
        pm_two_point_five = "22";
        other = "100";
        // temp = decoded_data['feeds'][0]['field1'];
        // humidity_value = decoded_data['feeds'][0]['field2'];
        // carbon_mono = decoded_data['feeds'][0]['field3'];
        // pm_two_point_five = decoded_data['feeds'][0]['field4'];
        // other = decoded_data['feeds'][0]['field5'];
      });
    } else {
      print(response.statusCode);
    }
  }

  @override
  initState() {
    super.initState();
    getDataValue();
  }

  Color getColor() {
    if ((int.parse(carbon_mono) >= 500 ||
        int.parse(pm_two_point_five) >= 500 ||
        int.parse(other) >= 500)) {
      return Color(0xFFEF5350);
      // return Color(0xFF4CAF50);
    } else if (int.parse(carbon_mono) >= 300 ||
        int.parse(pm_two_point_five) >= 300 ||
        int.parse(other) >= 300) {
      return Color(0xFFFFF176);
    } else {
      return Colors.green;
    }
  }

  Text get_text() {
    if (int.parse(carbon_mono) >= 500 ||
        int.parse(pm_two_point_five) >= 500 ||
        int.parse(other) >= 500) {
      return Text("Dangerous");
    } else if (int.parse(carbon_mono) >= 300 ||
        int.parse(pm_two_point_five) >= 300 ||
        int.parse(other) >= 300) {
      return Text("Medium");
    } else {
      return Text("Good");
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTitle = 'purifier data';

    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        appBar: AppBar(
          title: Text(appTitle),
          backgroundColor: Colors.green,
          centerTitle: true,
        ),
        body: Column(
          children: [
            Column(
              children: <Widget>[
                SizedBox(
                  height: 200.0,
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: Container(
                          width: 150,
                          height: 150,
                          child: new CircularProgressIndicator(
                            color: getColor(),
                            strokeWidth: 15,
                            value: 1.0,
                          ),
                        ),
                      ),
                      Center(child: get_text()),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      tileColor: Colors.green,
                      leading: Text(
                        "Title             ",
                        style: TextStyle(color: Colors.white, fontSize: 20.0),
                      ),
                      title: Text(
                        'value',
                        style: TextStyle(color: Colors.white, fontSize: 20.0),
                      ),
                      trailing: Text("Status",
                          style:
                              TextStyle(color: Colors.white, fontSize: 20.0)),
                    ),
                  ),
                  ListTile(
                    leading: Text("Temperature          "),
                    title: Text('$temp'),
                    trailing: Text("Excellent",
                        style: TextStyle(color: Colors.green)),
                  ),
                  ListTile(
                    leading: Text("Humidity                   "),
                    title: Text('$humidity_value'),
                    trailing: Text('A bit dry',
                        style: TextStyle(color: Colors.green)),
                  ),
                  ListTile(
                    leading: Text("Carbon Monoxide  "),
                    title: Text('$carbon_mono'),
                    trailing: Text('Excellent',
                        style: TextStyle(color: Colors.green)),
                  ),
                  ListTile(
                    leading: Text("PM2.5                      "),
                    title: Text('$pm_two_point_five'),
                    trailing: Text(
                      'Quiet',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                  ListTile(
                    leading: Text("Others                    "),
                    title: Text('$other'),
                    trailing: Text(
                      'Quiet',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
