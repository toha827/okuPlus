import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherRequest {
  String studentId;
  int courseId;
  bool submitted;
  DateTime timestamp;

  TeacherRequest({
    this.courseId,
    this.studentId,
    this.timestamp,
    this.submitted
  });

  TeacherRequest.map(dynamic obj) {
    this.courseId = obj['courseId'];
    this.studentId = obj['studentId'];
    this.timestamp = obj['timestamp'];
    this.submitted = obj['submitted'];
  }

  TeacherRequest.fromMap(Map<String,dynamic> map){
    this.courseId = map['courseId'];
    this.studentId = map['studentId'];
    this.submitted = map['submitted'] as bool;
    this.timestamp = DateTime.fromMillisecondsSinceEpoch((map['timestamp'] as Timestamp).seconds * 1000);
  }

  Map<String,dynamic> toMap(){
    var map = new Map<String,dynamic>();
    map['courseId'] = courseId;
    map['studentId'] = studentId;
    map['timestamp'] = timestamp;
    map['submitted'] = submitted;
    return map;
  }
}