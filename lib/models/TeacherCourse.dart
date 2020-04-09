import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherCourse {
  int courseId;
  List<String> students;

  TeacherCourse({
    this.courseId,
    this.students
  });

  TeacherCourse.map(dynamic obj) {
    this.courseId = obj['courseId'];
    this.students = obj['students'];
  }

  TeacherCourse.fromMap(Map<String,dynamic> map){
    this.courseId = map['courseId'];
    List<dynamic> parsedJson = map['students'] ?? [];
    this.students = parsedJson.map((e) => e.toString()).toList();
  }

  Map<String,dynamic> toMap(){
    var map = new Map<String,dynamic>();
    map['courseId'] = courseId;
    map['students'] = students;
    return map;
  }
}