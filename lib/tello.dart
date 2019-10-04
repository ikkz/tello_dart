import 'dart:io';
import 'dart:async';

import 'package:udp/udp.dart';

class FlipDirection {
  static final String l = "l";
  static final String r = "r";
  static final String f = "f";
  static final String b = "b";
}

class Tello {
  UDP _cmd;

  final _telloAddr =
      Endpoint.unicast(InternetAddress("192.168.10.1"), Port(8889));

  void connect() async {
    _cmd = await UDP.bind(Endpoint.loopback(port: Port(8889)));
  }

  Future<int> sendCommand(String command) async {
    return _cmd == null ? -1 : await _cmd.send(command.codeUnits, _telloAddr);
  }

  Future<int> takeoff() async {
    return await sendCommand("takeoff");
  }

  Future<int> setSpeed(int speed) async {
    return await sendCommand("speed $speed");
  }

  Future<int> rotateCw(int degrees) async {
    return await sendCommand("cw $degrees");
  }

  Future<int> rotateCcw(int degrees) async {
    return await sendCommand("ccw $degrees");
  }

  Future<int> flip(String flipDirection) async {
    return await sendCommand("flip $flipDirection");
  }

  Future<int> land() async {
    return await sendCommand("land");
  }

  void disconnect() {
    _cmd.close();
    _cmd = null;
  }
}
