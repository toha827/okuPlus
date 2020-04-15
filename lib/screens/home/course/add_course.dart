import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/models/Teacher.dart';
import 'package:flutterapp/models/TeacherCourse.dart';
import 'package:flutterapp/models/course.dart';
import 'package:flutterapp/models/user.dart';
import 'package:flutterapp/services/auth.dart';
import 'package:flutterapp/services/database.dart';
import 'package:flutterapp/services/teacher_service.dart';
import 'package:flutterapp/shared/constants.dart';
import 'package:flutterapp/shared/loading.dart';
import 'package:image_picker/image_picker.dart';

class AddCourse extends StatefulWidget {
  @override
  _AddCourseState createState() => _AddCourseState();
}

class _AddCourseState extends State<AddCourse> {

  AuthService _authService = new AuthService();
  String photoUrl = '';
  final _formKey = GlobalKey<FormState>();

  final AuthService _auth = AuthService();
  final DatabaseService _dbService = DatabaseService();
  TeacherService teacherService;
  Teacher teacher;
  User CurrentUser;

  String name = '';
  String image = '';
  String description = '';
  int count;
  String error = '';

  bool loading = false;

  @override
  void initState() {
    _auth.profile
        .listen((event) {
          setState(() {
            CurrentUser = User.fromMap(event);
            teacherService = new TeacherService(uid: CurrentUser.uid);
            teacherService.getTeacher()
                .listen((event) {
                  setState(() {
                    teacher = event;
                  });
                });
          });
        });
    _dbService.courses.listen((event) {
      count = event.length;
    });

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return loading ?  Loading() : Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        elevation: 0.0,
        title: Text('Add Course'),
        actions: <Widget>[
        ],
      ),
      body: Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                new Container(
                  height: 250.0,
                  color: Colors.white,
                  child: new Column(
                    children: <Widget>[

                      Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: new Stack(fit: StackFit.loose, children: <Widget>[
                          new Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Container(
                                  width: 140.0,
                                  height: 140.0,
                                  decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: new DecorationImage(
                                      image: new NetworkImage(photoUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  )),
                            ],
                          ),
                          Padding(
                              padding: EdgeInsets.only(top: 90.0, right: 100.0),
                              child: new Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      chooseFile();
                                    },
                                    child:  new CircleAvatar(
                                      backgroundColor: Colors.red,
                                      radius: 25.0,
                                      child: new Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                ],
                              )),
                        ]),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  decoration: textInputDecoration.copyWith(hintText: 'Course Name'),
                  validator: (val) => val.isEmpty ? 'Enter a Name' : null,
                  onChanged: (val) {
                    setState(() => name = val);
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  obscureText: true,
                  decoration: textInputDecoration.copyWith(hintText: 'Description'),
                  validator: (val) => val.isEmpty ? 'Enter a Description' : null,
                  onChanged: (val) {
                    setState(() => description = val);
                  },
                ),
                SizedBox(height: 20.0,),
                RaisedButton(
                  color: Colors.blue[400],
                  child: Text(
                    'Add Course',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      setState(() => loading = true);

                      teacher.teacherCourses.add(TeacherCourse(courseId: count,students: []));
                      dynamic res = teacherService.updateTeacher(teacher);
                      dynamic result = await _dbService.addPost(Course.fromMap({'id': count, 'name': name, 'image': photoUrl, 'teacherId': teacher.uid, 'description': description}));
                      if (result == null) {
                        setState(() => {
                          error = 'Could not sing in with those credentials',
                          loading = false
                        });
                      }
                      Navigator.pop(context);
                    }
                  },
                ),
                SizedBox(height: 12.0),
                Text(
                  error,
                  style: TextStyle(color: Colors.red, fontSize: 14.0),
                ),
              ],
            ),
          )
      ),
    );
  }

  File _image;
  Future chooseFile() async {
    await ImagePicker.pickImage(source: ImageSource.gallery).then((image) {
      setState(() async {
        _image = image;
        if (_image != null) {
          await _authService.uploadFile(_image).then((value) =>
              value.getDownloadURL().then((url) =>
              photoUrl = url
              )
          );
        }
      });
    });
  }
}
