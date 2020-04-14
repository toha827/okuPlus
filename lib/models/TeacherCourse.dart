import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherCourse {
  int courseId;
  List<String> students;
  List<DateTime> timestamp;
  TeacherCourse({
    this.courseId,
    this.students,
    this.timestamp
  });

  TeacherCourse.map(dynamic obj) {
    this.courseId = obj['courseId'];
    this.students = obj['students'];
    this.timestamp = obj['timestamp'];
  }

  TeacherCourse.fromMap(Map<String,dynamic> map){
    this.courseId = map['courseId'];
    List<dynamic> parsedJson = map['students'] ?? [];
    this.students = parsedJson.map((e) => e.toString()).toList();
    List<dynamic> parsedJson1 = map['timestamp'] ?? [];
    this.timestamp = parsedJson1.map((e) => DateTime.fromMillisecondsSinceEpoch(map['birthDate'] == null ? new DateTime.now().millisecondsSinceEpoch : e.seconds * 1000)).toList();
  }

  Map<String,dynamic> toMap(){
    var map = new Map<String,dynamic>();
    map['courseId'] = courseId;
    map['students'] = students;
    map['timestamp'] = timestamp;
    return map;
  }
}