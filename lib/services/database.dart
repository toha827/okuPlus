import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterapp/models/course.dart';

class DatabaseService {

  final String uid;
  DatabaseService({ this.uid });

  // collection reference
  final CollectionReference coursesCollection = Firestore.instance.collection('courses');

//  Future<void> updateUserData(String sugars, String name, int strength) async {
//    return await coursesCollection.document(uid).setData({
//      'sugars': sugars,
//      'name': name,
//      'strength': strength,
//    });
//  }

  Future addPost(Course course) async {
    try {
      await coursesCollection.add(course.toMap());
      return true;
    } catch (e) {
      return e.toString();
    }
  }

  List<Course> _coursesListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc){
      return Course(
        id: doc.data['id'],
        name: doc.data['name'] ?? '',
        description: doc.data['description'] ?? '',
        image: doc.data['image'] ?? '',
        tag: doc.data['tag'] ?? ''
      );
    }).toList();
  } 

  Stream<List<Course>> get courses {
    return coursesCollection.snapshots()
      .map(_coursesListFromSnapshot);
  }
}
