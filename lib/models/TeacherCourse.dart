import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherCourse {
  int courseId;
  List<String> students;
  List<DateTime> timestamp;
  List<bool> confirmed;

  TeacherCourse({
    this.courseId,
    this.students,
    this.timestamp,
    this.confirmed
  });

  TeacherCourse.map(dynamic obj) {
    this.courseId = obj['courseId'];
    this.students = obj['students'];
    this.timestamp = obj['timestamp'];
    this.confirmed = obj['confirmed'];
  }

  TeacherCourse.fromMap(Map<String,dynamic> map){
    this.courseId = map['courseId'];
    List<dynamic> parsedJson = map['students'] ?? [];
    this.students = parsedJson.map((e) => e.toString()).toList();
    List<dynamic> parsedconfirmedJson = map['confirmed'] ?? [];
    this.confirmed = parsedconfirmedJson.map((e) => e as bool).toList();
    List<dynamic> parsedJson1 = map['timestamp'] ?? [];
    this.timestamp = parsedJson1.map((e) => DateTime.fromMillisecondsSinceEpoch(map['timestamp'] == null ? new DateTime.now().millisecondsSinceEpoch : e.seconds * 1000)).toList();
  }

  Map<String,dynamic> toMap(){
    var map = new Map<String,dynamic>();
    map['courseId'] = courseId;
    map['students'] = students;
    map['confirmed'] = confirmed;
    map['timestamp'] = timestamp;
    return map;
  }
}