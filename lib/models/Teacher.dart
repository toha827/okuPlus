
import 'package:flutterapp/models/TeacherCourse.dart';

class Teacher {

  String uid;
  List<TeacherCourse> teacherCourses;

  Teacher({
    this.uid,
    this.teacherCourses
  });

  Teacher.map(dynamic obj) {
    this.uid = obj['uid'];
    this.teacherCourses = obj['teacherCourses'];
  }

  Teacher.fromMap(Map<String,dynamic> map){
    this.uid = map['uid'];
    List<dynamic> parsedJson = map['teacherCourses'] ?? [];
    this.teacherCourses = parsedJson.map((e) => new TeacherCourse.fromMap(e)).toList();
  }

  Map<String,dynamic> toMap(){
    var map = new Map<String,dynamic>();
    map['uid'] = uid;
    map['teacherCourses'] = teacherCourses != null ? teacherCourses.map((e) => e.toMap()).toList() : [];
    return map;
  }
}