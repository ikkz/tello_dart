import 'dart:collection';
import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:udp/udp.dart';

class FlipDirection {
  static final String l = "l";
  static final String r = "r";
  static final String f = "f";
  static final String b = "b";
}

typedef TelloSuccessCallback = void Function(bool success);

class Tello {
  UDP _cmd;
  StreamSubscription _cmdSubscription;

  Queue<void Function(String)> _listeners = Queue<void Function(String)>();

  final _telloAddr =
      Endpoint.unicast(InternetAddress("192.168.10.1"), Port(8889));

  void _cmdResponseListener(String data) {
    if (_listeners.isNotEmpty) {
      _listeners.removeFirst()(data);
    }
  }

  void connect() async {
    _listeners.clear();
    _cmd = await UDP.bind(Endpoint.loopback(port: Port(8889)));
    _cmdSubscription = _cmd.socket.listen((event) {
      if (event == RawSocketEvent.read) {
        _cmdResponseListener(String.fromCharCodes(_cmd.socket.receive().data));
      }
    });
  }

  Future<int> sendCommand(
      String command, void Function(String) callback) async {
    if (_cmd == null) {
      return -1;
    } else {
      _listeners.addLast(callback);
      final res = await _cmd.send(command.codeUnits, _telloAddr);
      if (res != -1) {
        _listeners.addLast(callback);
      }
      return res;
    }
  }

  void Function(String) _oeWrapper(TelloSuccessCallback successCallback) {
    return (String data) {
      successCallback(data == "ok");
    };
  }

  Future<int> takeoff(TelloSuccessCallback successCallback) async {
    return await sendCommand("takeoff", _oeWrapper(successCallback));
  }

  /// [cmps] : 1 to 100 centimeters/second
  Future<int> setSpeed(int cmps, TelloSuccessCallback successCallback) async {
    cmps = (cmps * 27.7778).round().toInt();
    return await sendCommand("speed $cmps", _oeWrapper(successCallback));
  }

  /// [degrees] : Degrees to rotate, 1 to 360.
  Future<int> rotateCw(
      int degrees, TelloSuccessCallback successCallback) async {
    return await sendCommand("cw $degrees", _oeWrapper(successCallback));
  }

  /// [degrees] : Degrees to rotate, 1 to 360.
  Future<int> rotateCcw(
      int degrees, TelloSuccessCallback successCallback) async {
    return await sendCommand("ccw $degrees", _oeWrapper(successCallback));
  }

  /// [flipDirection] : Direction to flip, 'l', 'r', 'f', 'b'. use FlipDirection.l ...
  Future<int> flip(
      String flipDirection, TelloSuccessCallback successCallback) async {
    return await sendCommand(
        "flip $flipDirection", _oeWrapper(successCallback));
  }

  Future<int> land(TelloSuccessCallback successCallback) async {
    return await sendCommand("land", _oeWrapper(successCallback));
  }

  /// [distance] = [20, 500] cm
  Future<int> _move(String direction, int distance,
      TelloSuccessCallback successCallback) async {
    distance = max(20, distance);
    distance = min(500, distance);
    return await sendCommand(
        "$direction $distance", _oeWrapper(successCallback));
  }

  /// [distance] = [20, 500] cm
  Future<int> moveBackward(
      int distance, TelloSuccessCallback successCallback) async {
    return await _move("back", distance, successCallback);
  }

  /// [distance] = [20, 500] cm
  Future<int> moveDown(
      int distance, TelloSuccessCallback successCallback) async {
    return await _move("down", distance, successCallback);
  }

  /// [distance] = [20, 500] cm
  Future<int> moveForward(
      int distance, TelloSuccessCallback successCallback) async {
    return await _move("forward", distance, successCallback);
  }

  /// [distance] = [20, 500] cm
  Future<int> moveLeft(
      int distance, TelloSuccessCallback successCallback) async {
    return await _move("left", distance, successCallback);
  }

  Future<int> moveRight(
      int distance, TelloSuccessCallback successCallback) async {
    return await _move("right", distance, successCallback);
  }

  Future<int> moveUp(int distance, TelloSuccessCallback successCallback) async {
    return await _move("up", distance, successCallback);
  }

  void disconnect() {
    _listeners.clear();
    _cmdSubscription?.cancel();
    _cmd?.close();
    _cmd = null;
  }
}
