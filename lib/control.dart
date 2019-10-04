import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './wheel.dart';
import './tello.dart';

class Control extends StatefulWidget {
  @override
  _ControlState createState() => _ControlState();
}

class _ControlState extends State<Control> {
  Tello _tello;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations([]);
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          bottomOpacity: 1,
          actions: <Widget>[
            Icon(Icons.wifi),
            Icon(Icons.airplanemode_active),
          ]
              .map((Widget icon) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: icon,
                  ))
              .toList(),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: Container(),
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Wheel(
                    width: 150,
                    height: 150,
                    indicatorRadius: 20,
                  ),
                ),
                Expanded(
                  child: Container(),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Wheel(
                    width: 150,
                    height: 150,
                    indicatorRadius: 20,
                  ),
                ),
              ],
            )
          ],
        ));
  }
}
