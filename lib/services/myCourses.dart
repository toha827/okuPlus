import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterapp/models/course.dart';
import 'package:flutterapp/models/myCourse.dart';
import 'package:flutterapp/services/auth.dart';
import 'package:rxdart/rxdart.dart';

class MyCoursesService {

  final String uid;
  BehaviorSubject<MyCourse> myCourses;
  // collection reference
  CollectionReference coursesCollection = Firestore.instance.collection('myCourses');


  MyCoursesService(this.uid) {
    myCourses = BehaviorSubject<MyCourse>();
  }

  Future<void> updateUserData(MyCourse myCourse) {
    print(myCourse.toMap());
    coursesCollection.document(uid).setData(myCourse.toMap());
  }

  List<Course> _coursesListFromSnapshot(DocumentSnapshot snapshot) {

    return MyCourse.fromJson(snapshot.data['myCourses']).myCourses;
  }

  Stream<List<Course>> get courses {
    return coursesCollection.document(uid).snapshots()
      .map(_coursesListFromSnapshot);
  }
}
