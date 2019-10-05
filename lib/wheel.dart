import 'dart:math';

import 'package:flutter/material.dart';

class Wheel extends StatefulWidget {
  final double radius;
  final double indicatorRadius;

  final Color backgroundColor;
  final Color foregroundColor;

  Wheel(
      {@required this.radius,
      @required this.indicatorRadius,
      this.backgroundColor,
      this.foregroundColor});

  @override
  _WheelState createState() => _WheelState();
}

class _WheelState extends State<Wheel> {
  Offset _offset;

  void _updateOffset(Offset offset) {
    if (offset != null) {
      var angle = asin((offset.dy - widget.radius) /
          sqrt((offset.dx - widget.radius) * (offset.dx - widget.radius) +
              (offset.dy - widget.radius) * (offset.dy - widget.radius)));
      offset = Offset(
          widget.radius +
              (offset.dx > widget.radius
                  ? (widget.radius - widget.indicatorRadius) * cos(angle)
                  : (widget.indicatorRadius - widget.radius) * cos(angle)),
          widget.radius +
              (widget.radius - widget.indicatorRadius) * sin(angle));
    }
    this.setState(() {
      _offset = offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.radius * 2,
      height: widget.radius * 2,
      child: GestureDetector(
        child: Center(
          child: Stack(
            children: <Widget>[
              CircleAvatar(
                foregroundColor: widget.backgroundColor ?? Colors.blue.shade300,
                radius: widget.radius,
              ),
              _offset == null
                  ? Container()
                  : Padding(
                      child: CircleAvatar(
                        foregroundColor:
                            widget.foregroundColor ?? Colors.blue.shade700,
                        radius: widget.indicatorRadius,
                      ),
                      padding: EdgeInsets.fromLTRB(
                          _offset.dx - widget.indicatorRadius,
                          _offset.dy - widget.indicatorRadius,
                          0,
                          0),
                    )
            ],
          ),
        ),
        onPanUpdate: (detail) => _updateOffset(detail.localPosition),
        onPanStart: (detail) => _updateOffset(detail.localPosition),
        onPanEnd: (detail) => _updateOffset(null),
      ),
    );
  }
}
