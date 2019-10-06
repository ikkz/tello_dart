# Tello无人机 dart demo

## lib/tello.dart

### 初始化
``` dart
_tello = Tello();

// 初始化连接，并设置无人机高度电量信息回调
await _tello.connect((h, bat) {
  debugPrint("height: $h, battery: $bat");
});
// 发送 command 命令进入无人机 SDK 模式才能发送后续命令s
_tello?.sendCommand("command", (s) {
  debugPrint(s);
});
```

### 发送命令
移动，翻转，旋转等，所有命令发送都是同步函数，可以设置无人机响应回调。
``` dart
_tello.land((bool success) {
  if (success) {
    debugPrint("降落成功");
  }
});
```

### 结束操作
```dart
// 同一 Tello 实例可多次 connect 与 disconnect
_tello.disconnect();
```
