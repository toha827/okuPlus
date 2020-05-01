import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/models/Teacher.dart';
import 'package:flutterapp/models/TeacherCourse.dart';
import 'package:flutterapp/models/TeacherRequest.dart';
import 'package:flutterapp/models/course.dart';
import 'package:flutterapp/models/user.dart';
import 'package:flutterapp/screens/home/main_drawer.dart';
import 'package:flutterapp/services/auth.dart';
import 'package:flutterapp/services/database.dart';
import 'package:flutterapp/services/teacher_service.dart';

class RequestsList extends StatefulWidget {

  List<TeacherRequest> requests;

  RequestsList({this.requests});

  @override
  _RequestsListState createState() => _RequestsListState(requests: requests);
}

class _RequestsListState extends State<RequestsList> {

  final Firestore _db = Firestore.instance;
  DatabaseService _databaseService = DatabaseService();
  AuthService _authService = AuthService();
  TeacherService _teacherService;

  List<TeacherRequest> requests;
  Teacher currTeacher;
  List<Course> coursesName = [];
  List<List<User>> students = [];
  List<String> studentsUID = [];
  List<bool> studentsConfirmed = [];
  String uid;
  bool isExpand = false;

  _RequestsListState({this.requests});

  @override
  void initState() {
    _authService.CurrentUser.listen((event) {
      uid = event.uid;
      _teacherService = TeacherService(uid: uid);
      _teacherService.getTeacher().listen((event) {
        currTeacher = event;
      });
    });
    _databaseService.courses.listen((event) {
      requests.forEach((element) {
        event.forEach((element1) {
          if (element.courseId == element1.id){
           setState(() {
             coursesName.add(element1);
           });
          }
        });
      });
    });
    requests.forEach((element) {
      studentsUID = [];
      studentsUID.add(element.studentId);
      studentsCountStream(studentsUID).listen((event) {
        students.add(event);
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
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text('OkuPlus'),
        backgroundColor: Colors.blue[400],
        elevation: 0.0,
        actions: <Widget>[

        ],
      ),
      body: ListView.builder(
        itemBuilder: (context, position) {
        return Card(
        child: listItem(coursesName[position].name + " " + students[position][0].displayName, students[position], position),
        );
        },
        itemCount: requests.length,
        ));
  }
    Widget listItem(String title, List<User> list, int position) => Container(
    height: 300.0,
    color: Colors.white,
    child: Container(
            width: double.infinity,

            child: ListTile(
              title: Text(title,style: TextStyle(fontSize: 18)),
              trailing: ButtonTheme(
                  buttonColor: !requests[position].submitted ? Colors.green : Colors.red,
                  minWidth: 50.0,
                  height: 20.0,
                  child: RaisedButton(
                      child: !requests[position].submitted ? Icon(Icons.add) : Icon(Icons.cancel),
                      onPressed: () async {
                        setState(() {
                          requests[position].submitted = !requests[position].submitted;
                          currTeacher.teacherRequests = requests;
                        });
                        await _teacherService.updateTeacher(currTeacher);
                      })
              ),
            )
    ),
  );
}
