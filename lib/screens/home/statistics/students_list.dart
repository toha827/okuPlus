import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/models/Teacher.dart';
import 'package:flutterapp/models/TeacherCourse.dart';
import 'package:flutterapp/models/course.dart';
import 'package:flutterapp/models/user.dart';
import 'package:flutterapp/screens/home/main_drawer.dart';
import 'package:flutterapp/services/auth.dart';
import 'package:flutterapp/services/database.dart';
import 'package:flutterapp/services/teacher_service.dart';

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
  TeacherService _teacherService;

  List<TeacherCourse> courses;
  List<Course> coursesName = [];
  List<List<User>> students = [];
  List<String> studentsUID = [];
  List<bool> studentsConfirmed = [];
  String uid;
  bool isExpand = false;

  _StudentsListState({this.courses});

  @override
  void initState() {
    _authService.CurrentUser.listen((event) {
      uid = event.uid;
      _teacherService = TeacherService(uid: uid);
    });
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
        child: listItem(coursesName[position] == null ? "" : "dd", students[position] ?? null, position),
        );
        },
        itemCount: courses.length,
        ));
  }
    Widget listItem(String title, List<User> list, int position) => Container(
    height: 300.0,
    color: Colors.white,
    child: list != null ? ExpansionTile(
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
            children: getStudents(list,position)
        ) : Text("No Students")
  );

  List<Widget> getStudents(List<User> list,int position) {
    List<Widget> ll = [];
    for(int i = 0; i < list.length; i++){
      ll.add(
        ListTile(
          title: Text(list[i].displayName,style: TextStyle(fontSize: 18)),
//          trailing: ButtonTheme(
//            buttonColor: !courses[position].confirmed[i] ? Colors.green : Colors.red,
//            minWidth: 50.0,
//            height: 20.0,
//            child: RaisedButton(
//                child: Icon(Icons.add),
//                onPressed: () async {
//                  setState(() {
//                    courses[position].confirmed[i] = !courses[position].confirmed[i];
//                  });
//                  Teacher updateTeacher = new Teacher(uid: uid,teacherCourses: courses);
//                  await _teacherService.updateTeacher(updateTeacher);
//                })
//        ),
        )
      );
    }
    return ll;
  }
}
