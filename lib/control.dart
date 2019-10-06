import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './wheel.dart';
import './tello.dart';
import './simple_dialogs.dart';

class Control extends StatefulWidget {
  @override
  _ControlState createState() => _ControlState();
}

class _ControlState extends State<Control> {
  Tello _tello;
  final _moveDistance = 20;
  final _udDistance = 50;
  var height = 0;
  var battery = 100;

  void _init() async {
    _tello = Tello();
    await _tello.connect((h, bat) {
      this.setState(() {
        height = h;
        battery = bat;
      });
    });
    _tello?.sendCommand("command", (s) {
      print(s);
    });
  }

  void _takeoff() async {
    final res = await SimpleDialogs.alert(context: context, content: "确认起飞吗？");
    if (res == true) {
      _tello.takeoff((b) {
        if (b) {
          SimpleDialogs.alert(context: context, content: "起飞成功");
        }
      });
    }
  }

  void _land() async {
    final res = await SimpleDialogs.alert(context: context, content: "确认降落吗？");
    if (res == true) {
      _tello.land((b) {
        if (b) {
          SimpleDialogs.alert(context: context, content: "降落成功");
        }
      });
    }
  }

  void _execCmd() async {
    final cmd = await SimpleDialogs.editText(
        context: context, title: "请输入要执行的命令", defaultText: "land");
    if (cmd != null && cmd.isNotEmpty) {
      _tello?.sendCommand(cmd, (s) {
        SimpleDialogs.alert(context: context, title: "收到如下返回值", content: s);
      });
    }
  }

  void _move(WheelDirection wheelDirection) {
    switch (wheelDirection) {
      case WheelDirection.Forward:
        _tello?.moveForward(_moveDistance, (b) {});
        break;
      case WheelDirection.Backward:
        _tello?.moveBackward(_moveDistance, (b) {});
        break;
      case WheelDirection.Left:
        _tello?.moveLeft(_moveDistance, (b) {});
        break;
      case WheelDirection.Right:
        _tello?.moveRight(_moveDistance, (b) {});
        break;
      default:
    }
  }

  void _moveUd(WheelDirection wheelDirection) {
    switch (wheelDirection) {
      case WheelDirection.Forward:
        _tello?.moveUp(_udDistance, (b) {});
        break;
      case WheelDirection.Backward:
        _tello?.moveDown(_udDistance, (b) {});
        break;
      // case WheelDirection.Left:
      //   _tello?.moveLeft(_moveDistance, (b) {});
      //   break;
      // case WheelDirection.Right:
      //   _tello?.moveRight(_moveDistance, (b) {});
      //   break;
      default:
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations([]);
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    _tello?.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          bottomOpacity: 1,
          actions: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.battery_std),
                Text(battery.toString())
              ],
            ),
            Row(
              children: <Widget>[
                Icon(Icons.import_export),
                Text("${height / 100} m")
              ],
            ),
            IconButton(
              icon: Icon(Icons.flight_takeoff),
              onPressed: () {
                _takeoff();
              },
            ),
            IconButton(
              icon: Icon(Icons.flight_land),
              onPressed: () {
                _land();
              },
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                _execCmd();
              },
            )
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
                    radius: 100,
                    directionCallback: _moveUd,
                  ),
                ),
                Expanded(
                  child: Container(),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Wheel(
                    radius: 100,
                    directionCallback: _move,
                  ),
                ),
              ],
            )
          ],
        ));
  }
}
