import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/models/course.dart';
import 'package:flutterapp/screens/home/course_detail.dart';
import 'package:provider/provider.dart';

class CourseList extends StatefulWidget {
  @override
  _CourseListState createState() => _CourseListState();
}

class _CourseListState extends State<CourseList> {

  List arr = ["1", "2", "2", "2","2", "2","2", "2"];
  String uid;


  @override
  void initState() {

    FirebaseAuth.instance.onAuthStateChanged.listen((event) {
      setState(() {
        uid = event.uid;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final courses = Provider.of<List<Course>>(context);
    return ListView.builder(
        itemCount: courses == null ? 0 : courses.length,
        itemBuilder: (context, index){
          return Card(
              child: Column(
                  children: <Widget>[
                    Image(
                      height: 100,
                      image: NetworkImage(courses[index].image),
                      fit: BoxFit.fill,
                    ),
                    ListTile(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => CourseDetail(courses[index], uid)));
                      },
                      title: Text(courses[index].tag),
                    ),
                  ]
              ),
          );
        });
  }
}
