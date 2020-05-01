import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterapp/models/schedule.dart';

class User {

  String uid;
  String fullName;
  String displayName;
  String email;
  DateTime birthDate;
  String photoURL;
  String userType;
  String userState;
  String userInterest;
  String userPurpose;
  List<String> subscribers;
  List<Schedule> schedule;

  User({
    this.uid,
    this.fullName,
    this.email,
    this.displayName,
    this.birthDate,
    this.photoURL,
    this.userType,
    this.userState,
    this.userInterest,
    this.userPurpose,
    this.subscribers,
    this.schedule
  });

  User.map(dynamic obj) {
    this.uid = obj['uid'];
    this.email = obj['email'];
    this.fullName = obj['fullName'];
    this.displayName = obj['displayName'];
    this.birthDate = obj['birthDate'];
    this.photoURL = obj['photoURL'];
    this.userType = obj['userType'];
    this.subscribers = obj['subscribers'];
    this.schedule = obj['schedule'];
  }

//  String get uid => _uid;
//  set uid(String val) => uid = val;
//  String get email => _email;
//  String get firstName => _fullName;
//  String get displayName => _displayName;
//  DateTime get birthDate => _birthDate;
//  set birthDate(DateTime val) => _birthDate = val;
//  String get photoURL => _photoURL;
//  String get userType => _userType;

  User.fromMap(Map<String,dynamic> map){
    this.uid = map['uid'];
    this.email = map['email'];
    this.fullName = map['fullName'] ?? '';
    this.displayName = map['displayName'] ?? '';
    this.photoURL = map['photoURL'] ?? '';
    this.birthDate = DateTime.fromMillisecondsSinceEpoch(map['birthDate'] == null ? new DateTime.now().millisecondsSinceEpoch : map['birthDate'].seconds * 1000);
    this.userType = map['userType'] ?? '';
    this.userState = map['userState'] ?? '';
    this.userPurpose = map['userPurpose'] ?? '';
    this.userInterest = map['userInterest'] ?? '';
    List<dynamic> parsedJson = map['subscribers'] ?? [];
    this.subscribers = parsedJson.map((e) => e.toString()).toList();
    List<dynamic> parsedSchedule = map['schedule'] ?? [];
    this.schedule = parsedSchedule.map((e) => new Schedule.fromMap(e)).toList();
  }

  Map<String,dynamic> toMap(){
    var map = new Map<String,dynamic>();
    map['uid'] = uid;
    map['email'] = email;
    map['fullName'] = fullName;
    map['displayName'] = displayName;
    map['birthDate'] = birthDate;
    map['photoURL'] = photoURL;
    map['userType'] = userType;
    map['userState'] = userState;
    map['userInterest'] = userInterest;
    map['userPurpose'] = userPurpose;
    map['subscribers'] = subscribers;
    map['schedule'] = schedule != null ? schedule.map((e) => e.toMap()).toList() : [];
    return map;
  }
}