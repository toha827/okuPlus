import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterapp/models/Teacher.dart';
import 'package:flutterapp/models/course.dart';

class TeacherService {

  final String uid;
  TeacherService({ this.uid });

  // collection reference
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

  List<Teacher> _coursesListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc){
      return Teacher.fromMap(doc.data);
    }).toList();
  }

  Stream<List<Teacher>> get teachers {
    return teachersCollection.snapshots()
        .map(_coursesListFromSnapshot);
  }
}
