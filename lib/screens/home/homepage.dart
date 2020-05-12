import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutterapp/models/course.dart';
import 'package:flutterapp/models/user.dart';
import 'package:flutterapp/screens/home/home.dart';
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
  String currUser = "";
  bool isTeacher = false;
  bool isSearching = false;
  bool isWelcome = false;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  new FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid;
  var initializationSettingsIOS;
  var initializationSettings;

  void _showNotification() async {
    await _demoNotification();
  }

  Future<void> _demoNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'channel_ID', 'channel name', 'channel description',
        importance: Importance.Max,
        priority: Priority.High,
        ticker: 'test ticker');

    var iOSChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(0, 'Hello, Did you pass our course',
        'A message from our community', platformChannelSpecifics,
        payload: 'test oayload');
  }

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
            setState(() {
              filteredCourses.add(element.tag);
            });
          }
        });
        setState(() {
          courses = filteredCourses;
        });
      });
    });



    super.initState();
    initializationSettingsAndroid =
    new AndroidInitializationSettings('app_icon');
    initializationSettingsIOS = new IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    _showNotification();
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('Notification payload: $payload');
    }
    await Navigator.push(context,
        new MaterialPageRoute(builder: (context) => new Home()));
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(body),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Ok'),
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                await Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Home()));
              },
            )
          ],
        ));
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
      backgroundColor: Colors.cyan,
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
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/a9Bmy0Z.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: CustomScrollView(
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
                    "Welcome to OkuPlus " + currUser,
                    style: TextStyle(
                      color: Colors.white,
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

      ),
    );
  }


  Widget listItem(String course, context) => Container(
    height: 50.0,
    color: Colors.transparent,
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Home(filter: course)));
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
