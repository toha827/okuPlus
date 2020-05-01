import 'package:flutterapp/models/question.dart';

class Schedule {
  String name;
  String desc;
  bool complete;
  DateTime complete_date;
  int pos;

  Schedule({
    this.name,
    this.desc,
    this.pos,
    this.complete,
    this.complete_date
  });

  Map<String,dynamic> toMap(){
    var map = new Map<String,dynamic>();
    map['name'] = name;
    map['desc'] = desc;
    map['pos'] = pos;
    map['complete'] = complete;
    map['complete_date'] = complete_date;
    return map;
  }
  Schedule.fromMap(Map<String,dynamic> map){
    this.name = map['name'] ?? 'Unknown Task';
    this.pos = map['pos'] ?? -1;
    this.desc = map['desc'] ?? '';
    this.complete = map['complete'] ?? false;
    this.complete_date = DateTime.fromMillisecondsSinceEpoch(map['complete_date'] == null ? new DateTime.now().millisecondsSinceEpoch : map['complete_date'].seconds * 1000);

  }
}