import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:permission_handler/permission_handler.dart';

import './control.dart';

void main() => runApp(WifiInfo());

class WifiInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpecialJourney',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WifiInfoState(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WifiInfoState extends StatefulWidget {
  WifiInfoState({Key key}) : super(key: key);
  @override
  _WifiInfoStateState createState() => _WifiInfoStateState();
}

class _WifiInfoStateState extends State<WifiInfoState> {
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  String _wifiName = "none";
  StreamSubscription<ConnectivityResult> _subscription;

  @override
  void initState() {
    super.initState();

    _initConnectivity();
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult connectivityResult) async {
      if (connectivityResult == ConnectivityResult.wifi) {
        var wifiName = await (Connectivity().getWifiName());
        this.setState(() {
          _connectivityResult = connectivityResult;
          _wifiName = wifiName;
        });
      } else {
        this.setState(() {
          _connectivityResult = connectivityResult;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }

  void _initConnectivity() async {
    await PermissionHandler().requestPermissions([PermissionGroup.location]);
    var connectivityResult = await (Connectivity().checkConnectivity());
    var wifiName = await (Connectivity().getWifiName());
    this.setState(() {
      _connectivityResult = connectivityResult;
      _wifiName = wifiName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('当前网络状态'),
      ),
      body: SingleChildScrollView(
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 100),
              child: Icon(
                Icons.wifi,
                size: 100,
              ),
            ),
            Container(
              height: 100,
              width: 300,
              child: Text("在启动设备并开启连接后，将手机连接到以 Tello 开头的 Wifi 网络。当前" +
                  (_connectivityResult == ConnectivityResult.wifi ? "已" : "未") +
                  "连接到 Wifi" +
                  (_connectivityResult == ConnectivityResult.wifi
                      ? "，名称为 $_wifiName。"
                      : "。")),
            ),
            _connectivityResult == ConnectivityResult.wifi
                ? RaisedButton(
                    child: const Text("开始控制"),
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return Control();
                      }));
                    },
                  )
                : Container()
          ],
        )),
      ),
    );
  }
}
