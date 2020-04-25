import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/models/TeacherCourse.dart';
import 'package:flutterapp/models/course.dart';
import 'package:flutterapp/models/user.dart';
import 'package:flutterapp/screens/home/main_drawer.dart';
import 'package:flutterapp/services/auth.dart';
import 'package:flutterapp/services/database.dart';

class StudentsList extends StatefulWidget {

  List<TeacherCourse> courses;

  StudentsList({this.courses});

  @override
  _StudentsListState createState() => _StudentsListState(courses: courses);
}

class _StudentsListState extends State<StudentsList> {

  final Firestore _db = Firestore.instance;
  DatabaseService _databaseService = DatabaseService();
  AuthService _authService = AuthService();

  List<TeacherCourse> courses;
  List<Course> coursesName = [];
  List<List<User>> students = [];
  List<String> studentsUID = [];

  bool isExpand = false;

  _StudentsListState({this.courses});

  @override
  void initState() {
    _databaseService.courses.listen((event) {
      courses.forEach((element) {
        event.forEach((element1) {
          if (element.courseId == element1.id){
           setState(() {
             coursesName.add(element1);
           });
          }
        });
      });
    });
    courses.forEach((element) {
      studentsUID = [];
      element.students.forEach((element1) {
        studentsUID.add(element1);
      });
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
        child: listItem(coursesName[position].name, students[position]),
        );
        },
        itemCount: courses.length,
        ));
  }
    Widget listItem(String title, List<User> list) => Container(
    height: 300.0,
    color: Colors.white,
    child: ExpansionTile(
        key: PageStorageKey(this.widget.key),
        title: Container(
            width: double.infinity,

            child: Text(title,style: TextStyle(fontSize: 18))
        ),
            trailing: Icon(Icons.arrow_drop_down,size: 32,color: Colors.pink,),
            onExpansionChanged: (value){
              setState(() {
                isExpand=value;
              });
            },
            children: getStudents(list)
        )
  );

  List<Widget> getStudents(List<User> list) {
    List<Widget> ll = [];
    list.forEach((element) {
      ll.add(Text(element.displayName,style: TextStyle(fontSize: 18),));
    });
    return ll;
  }
}
