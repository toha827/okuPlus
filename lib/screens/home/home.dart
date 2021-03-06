import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutterapp/models/course.dart';
import 'package:flutterapp/models/user.dart';
import 'package:flutterapp/screens/home/course/course_detail.dart';
import 'package:flutterapp/screens/home/home.dart';
import 'package:flutterapp/screens/wrapper.dart';
import 'course/course_list.dart';
import 'package:flutterapp/screens/home/main_drawer.dart';
import 'package:flutterapp/services/auth.dart';
import 'package:flutterapp/services/database.dart';
import 'package:provider/provider.dart';
import 'course/add_course.dart';

class Home extends StatefulWidget {
  String filter;

  Home({this.filter});
  @override
  _HomePageState createState() => _HomePageState(filter: filter);
}

class _HomePageState extends State<Home> {
  String filter;

  _HomePageState({this.filter});

  final AuthService _auth = AuthService();
  final DatabaseService _db = DatabaseService();
  List<Course> courses = [];
  List<Course> filteredCourses = [];
  String currUser = "";
  bool isTeacher = false;
  bool isSearching = false;
  bool isWelcome = false;

  @override
  void initState() {
    _auth.CurrentUser.listen((event) {
      setState(() {
        currUser = event.displayName;
      });
    });
    _db.courses.listen((event) {
      setState(() {
          courses = filteredCourses = event;
          if(filter != null) {
            _filterCourses(filter);
          }
      });
    });

    super.initState();
  }


  // METHODS

  void _filterCourses(value) {
    setState(() {
      filteredCourses = courses
          .where((course) =>
          course.name.toLowerCase().contains(value.toLowerCase()) || course.tag.toLowerCase().contains(value.toLowerCase())
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue[50],
        appBar: AppBar(
          title: isSearching ? Text('OkuPlus') : TextField(
            onChanged: (value) {
              _filterCourses(value);
            },
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
                icon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                hintText: "Search Country Here",
                hintStyle: TextStyle(color: Colors.white)),
          ),
          backgroundColor: Colors.cyan,
          elevation: 0.0,
          actions: <Widget>[
            isSearching
                ? IconButton(
              icon: Icon(Icons.cancel),
              onPressed: () {
                setState(() {
                  this.isSearching = false;
                  filteredCourses = courses;
                });
              },
            )
                : IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                setState(() {
                  this.isSearching = true;
                });
              },
            )
          ],
        ),
        drawer: MainDrawer(),
        body: Scaffold(
          backgroundColor: Colors.cyan,
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/a9Bmy0Z.png"),
                fit: BoxFit.cover,
              ),
            ),
            child:  CustomScrollView(
              slivers: <Widget>[
                ///First sliver is the App Bar
                SliverAppBar(
                  ///Properties of app bar
                  backgroundColor: Colors.transparent,
                  floating: false,
                  pinned: true,
                  expandedHeight: 50.0,

                  ///Properties of the App Bar when it is expanded
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: currUser != null ? Text(
                      "Courses" + currUser,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,),
                    ) : Text("Welcome to OkuPlus"),
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
                      if (index >= filteredCourses.length) return null;
                      return listItem(filteredCourses[index], context);
                    },
                    /// Set childCount to limit no.of items
                    childCount: filteredCourses.length,
                  ),
                )
              ],
            ),
          ),
        ),
    );
  }


  Widget listItem(Course course, context) => Container(
    height: 50.0,
    color: Colors.transparent,
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
