import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/models/course.dart';
import 'package:flutterapp/models/user.dart';
import 'package:flutterapp/screens/home/course/add_course.dart';
import 'package:flutterapp/screens/home/course/course_detail.dart';
import 'package:flutterapp/screens/wrapper.dart';
import 'package:flutterapp/screens/home/main_drawer.dart';
import 'package:flutterapp/services/auth.dart';
import 'package:flutterapp/services/database.dart';
import 'package:flutterapp/services/teacher_service.dart';
import 'package:provider/provider.dart';

class MyTeachingCourses extends StatelessWidget {

  final AuthService _auth = AuthService();
  bool isTeacher = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
        stream: _auth.CurrentUser.map((event) => event.uid),
        builder: (context, snapshot) {
          return StreamProvider<List<Course>>.value(
            value: TeacherService(uid: snapshot.data).teacherCoursesStream,
            child: Consumer<List<Course>>(
            builder: (context, value, _){
              return Scaffold(
                backgroundColor: Colors.blue[50],
                appBar: AppBar(
                  title: Text('OkuPlus'),
                  backgroundColor: Colors.cyan,
                  elevation: 0.0,
                  actions: <Widget>[
                  ],
                ),
                drawer: MainDrawer(),
                body: Scaffold(
                  body: CustomScrollView(
                    slivers: <Widget>[
                      ///First sliver is the App Bar
                      SliverAppBar(
                        ///Properties of app bar
                        backgroundColor: Colors.white,
                        floating: false,
                        pinned: true,
                        expandedHeight: 50.0,

                        ///Properties of the App Bar when it is expanded
                        flexibleSpace: FlexibleSpaceBar(
                          centerTitle: true,
                          title: Text(
                            "My Teaching Courses",
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,),
                          ),
                          background: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: Colors.black26,
                                  width: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          ///no.of items in the horizontal axis
                          crossAxisCount: 2,
                        ),
                        ///Lazy building of list
                        delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                            /// To convert this infinite list to a list with "n" no of items,
                            /// uncomment the following line:
                            if (index >= (value != null ? value.length : 0)) return null;
                            return listItem(value[index], context);
                          },
                          /// Set childCount to limit no.of items
                           childCount: value != null ? value.length : 0,
                        ),
                      )
                    ],
                  ),
                ),
                floatingActionButton: StreamBuilder<bool>(
                    stream: _auth.isTeacher,
                    builder: (context, snapshot) {
                      return new Visibility(
                        visible: snapshot == null ? false : snapshot.data,
                        child: FloatingActionButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => AddCourse()));
                          },
                          child: Icon(Icons.add, color: Colors.white,),
                          foregroundColor: Colors.cyan,
                        ),
                      );
                    }),
              );
            })
          );
    });
  }

  Widget listItem(Course course, context) => Container(
    height: 300.0,
    color: Colors.white,
    child: Center(
      child: Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Column(
          children: <Widget>[
            Image(
              height: 100,
              width: 100,
              image: NetworkImage(course.image),
              fit: BoxFit.fill,
            ),
            ListTile(
                onTap: () async {
                  String uid;
                  await _auth.CurrentUser.listen((event) { uid = event.uid; });
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CourseDetail(course, uid)));
                },
                title: Text(course.name)
            )
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 5,
        margin: EdgeInsets.all(10),
      ),
    ),
  );
}
