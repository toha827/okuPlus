import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterapp/models/Teacher.dart';
import 'package:flutterapp/models/course.dart';
import 'package:flutterapp/models/myCourse.dart';
import 'package:flutterapp/models/schedule.dart';
import 'package:flutterapp/models/user.dart';
import 'package:flutterapp/screens/wrapper.dart';
import 'package:flutterapp/services/auth.dart';
import 'package:flutterapp/services/database.dart';
import 'package:flutterapp/services/myCourses.dart';
import 'package:flutterapp/services/teacher_service.dart';
import 'package:image_picker/image_picker.dart';

class Promo extends StatefulWidget {
  @override
  _PromoState createState() => _PromoState();
}

class _PromoState extends State<Promo>{
  bool _status = true;
  AuthService _authService = new AuthService();
  final Firestore _db = Firestore.instance;

  MyCoursesService _myCoursesService;
  TeacherService _teacherService;
  final DatabaseService _databaseService = DatabaseService();
  bool isChecked = false;
  User currUser;
  String promo = '';
  String fullName = '';
  String email = '';
  DateTime birthDate;
  List<User> users = [];
  List<String> subscribers = [];
  List<Course> list = [];
  List<Course> courses = [];

  @override
  void initState() {
    _authService.profile.listen((event2) {
      setState(() {
        currUser = User.fromMap(event2);
        birthDate = currUser.birthDate;
        _myCoursesService = MyCoursesService(currUser.uid);
        subscribers = currUser.subscribers;
      });
      promoGet();
      StudentsList();
    });
    super.initState();
  }

  Future<void> promoGet() async {
    _myCoursesService.courses.listen((event) {
      setState(() {
        list = event ?? [];
      });
      _databaseService.courses.listen((event1) {
        event1.forEach((element1) {
          bool isHave = false;
          list.forEach((element2) {
            if (element1.id == element2.id) {
              isHave = true;
            }
          });
          if (!isHave) {
            setState(() {
              courses.add(element1);
            });
          }
        });
        for (int i = 0; i < subscribers.length / 2; i++) {
          if (courses.length > 0) {
            Course temp = courses[0];
            setState(() {
              courses.removeAt(0);
              subscribers.removeRange(0, 2);
            });
            AddCourseFromPromo(temp, temp.teacherId);
          }
          setState(() {
            currUser.subscribers = subscribers;
            if (courses.length == 0) {
              createQuestionDialog(context, "You have already get course");
            } else {
              createQuestionDialog(context, courses[0].name);
            }
          });
        }
      });
    });
  }

  void StudentsList() {
    if(currUser.subscribers.length == 0){
      setState(() {
        users = [];
      });
    } else {
      studentsCountStream(currUser.subscribers).listen((event) {
        setState(() {
          users = event;
        });
      });
    }
  }

  Future createQuestionDialog(BuildContext context, String courseName){
    return showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text("You get new Course " + courseName),
        content: Column(
            children: <Widget>[
            ]
        ),
        actions: <Widget>[
          MaterialButton(
            elevation: 3.0,
            child: Text("Ok"),
            onPressed: (){
              Navigator.pop(context);
            },
          )
        ],
      );
    });
  }

  bool contains(Course element, List<Course> list) {
    for (Course e in list) {
      if (e.id == element.id) return true;
    }
    return false;
  }

  AddCourseFromPromo(Course course, String teacherUid) {
    currUser.schedule.add(new Schedule(name: course.name, desc: "Lesson", complete: false, complete_date: course.course_date));
    _authService.updateUserrData(currUser.uid, currUser);
    Teacher _teacher;
    _teacherService = TeacherService(uid: teacherUid);
    _teacherService.getTeacher().listen((event) async {
      setState(() {
        _teacher = event;
        _teacher.teacherCourses.forEach((element) {
          if( element.courseId == course.id) {
            element.students.add(currUser.uid);
            element.timestamp.add(DateTime.now());
            element.confirmed.add(false);
          }
          if (!contains(course,list)) {
            list.add(course);
          }
        });
      });
      _teacherService.updateTeacher(_teacher);
      await _myCoursesService.updateUserData(MyCourse(myCourses: list));
    });

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
                              _authService.updateUserrData(promo, user);
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
