import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterapp/models/user.dart';
import 'package:flutterapp/screens/wrapper.dart';
import 'package:flutterapp/services/auth.dart';
import 'package:image_picker/image_picker.dart';

class Promo extends StatefulWidget {
  @override
  _PromoState createState() => _PromoState();
}

class _PromoState extends State<Promo>{
  bool _status = true;
  AuthService _authService = new AuthService();
  final Firestore _db = Firestore.instance;

  User currUser;
  String promo = '';
  String fullName = '';
  String email = '';
  DateTime birthDate;
  List<User> users = [];

  @override
  void initState() {
    _authService.profile.listen((event) {
      setState(() {
        currUser = User.fromMap(event);
        birthDate = currUser.birthDate;
      });
      studentsCountStream(currUser.subscribers).listen((event) {
        users = event;
      });
    });

    super.initState();
  }
  Stream<List<User>> studentsCountStream(List<String> list) {
    return _db.collection('users').where('uid', whereIn: list).snapshots()
        .map(_coursesListFromSnapshot);
  }

  List<User> _coursesListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc){
      return User.fromMap(doc.data);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
          new Container(
            color: Colors.white,
            child: new Column(
              children: <Widget>[
                ListTile(
                  title: new Text('Enter Promocode'),
                  subtitle: new TextField(
                    decoration: const InputDecoration(
                      hintText: "Enter Code",
                    ),
                    onChanged: (val) => promo = val,
                  ),
                  trailing: new RaisedButton(
                      child: new Text('Enter'),
                      onPressed: () async {
                          User user;
                          getUser().listen((event) {
                            user = event;
                            if (!event.subscribers.contains(currUser.uid) ) {
                              user.subscribers.add(currUser.uid);
                              _authService.updateUserData(promo, user);
                            }
                          });
                      }),
                ),
                ListTile(
                  title: new Text('Invite Friends'),
                  subtitle: new RaisedButton(
                      child: new Text('Copy to Clipboard'),
                      onPressed: () {
                        if (currUser != null) {
                          Clipboard.setData(
                              ClipboardData(text: currUser.uid));
                        }
                      }),
                ),
                ListTile(
                  title: Text("You have collected " + currUser.subscribers.length.toString() + "/10"),
                  subtitle: Text("To get reward you need to collect at least 10"),
                ),
                Container(
                  height: 100,
                  child: users.length > 0 ? ListView.builder(
                      itemCount: users == null ? 0 : users.length,
                      itemBuilder: (context, index){
                        return Card(
                          child: Column(
                              children: <Widget>[
                                ListTile(
                                  title: Text(users[index].displayName),
                                ),
                              ]
                          ),
                        );
                      }) : Text("You don't have any subscribes")
                )
            ]),
          ),

        ],
      ),
    );
  }

  Stream<User> getUser() {
    return _db.collection('users').document(promo).snapshots().map((event) =>
        User.fromMap(event.data)
    );
  }
}
