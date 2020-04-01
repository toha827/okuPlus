import 'package:flutter/material.dart';
import 'package:flutterapp/models/user.dart';
import 'package:flutterapp/screens/wrapper.dart';
import 'package:flutterapp/services/auth.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  AuthService _authService = new AuthService();
  User currUser;

  @override
  void initState() {
    _authService.profile.listen((event) {
      setState(() {
        currUser = User.fromMap(event);
      });
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: Text('OkuPlus'),
            backgroundColor: Colors.blue[400],
            elevation: 0.0,
            actions: <Widget>[
              FlatButton.icon(
                  icon: Icon(Icons.person),
                  label: Text('logout'),
                  onPressed: () async {
                    await _authService.signOut();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Wrapper()));
                  }
              )
            ],
          ),
          body: Column(
            children: <Widget>[
              Text(
                  "Email : " + currUser.email ?? '',
                  style: TextStyle(
                    color: Colors.white,
                  )
              ),
              Text(
                  "DisplayName : " + currUser.displayName ?? '',
                  style: TextStyle(
                    color: Colors.white,
                  )
              ),
              Text(
                  "UserType : " + currUser.userType ?? '',
                  style: TextStyle(
                    color: Colors.white,
                  )
              ),
            ],
          ),
        );
  }
}
