
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/models/user.dart';
import 'package:flutterapp/screens/wrapper.dart';
import 'package:flutterapp/services/auth.dart';
import 'package:flutterapp/shared/constants.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  AuthService _authService = new AuthService();
  double _value = 0.0;
  var _character;
  var _value2Changed;
  int value = 5;
  final IconData filledStar = Icons.star;
  final IconData unfilledStar = Icons.star_half;






  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
        stream: _authService.profile,
        builder: (context, snapshot){
          return Scaffold(
            appBar: AppBar(
              title: Text('OkuPlus'),
              backgroundColor: Colors.blue[400],
              elevation: 0.0,
              actions: <Widget>[
              ],
            ),
            body: Column(
                children: <Widget>[
                  Text(
                      "Text Size",
                      style: TextStyle(
                        color: Colors.black,
                      )
                  ),
                  new Slider(
                      value: _value,
                      onChanged: _setvalue),
                  ListTile(
                    title: const Text('Recieve Updates'),
                    leading: Radio(
                      value: true,
                      groupValue: _character,
                      onChanged: (value) {
                        setState(() {
                          _character = value;
                        });
                      },
                    ),
                  ),
                  new SwitchListTile(
                    value: true,
                    onChanged: (value) {},
                    title: new Text('Allow pop-up notifications', style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                  Text(
                      "Rate us",
                      style: TextStyle(
                        color: Colors.black,
                      )
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: onChanged != null
                            ? () {
                          onChanged(value == index + 1 ? index : index + 1);
                        }
                            : null,
                        color: index < value ? Colors.amber : null,
                        iconSize: 26.0,
                        icon: Icon(
                          index < value
                              ? filledStar ?? Icons.star
                              : unfilledStar ?? Icons.star_border,
                        ),
                        padding: EdgeInsets.zero,
                        tooltip: "${index + 1} of 5",
                      );
                    }),
                  )
                ]
            ),
          );
        });
  }
  void onChanged (int index) {
    value = index;
  }
  void _setvalue(double value) => setState(() => _value = value);

}
