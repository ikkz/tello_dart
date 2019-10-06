import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

class FlipDirection {
  static final String l = "l";
  static final String r = "r";
  static final String f = "f";
  static final String b = "b";
}

class CmdResponseCallback {
  DateTime time;
  void Function(String) callback;

  CmdResponseCallback(this.time, this.callback);
}

typedef TelloSuccessCallback = void Function(bool success);

class Tello {
  RawDatagramSocket _cmdSocket;
  StreamSubscription _cmdSubscription;

  Queue<CmdResponseCallback> _listeners = Queue<CmdResponseCallback>();

  var telloPort = 8889;
  var telloAddr = InternetAddress("192.168.10.1");

  void _cmdResponseListener(String data) {
    debugPrint("recv response: $data");
    final now = DateTime.now();
    while (_listeners.isNotEmpty &&
        now.millisecondsSinceEpoch -
                _listeners.first.time.millisecondsSinceEpoch >
            1000) {
      _listeners.removeFirst();
    }
    if (_listeners.isNotEmpty) {
      _listeners.removeFirst().callback(data);
    }
  }

  Future<void> connect() async {
    _listeners.clear();
    _cmdSocket =
        await RawDatagramSocket.bind(InternetAddress.anyIPv4, telloPort);
    _cmdSocket.broadcastEnabled = true;
    _cmdSubscription = _cmdSocket.listen((event) {
      if (event == RawSocketEvent.read) {
        _cmdResponseListener(String.fromCharCodes(_cmdSocket.receive().data));
      }
    });
  }

  int sendCommand(String command, void Function(String) callback) {
    if (_cmdSocket == null) {
      return 0;
    } else {
      debugPrint("send command: $command");
      _listeners.addLast(CmdResponseCallback(DateTime.now(), callback));
      final res = _cmdSocket.send(utf8.encode(command), telloAddr, telloPort);
      return res;
    }
  }

  void Function(String) _oeWrapper(TelloSuccessCallback successCallback) {
    return (String data) {
      successCallback(data == "ok");
    };
  }

  int takeoff(TelloSuccessCallback successCallback) {
    return sendCommand("takeoff", _oeWrapper(successCallback));
  }

  /// [cmps] : 1 to 100 centimeters/second
  int setSpeed(int cmps, TelloSuccessCallback successCallback) {
    cmps = (cmps * 27.7778).round().toInt();
    return sendCommand("speed $cmps", _oeWrapper(successCallback));
  }

  /// [degrees] : Degrees to rotate, 1 to 360.
  int rotateCw(int degrees, TelloSuccessCallback successCallback) {
    return sendCommand("cw $degrees", _oeWrapper(successCallback));
  }

  /// [degrees] : Degrees to rotate, 1 to 360.
  int rotateCcw(int degrees, TelloSuccessCallback successCallback) {
    return sendCommand("ccw $degrees", _oeWrapper(successCallback));
  }

  /// [flipDirection] : Direction to flip, 'l', 'r', 'f', 'b'. use FlipDirection.l ...
  int flip(String flipDirection, TelloSuccessCallback successCallback) {
    return sendCommand("flip $flipDirection", _oeWrapper(successCallback));
  }

  int land(TelloSuccessCallback successCallback) {
    return sendCommand("land", _oeWrapper(successCallback));
  }

  /// [distance] = [20, 500] cm
  int _move(
      String direction, int distance, TelloSuccessCallback successCallback) {
    distance = max(20, distance);
    distance = min(500, distance);
    return sendCommand("$direction $distance", _oeWrapper(successCallback));
  }

  /// [distance] = [20, 500] cm
  int moveBackward(int distance, TelloSuccessCallback successCallback) {
    return _move("back", distance, successCallback);
  }

  /// [distance] = [20, 500] cm
  int moveDown(int distance, TelloSuccessCallback successCallback) {
    return _move("down", distance, successCallback);
  }

  /// [distance] = [20, 500] cm
  int moveForward(int distance, TelloSuccessCallback successCallback) {
    return _move("forward", distance, successCallback);
  }

  /// [distance] = [20, 500] cm
  int moveLeft(int distance, TelloSuccessCallback successCallback) {
    return _move("left", distance, successCallback);
  }

  int moveRight(int distance, TelloSuccessCallback successCallback) {
    return _move("right", distance, successCallback);
  }

  int moveUp(int distance, TelloSuccessCallback successCallback) {
    return _move("up", distance, successCallback);
  }

  void disconnect() {
    _listeners.clear();
    _cmdSubscription?.cancel();
    _cmdSocket?.close();
    _cmdSubscription = null;
    _cmdSocket = null;
  }
}
