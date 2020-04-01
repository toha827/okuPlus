import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/models/course.dart';
import 'package:flutterapp/models/myCourse.dart';
import 'package:flutterapp/services/auth.dart';
import 'package:flutterapp/services/myCourses.dart';

class CourseDetail extends StatefulWidget {
  Course course;
  String uid;
   CourseDetail(this.course, this.uid);

  @override
  _CourseDetailState createState() => _CourseDetailState(this.course,this.uid);
}

class _CourseDetailState extends State<CourseDetail> {
  Course course;
  String uid;
  MyCoursesService _myCoursesService;
  bool isBought = false;
  List<Course> list;
  _CourseDetailState(this.course, this.uid);

  final AuthService _auth = AuthService();
  @override
  void initState() {
      _myCoursesService = MyCoursesService(uid);
      _myCoursesService.courses.listen((event) {
        list = event ?? new List<Course>();
        event.forEach((element) {
          if(element.id == course.id) {
            setState(() {
              isBought = true;
            });
          }
        });
      });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
        stream: _auth.CurrentUser.map((event) => event.uid),
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Second Route"),
            ),
            body: Column(
                children: <Widget>[
            Image(
            image: NetworkImage(course.image),
            fit: BoxFit.fill,
            height: 200,
          ),
          SizedBox(height: 10.0),
          Text(
          course.name,
          style: TextStyle(fontSize: 20.0)
          ),
          SizedBox(height: 10.0),
          Text(course.description),
          new Visibility(
                  visible: !isBought,
                  child: RaisedButton(
                      color: Colors.blue[400],
                      child: Text(
                        'Add Course',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        list.add(course);
                        _myCoursesService.updateUserData(MyCourse(myCourses: list));
                      }
                  )
          )
        ],
      ),
    );
  });
  }
}
