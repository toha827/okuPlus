import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/models/course.dart';
import 'package:flutterapp/models/user.dart';
import 'package:flutterapp/screens/wrapper.dart';
import 'course_list.dart';
import 'package:flutterapp/screens/home/main_drawer.dart';
import 'package:flutterapp/services/auth.dart';
import 'package:flutterapp/services/myCourses.dart';
import 'package:provider/provider.dart';
import 'add_course.dart';


class MyCoursesView extends StatelessWidget {

  final AuthService _auth = AuthService();
  bool isTeacher = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
        stream: _auth.CurrentUser.map((event) => event.uid),
        builder: (context, snapshot) {
          return StreamProvider<List<Course>>.value(
          value: MyCoursesService(snapshot.data).courses,
          child: Scaffold(
              backgroundColor: Colors.blue[50],
              appBar: AppBar(
                title: Text('OkuPlus'),
                backgroundColor: Colors.blue[400],
                elevation: 0.0,
                actions: <Widget>[
                  FlatButton.icon(
                      icon: Icon(Icons.person),
                      label: Text('logout'),
                      onPressed: () async {
                        await _auth.signOut();
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Wrapper()));
                      }
                  )
                ],
              ),
              drawer: MainDrawer(),
              body: CourseList()
          )
      );
    });
  }

}