
import 'package:flutterapp/models/TeacherCourse.dart';
import 'package:flutterapp/models/TeacherRequest.dart';

class Teacher {

  String uid;
  List<TeacherCourse> teacherCourses;
  List<TeacherRequest> teacherRequests;
  int rating;

  Teacher({
    this.uid,
    this.teacherCourses,
    this.rating,
    this.teacherRequests
  });

  Teacher.map(dynamic obj) {
    this.uid = obj['uid'];
    this.teacherCourses = obj['teacherCourses'];
    this.rating = obj['rating'];
    this.teacherRequests = obj['teacherRequests'];
  }

  Teacher.fromMap(Map<String,dynamic> map){
    this.uid = map['uid'];
    this.rating = map['rating'] ?? 0;
    List<dynamic> parsedJson = map['teacherCourses'] ?? [];
    this.teacherCourses = parsedJson.map((e) => new TeacherCourse.fromMap(e)).toList();
    List<dynamic> parsedRequestJson = map['teacherRequests'] ?? [];
    this.teacherRequests = parsedRequestJson.map((e) => new TeacherRequest.fromMap(e)).toList();
  }

  Map<String,dynamic> toMap(){
    var map = new Map<String,dynamic>();
    map['uid'] = uid;
    map['rating'] = rating;
    map['teacherCourses'] = teacherCourses != null ? teacherCourses.map((e) => e.toMap()).toList() : [];
    map['teacherRequests'] = teacherRequests != null ? teacherRequests.map((e) => e.toMap()).toList() : [];
    return map;
  }
}