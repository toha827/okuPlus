import 'dart:async';
import 'dart:developer';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterapp/models/Teacher.dart';
import 'package:flutterapp/models/course.dart';
import 'package:flutterapp/services/database.dart';

class TeacherService {

  final String uid;
  Teacher currentTeacher;
  List teacherCourses = [];
  DatabaseService databaseService;

  TeacherService({ this.uid }) {
    databaseService = new DatabaseService(uid: uid);
    getTeacher().listen((event) {
      currentTeacher = event;
      teacherCourses = [];
      currentTeacher.teacherCourses.forEach((element) {
        teacherCourses.add(element.courseId);
      });
      updateCourses();
    });
  }

  // Streams
  StreamController<List<Course>> _teacherCoursesController = StreamController();
  Stream<List<Course>> get teacherCoursesStream => _teacherCoursesController.stream;

  void updateCourses() {
    courses.listen((event) {
      this._teacherCoursesController.sink.add(event);
    });
  }

  // collection reference
  final CollectionReference coursesCollection = Firestore.instance.collection('courses');
  final CollectionReference teachersCollection = Firestore.instance.collection('teachers');

  Future updateTeacher(Teacher teacher) async {
    try {
      await teachersCollection.document(uid).setData(teacher.toMap());
      return true;
    } catch (e) {
      return e.toString();
    }
  }

  Stream<Teacher> getTeacher() {
    return teachersCollection
        .document(uid).snapshots()
        .map((event) =>
          Teacher.fromMap(event.data)
        );
  }

  Stream<List<Course>> get courses {

    return coursesCollection.where('id', whereIn: teacherCourses).snapshots()
        .map(_coursesListFromSnapshot);

  }

  List<Course> _coursesListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc){
      return Course.fromMap(doc.data);
    }).toList();
  }

  List<Teacher> _teachersListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc){
      return Teacher.fromMap(doc.data);
    }).toList();
  }

  Stream<List<Teacher>> get teachers {
    return teachersCollection.snapshots()
        .map(_teachersListFromSnapshot);
  }
}
