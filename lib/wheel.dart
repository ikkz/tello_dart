import 'dart:math';

import 'package:flutter/material.dart';

class Wheel extends StatefulWidget {
  final double width;
  final double height;
  final double indicatorRadius;

  final Color backgroundColor;
  final Color foregroundColor;

  Wheel(
      {@required this.width,
      @required this.height,
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
      offset = Offset(
          offset.dx - widget.indicatorRadius < 0
              ? (_offset == null ? widget.width / 2 : _offset.dx)
              : offset.dx,
          offset.dy - widget.indicatorRadius < 0
              ? (_offset == null ? widget.height / 2 : _offset.dy)
              : offset.dy);
      offset = Offset(
          offset.dx + widget.indicatorRadius > widget.width
              ? (_offset == null ? widget.width / 2 : _offset.dx)
              : offset.dx,
          offset.dy + widget.indicatorRadius > widget.height
              ? (_offset == null ? widget.height / 2 : _offset.dy)
              : offset.dy);
    }
    this.setState(() {
      _offset = offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: GestureDetector(
        child: Center(
          child: Stack(
            children: <Widget>[
              CircleAvatar(
                foregroundColor: widget.backgroundColor ?? Colors.blue.shade300,
                radius: min(widget.width, widget.height) / 2,
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
