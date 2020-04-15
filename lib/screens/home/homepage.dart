import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/models/course.dart';
import 'package:flutterapp/models/user.dart';
import 'package:flutterapp/screens/home/home.dart';
import 'file:///C:/Users/Fixer/Desktop/app/flutter_app/lib/screens/home/course/course_detail.dart';
import 'package:flutterapp/screens/wrapper.dart';
import 'course/course_list.dart';
import 'package:flutterapp/screens/home/main_drawer.dart';
import 'package:flutterapp/services/auth.dart';
import 'package:flutterapp/services/database.dart';
import 'package:provider/provider.dart';
import 'course/add_course.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final AuthService _auth = AuthService();
  final DatabaseService _db = DatabaseService();
  List<String> courses = [];
  List<String> filteredCourses = [];
  String currUser;
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
        event.forEach((element) {
          bool isExist = false;
          filteredCourses.forEach((el2) {
            if (el2 == element.tag){
              isExist = true;
            }
          });
          if (!isExist) {
            filteredCourses.add(element.tag);
          }
        });
        courses = filteredCourses;
      });
    });

    super.initState();
  }


  // METHODS

  void _filterCourses(value) {
    setState(() {
      filteredCourses = courses
          .where((course) =>
            course.toLowerCase().contains(value.toLowerCase())
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
        backgroundColor: Colors.blue[400],
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
                  "Welcome to OkuPlus " + currUser,
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
                crossAxisCount: 3,
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
      floatingActionButton: StreamBuilder<bool>(
          stream: _auth.isTeacher,
          builder: (context, snapshot) {
            return new Visibility(
              visible: snapshot.data ?? false,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddCourse()));
                },
                child: Icon(Icons.add, color: Colors.white,),
                foregroundColor: Colors.blue,
              ),
            );
          }),
    );
  }


  Widget listItem(String course, context) => Container(
    height: 50.0,
    color: Colors.white,
    child: Center(
      child: Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Column(
          children: <Widget>[

            ListTile(
                onTap: () async {
                  String uid;
                  await _auth.CurrentUser.listen((event) { uid = event.uid; });
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
                },
                title: Text(course)
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
