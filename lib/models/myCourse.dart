import 'package:flutterapp/models/course.dart';

class MyCourse {
  List<Course> myCourses;

  MyCourse({this.myCourses});

  Map<String,dynamic> toMap(){
    var map = new Map<String,dynamic>();
    map['myCourses'] = myCourses.map((e) => e.toMap()).toList();
    return map;
  }
  factory MyCourse.fromJson(List<dynamic> parsedJson){
    List<Course> _myCourses = parsedJson.map((i) {
      return Course(
        name: i['name'],
        description: i['description'],
        image: i['image'],
        id: i['id'] is int ? i['id'] : int.parse(i['id'])
      );}).toList();
    return new MyCourse(
      myCourses: _myCourses,
    );
  }
}