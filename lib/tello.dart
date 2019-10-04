import 'dart:io';
import 'package:h264/h264.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

typedef VideoCallback = void Function(String);

class Tello {
  String telloIp = "192.168.10.1";
  int telloPort = 8889;
  int telloVideoPort = 11111;

  VideoCallback videoCallback = (jpgPath) {};

  Socket _cmdSocket;
  Socket _videoSocket;

  String _cmdResponse;

  String _packetData = "";
  String _videoFrame = "";

  void _init() async {
    final tmpPath = (await getTemporaryDirectory()).path;

    _cmdSocket = await Socket.connect(telloIp, telloPort, sourceAddress: ":$telloPort");
    _videoSocket = await Socket.connect(telloIp, telloVideoPort, sourceAddress: "$telloVideoPort");

    _cmdSocket.listen((data) {
      _cmdResponse = String.fromCharCodes(data);
    });

    _videoSocket.listen((data) async {
      var resString = String.fromCharCodes(data);
      _packetData += resString;
      if (resString.length != 1460) {
        var frame = File("$tmpPath/raw-frame");
        frame.writeAsStringSync(_packetData);
        var decoded = File("$tmpPath/decoded.jpg");
        await H264.decodeFrame(frame.path, decoded.path, 2592, 1936);
        videoCallback(decoded.path);
      }
    });

    _cmdSocket.write("command");
    _cmdSocket.write("streamon");
  }

  Tello(
      {@required this.localPort,
      @required this.localIp,
      this.telloIp,
      this.telloPort}) {
    _init();
  }

  void del() {
    _cmdSocket.close();
    _videoSocket.close();
  }
}
