import 'package:flutter/material.dart';

class Wheel extends StatefulWidget {
  final double radius;

  final Color backgroundColor;
  final Color foregroundColor;

  final void Function(WheelDirection wheelDirection) directionCallback;

  Wheel(
      {@required this.radius,
      @required this.directionCallback,
      this.backgroundColor,
      this.foregroundColor});

  @override
  _WheelState createState() => _WheelState();
}

enum WheelDirection { Forward, Backward, Left, Right }

class _WheelState extends State<Wheel> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.radius * 2,
      height: widget.radius * 2,
      child: Center(
        child: Stack(
          children: <Widget>[
            CircleAvatar(
              foregroundColor: widget.backgroundColor ?? Colors.blue.shade100,
              radius: widget.radius,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.arrow_upward,
                    color: Colors.white,
                  ),
                  onPressed: () =>
                      widget.directionCallback(WheelDirection.Forward),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    width: widget.radius * 2,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.arrow_downward,
                    color: Colors.white,
                  ),
                  onPressed: () =>
                      widget.directionCallback(WheelDirection.Backward),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: () =>
                      widget.directionCallback(WheelDirection.Left),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    width: widget.radius * 2,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  ),
                  onPressed: () =>
                      widget.directionCallback(WheelDirection.Right),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
