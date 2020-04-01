import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/models/user.dart';
import 'package:flutterapp/screens/home/home.dart';
import 'package:flutterapp/screens/home/profile.dart';
import 'package:flutterapp/screens/home/settings.dart';
import 'package:flutterapp/screens/home/myCourses.dart';
import 'package:flutterapp/services/auth.dart';
import 'package:flutterapp/shared/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainDrawer extends StatefulWidget {


  @override
  State<StatefulWidget> createState() => _MainDrawerState();

}
class _MainDrawerState extends State<MainDrawer>{

  User currentUser = new User("sss", "qwdqw", "", "www", "", "", "");
  AuthService authService = new AuthService();

  @override
  void initState() {

    authService.profile.listen((event) {
        setState(() {
          this.currentUser = User.fromMap(event);
        });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              color: Theme.of(context).primaryColor,
              child: Center(
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 100,
                      height: 100,
                      margin: EdgeInsets.only(
                        top: 30,
                        bottom: 10
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: NetworkImage(
                              currentUser.photoURL ?? 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80'),
//                                'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80'),
                            fit: BoxFit.fill),
                      ),
                     ),
                    Text(
                      currentUser.displayName,
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                      )
                    ),
                    Text(
                        currentUser.email,
                        style: TextStyle(
                          color: Colors.white,
                        )
                    )
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 18,
                  ),
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text(
                'Courses',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
              },
            ),
            new Visibility(
                visible: currentUser.userType == 'Student',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text(
                    'My Courses',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MyCoursesView()));
                  },
                ),
            ),

            ListTile(
              leading: Icon(Icons.settings),
              title: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Settings()));
              },
            ),
            ListTile(
              leading: Icon(Icons.arrow_back),
              title: Text(
                'Logout',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              onTap: null,
            )
          ],
        )
    );
  }


}
