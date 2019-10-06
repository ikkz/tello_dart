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

typedef TelloSuccessCallback = void Function(bool success);

class Tello {
  RawDatagramSocket _cmdSocket;
  RawDatagramSocket _stateSocket;
  StreamSubscription _cmdSubscription;
  StreamSubscription _stateSubscription;

  Queue<void Function(String)> _listeners = Queue<void Function(String)>();

  var telloPort = 8889;
  var telloStatePort = 8890;
  var telloAddr = InternetAddress("192.168.10.1");

  void _cmdResponseListener(String data) {
    debugPrint("recv response: $data");
    if (_listeners.isNotEmpty) {
      _listeners.removeFirst()(data);
    }
  }

  Future<void> connect(Function(int height, int bat) stateCallback) async {
    _listeners.clear();
    _cmdSocket =
        await RawDatagramSocket.bind(InternetAddress.anyIPv4, telloPort);
    _cmdSocket.broadcastEnabled = true;
    _cmdSubscription = _cmdSocket.listen((event) {
      if (event == RawSocketEvent.read) {
        _cmdResponseListener(String.fromCharCodes(_cmdSocket.receive().data));
      }
    });

    _stateSocket =
        await RawDatagramSocket.bind(InternetAddress.anyIPv4, telloStatePort);
    _stateSocket.broadcastEnabled = true;
    _stateSubscription = _stateSocket.listen((event) {
      if (event == RawSocketEvent.read && stateCallback != null) {
        final stateStr = String.fromCharCodes(_stateSocket.receive().data);
        final states = stateStr.split(";");
        Map map = Map<String, String>();
        for (var item in states) {
          final kv = item.split(":");
          if (kv.length == 2) {
            map[kv[0]] = kv[1];
          }
        }
        stateCallback(int.parse(map["h"]), int.parse(map["bat"]));
      }
    });
  }

  int sendCommand(String command, void Function(String) callback) {
    if (_cmdSocket == null) {
      return 0;
    } else {
      debugPrint("send command: $command");
      _listeners.addLast(callback);
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

    _stateSubscription?.cancel();
    _stateSocket?.close();
    _stateSubscription = null;
    _stateSocket = null;
  }
}
