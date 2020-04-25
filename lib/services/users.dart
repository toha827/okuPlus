import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterapp/models/top.dart';

class TopService {

  final String uid;
  TopService({ this.uid }){
    getMyTop();
  }

  // collection reference
  final CollectionReference topCollection = Firestore.instance.collection('top');

// Streams
  StreamController<Top> _teacherCoursesController = StreamController();
  Stream<Top> get teacherCoursesStream => _teacherCoursesController.stream;

  void getMyTop() {
    topCollection.document(uid).snapshots()
        .listen((snap){
          this._teacherCoursesController.sink.add(Top.fromMap(snap.data));
        });
  }

  Future updateTop(Top top) async {
    try {
      await topCollection.document(uid).setData(top.toMap());
      return true;
    } catch (e) {
      return e.toString();
    }
  }

  List<Top> _topsListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc){
      return Top.fromMap(doc.data);
    }).toList();
  } 

  Stream<List<Top>> get tops {
    return topCollection.snapshots()
      .map(_topsListFromSnapshot);
  }
}
