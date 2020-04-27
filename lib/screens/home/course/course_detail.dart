import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/models/Teacher.dart';
import 'package:flutterapp/models/TeacherCourse.dart';
import 'package:flutterapp/models/course.dart';
import 'package:flutterapp/models/myCourse.dart';
import 'package:flutterapp/screens/home/course/test.dart';
import 'package:flutterapp/screens/home/course/video_course.dart';
import 'package:flutterapp/services/auth.dart';
import 'package:flutterapp/services/myCourses.dart';
import 'package:flutterapp/services/teacher_service.dart';
import 'package:flutterapp/shared/cardDetatil.dart';
import 'package:flutterapp/shared/common.dart';
import 'package:flutterapp/shared/loading.dart';
import 'package:flutterapp/shared/textStyle.dart';


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
  TeacherService _teacherService;
  Teacher _teacher;
  bool isBought = false;
  List<Course> list = [];

  bool isExpand = false;
  _CourseDetailState(this.course, this.uid);
  bool isLoading = true;
  final AuthService _auth = AuthService();
  @override
  void initState() {
    _auth.CurrentUser.listen((event) {
      setState(() {
        uid = event.uid;
        _myCoursesService = MyCoursesService(event.uid);
        _teacherService = TeacherService(uid: course.teacherId);
      });
      _myCoursesService.courses.listen((el) {
        list = el ?? new List<Course>();
        el.forEach((element) {
          if(element.id == course.id) {
            setState(() {
              isBought = true;
            });
          }
        });
      });
      _teacherService.getTeacher().listen((el) {
        setState(() {
          _teacher = el;
          isLoading = false;
        });
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? new Loading() : new Scaffold(
              body: new Container(
            constraints: new BoxConstraints.expand(),
            color: new Color(0xFF736AB7),
            child: new Stack (
              children: <Widget>[
                _getBackground(),
                _getGradient(),
                _getContent(),
                _getToolbar(context),
              ],
            ),
          ),
        );
  }
  Container _getBackground () {
    var _opacity = 1.0;
    var _xOffset = 0.0;
    var _yOffset = 0.0;
    var _blurRadius = 10.0;
        return new Container(
              child:  Image.network(course.image,
                fit: BoxFit.cover,
                height: 300.0,
              ),
            constraints: new BoxConstraints.expand(height: 300.0),
        );
  }

  Container _getGradient() {
        return new Container(
          margin: new EdgeInsets.only(top: 190.0),
          height: 110.0,
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
              colors: <Color>[
                new Color(0x00736AB7),
                new Color(0xFF736AB7)
              ],
              stops: [0.0, 0.9],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(0.0, 1.0),
            ),
          ),
        );
      }

  Widget _getContent() {
        return StreamBuilder<String>(
        stream: _auth.CurrentUser.map((event) => event.uid),
        builder: (context, snapshot) {
          return Container(
            child: new ListView(
              padding: new EdgeInsets.fromLTRB(0.0, 72.0, 0.0, 32.0),
              children: <Widget>[
                new PlanetSummary(course,
                  horizontal: false,
                ),
                new Container(
                  padding: new EdgeInsets.symmetric(horizontal: 32.0),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(course.name,
                        style: Style.headerTextStyle,),
                      new Separator(),
                      new Text(
                          course.description, style: Style.commonTextStyle),
                    ],
                  ),
                ),
                ExpansionTile(
                    key: PageStorageKey(this.widget.key),
                    title: Container(
                        width: double.infinity,

                        child: Text("Course Detail",style: TextStyle(fontSize: 18))
                    ),
                    trailing: Icon(Icons.arrow_drop_down,size: 32,color: Colors.pink,),
                    onExpansionChanged: (value){
                      setState(() {
                        isExpand=value;
                      });
                    },
                    children: <Widget>[
                      Text(course.courseDetail)
                    ],
                ),
                ListTile(
                  leading: Text("Lessons"),
                ),
                ListTile(
                  leading: Icon(Icons.video_library),
                  title: Text("Promo Video"),
                  onTap: () => {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => VideoCourse(course.lesson)))
                  },
                ),
                new Visibility(
                visible: isBought,
                child: RaisedButton(
                    color: Colors.blue[400],
                    child: Text(
                      'Questions',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Test(questions: course.questions)));
                    }
                ),
                ),
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
                            _teacher.teacherCourses.forEach((element) {
                              if( element.courseId == course.id) {
                                element.students.add(uid);
                                element.timestamp.add(DateTime.now());
                              }
                            });
                            _teacherService.updateTeacher(_teacher);
                            _myCoursesService.updateUserData(MyCourse(myCourses: list));
                          }
                      )
                ) 
              ],
            ),
          );
        });

  }

  Container _getToolbar(BuildContext context) {
        return new Container(
            margin: new EdgeInsets.only(
                top: MediaQuery
                    .of(context)
                        .padding
                        .top),
                child: new BackButton(color: Colors.white),
              );
      }
//    return StreamBuilder<String>(
//        stream: _auth.CurrentUser.map((event) => event.uid),
//        builder: (context, snapshot) {
//          return Scaffold(
//            appBar: AppBar(
//              title: Text("Second Route"),
//            ),
//            body: Column(
//                children: <Widget>[
//            Image(
//            image: NetworkImage(course.image),
//            fit: BoxFit.fill,
//            height: 200,
//          ),
//          SizedBox(height: 10.0),
//          Text(
//          course.name,
//          style: TextStyle(fontSize: 20.0)
//          ),
//          SizedBox(height: 10.0),
//          Text(course.description),
//          new Visibility(
//                  visible: !isBought,
//                  child: RaisedButton(
//                      color: Colors.blue[400],
//                      child: Text(
//                        'Add Course',
//                        style: TextStyle(color: Colors.white),
//                      ),
//                      onPressed: () {
//                        list.add(course);
//                        _myCoursesService.updateUserData(MyCourse(myCourses: list));
//                      }
//                  )
//          )
//        ],
//      ),
//    );
//  });
//  }
}