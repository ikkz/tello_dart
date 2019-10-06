import 'package:flutter/material.dart';
import 'dart:async';

import 'text_edit_dialog.dart';

class SimpleDialogs {
  static Future<bool> alert(
      {@required BuildContext context,
      String title,
      @required String content}) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: title != null ? Text(title) : null,
            content: Text(
              content,
              style: Theme.of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Theme.of(context).textTheme.caption.color),
            ),
            actions: <Widget>[
              FlatButton(
                  child: Text("确认"),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  })
            ],
          );
        });
  }

  static Future<String> editText(
      {@required BuildContext context,
      @required String title,
      @required String defaultText}) {
    return showDialog<String>(
        context: context,
        builder: (context) {
          return TextEditDiaglog(
            title: title,
            defaultText: defaultText,
          );
        });
  }
}
