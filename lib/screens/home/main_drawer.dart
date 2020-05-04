import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/models/user.dart';
import 'package:flutterapp/screens/home/home.dart';
import 'package:flutterapp/screens/home/homepage.dart';
import 'package:flutterapp/screens/home/profile.dart';
import 'package:flutterapp/screens/home/promo.dart';
import 'package:flutterapp/screens/home/schedule/schedule.dart';
import 'package:flutterapp/screens/home/settings.dart';
import 'package:flutterapp/screens/home/myCourses.dart';
import 'package:flutterapp/screens/home/statistics/my_statistics.dart';
import 'package:flutterapp/screens/teacher/my_teacher_courses.dart';
import 'package:flutterapp/screens/wrapper.dart';
import 'package:flutterapp/services/auth.dart';
import 'package:flutterapp/shared/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainDrawer extends StatefulWidget {


  @override
  State<StatefulWidget> createState() => _MainDrawerState();

}
class _MainDrawerState extends State<MainDrawer>{

  User currentUser = new User();
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
        child: ListView(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(5),
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
                                image: currentUser.photoURL == "" ? AssetImage('assets/profile.png') : NetworkImage(currentUser.photoURL),
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
                  leading: Icon(Icons.card_giftcard),
                  title: Text(
                    'Promo',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Promo()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.calendar_today),
                  title: Text(
                    'Schedule',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MySchedule()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.view_list),
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
                    leading: Icon(Icons.personal_video),
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
                new Visibility(
                  visible: currentUser.userType == 'Teacher' || currentUser.userType == 'Admin',
                  child: ListTile(
                    leading: Icon(Icons.graphic_eq),
                    title: Text(
                      'My Statistics',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MyStatistics()));
                    },
                  ),
                ),
                new Visibility(
                  visible: currentUser.userType == 'Teacher',
                  child: ListTile(
                    leading: Icon(Icons.short_text),
                    title: Text(
                      'My Teaching Courses',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MyTeachingCourses()));
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
                  onTap: () async {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Wrapper()));
                    await authService.signOut();
                  },
                )
              ],
            )
          ],
        )
    );
  }


}
