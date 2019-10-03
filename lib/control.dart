import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './wheel.dart';

class Control extends StatefulWidget {
  @override
  _ControlState createState() => _ControlState();
}

class _ControlState extends State<Control> {
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
