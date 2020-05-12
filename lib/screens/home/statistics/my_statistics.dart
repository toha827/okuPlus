import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:flutterapp/models/Teacher.dart';
import 'package:flutterapp/models/top.dart';
import 'package:flutterapp/models/user.dart';
import 'package:flutterapp/screens/home/main_drawer.dart';
import 'package:flutterapp/screens/home/statistics/requests_list.dart';
import 'package:flutterapp/screens/home/statistics/students_list.dart';
import 'package:flutterapp/services/auth.dart';
import 'package:flutterapp/services/teacher_service.dart';
import 'package:flutterapp/services/users.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class MyStatistics extends StatefulWidget {

  @override
  _MyStatisticsState createState() => _MyStatisticsState();
}

class _MyStatisticsState extends State<MyStatistics> {
  TeacherService _teacherService;
  TopService _topService;
  final Firestore _db = Firestore.instance;
  final AuthService _auth = AuthService();
  Teacher currTeacher;
  List<String> myStudents = [];
  double balance = 0.0;
  List<Top> topList = [];
  var data = [0.0];
  var data1 = [12000.0,24000.0,30000.0,50000.0];
  bool isAdmin = false;

  int studentsCount = 0;
  int requestsCount = 0;

  @override
  void initState() {
    _auth.isAdmin.listen((event) {
      isAdmin = event;
    });
    _auth.CurrentUser.listen((event) {
      setState(() {
        _teacherService = TeacherService(uid: event.uid);
        _topService = TopService(uid: event.uid);
      });
      _topService.tops.listen((toplist) {
        setState(() {
          topList = toplist;
          toplist.sort((a,b) => a.score.compareTo(b.score));
        });
      });
      _teacherService.getTeacher().listen((event1) {
        setState(() {
          currTeacher = event1;
          requestsCount = event1.teacherRequests.length;
        });
        currTeacher.teacherCourses.forEach((element) {
          data = [0.0];
          balance = 0;
          myStudents = [];
          double sum = 0.0;
          for(int i = 0; i < element.students.length; i++) {
            sum += 50000.0;
            myStudents.add(element.students[i]);
          }
          setState(() {
            if (sum > 0) {
              data.add(sum);
              balance += sum;
            }
          });
        });
      });
    });

    super.initState();
  }

  Stream<List<User>> teacherCountStream() {
    return _db.collection('users').where('userType', isEqualTo: "Teacher").snapshots()
        .map(_coursesListFromSnapshot);
  }

  Stream<List<User>> studentsCountStream() {
    return _db.collection('users').where('userType', isEqualTo: "Student").snapshots()
        .map(_coursesListFromSnapshot);
  }

  List<User> _coursesListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc){
      return User.fromMap(doc.data);
    }).toList();
  }

  List<CircularStackEntry> circularData = <CircularStackEntry>[
    new CircularStackEntry(
      <CircularSegmentEntry>[
        new CircularSegmentEntry(700.0, Color(0xff4285F4), rankKey: 'Q1'),
        new CircularSegmentEntry(1000.0, Color(0xfff3af00), rankKey: 'Q2'),
        new CircularSegmentEntry(1800.0, Color(0xffec3337), rankKey: 'Q3'),
        new CircularSegmentEntry(1000.0, Color(0xff40b24b), rankKey: 'Q4'),
      ],
      rankKey: 'Quarterly Profits',
    ),
  ];

  Material myTextItems(String title, String subtitle){
    return Material(
      color: Colors.white,
      elevation: 14.0,
      borderRadius: BorderRadius.circular(24.0),
      shadowColor: Color(0x802196F3),
      child: Center(
        child:Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment:MainAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment:MainAxisAlignment.center,
                children: <Widget>[

                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child:Text(title,style:TextStyle(
                      fontSize: 20.0,
                      color: Colors.blueAccent,
                    ),),
                  ),

                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      subtitle,
                      style:TextStyle(
                        fontSize: 30.0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Material myTopItems(String title, String subtitle){
    return Material(
      color: Colors.white,
      elevation: 14.0,
      borderRadius: BorderRadius.circular(24.0),
      shadowColor: Color(0x802196F3),
      child: Center(
        child:Padding(
          padding: EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: topList.length,
            itemBuilder: (context, index) {
              return Card(
                child: Column(
                    children: <Widget>[
                      Visibility(
                        visible: index == 0,
                        child: ListTile(
                          onTap: () {
//                              Navigator.push(context, MaterialPageRoute(builder: (context) => CourseDetail(courses[index], uid)));
                          },
                          title: Text("Name"),
                          trailing: Text("Score"),
                        ),
                      ),
                      ListTile(
                        onTap: () {
//                              Navigator.push(context, MaterialPageRoute(builder: (context) => CourseDetail(courses[index], uid)));
                        },
                        title: Text(topList[topList.length - 1 - index].name),
                        trailing: Text(topList[topList.length - 1 - index].score.toString()),
                      ),
                    ]
                ),
              );
            },
          )
        ),
      ),
    );
  }

  Material myCircularItems(String title, String subtitle){
    return Material(
      color: Colors.white,
      elevation: 14.0,
      borderRadius: BorderRadius.circular(24.0),
      shadowColor: Color(0x802196F3),
      child: Center(
        child:Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment:MainAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment:MainAxisAlignment.center,
                children: <Widget>[

                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child:Text(title,style:TextStyle(
                      fontSize: 20.0,
                      color: Colors.blueAccent,
                    ),),
                  ),

                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child:Text(subtitle,style:TextStyle(
                      fontSize: 30.0,
                    ),),
                  ),

                  Padding(
                    padding:EdgeInsets.all(8.0),
                    child:AnimatedCircularChart(
                      size: const Size(100.0, 100.0),
                      initialChartData: circularData,
                      chartType: CircularChartType.Pie,
                    ),
                  ),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Material mychart1Items(String title, String priceVal,String subtitle) {
    return Material(
      color: Colors.white,
      elevation: 14.0,
      borderRadius: BorderRadius.circular(24.0),
      shadowColor: Color(0x802196F3),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[

                  Padding(
                    padding: EdgeInsets.all(1.0),
                    child: Text(title, style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.blueAccent,
                    ),),
                  ),

                  Padding(
                    padding: EdgeInsets.all(1.0),
                    child: Text(priceVal, style: TextStyle(
                      fontSize: 30.0,
                    ),),
                  ),
                  Padding(
                    padding: EdgeInsets.all(1.0),
                    child: Text(subtitle, style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.blueGrey,
                    ),),
                  ),

                  Padding(
                    padding: EdgeInsets.all(1.0),
                    child: new Sparkline(
                      data: data,
                      lineColor: Color(0xffff6101),
                      pointsMode: PointsMode.all,
                      pointSize: 8.0,
                    ),
                  ),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Material mychart2Items(String title, String priceVal,String subtitle) {
    return Material(
      color: Colors.white,
      elevation: 14.0,
      borderRadius: BorderRadius.circular(24.0),
      shadowColor: Color(0x802196F3),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[

                  Padding(
                    padding: EdgeInsets.all(1.0),
                    child: Text(title, style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.blueAccent,
                    ),),
                  ),

                  Padding(
                    padding: EdgeInsets.all(1.0),
                    child: Text(priceVal, style: TextStyle(
                      fontSize: 30.0,
                    ),),
                  ),
                  Padding(
                    padding: EdgeInsets.all(1.0),
                    child: Text(subtitle, style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.blueGrey,
                    ),),
                  ),

                  Padding(
                    padding: EdgeInsets.all(1.0),
                    child: new Sparkline(
                      data: data1,
                      fillMode: FillMode.below,
                      fillGradient: new LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.amber[800], Colors.amber[200]],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
        actions: <Widget>[
          IconButton(icon: Icon(
              FontAwesomeIcons.chartLine), onPressed: () {
            //
          }),
        ],
      ),
      drawer: MainDrawer(),
      body:Container(
        color:Color(0xffE5E5E5),
        child:StaggeredGridView.count(
          crossAxisCount: 4,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: mychart1Items("My Balance",balance.toString(),"+12.9% of target"),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: myCircularItems("Quarterly Profits","68.7M"),
            ),
            isAdmin ? StreamBuilder<List<User>>(
                stream: teacherCountStream(),
                builder: (context, snapshot) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: myTextItems("Teachers", snapshot.data.length.toString()),
                  );
                }) :
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => RequestsList(requests: currTeacher.teacherRequests)));
                },child: myTextItems("Requests", requestsCount.toString()),
              )
            ),
            StreamBuilder<List<User>>(
            stream: studentsCountStream(),
            builder: (context, snapshot) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => StudentsList(courses: currTeacher.teacherCourses)));
                  },
                  child: myTextItems("Students", myStudents.length.toString()),
                )
              );
            }),
//            Padding(
//              padding: const EdgeInsets.all(8.0),
//              child: mychart2Items("Conversion","0.9M","+19% of target"),
//            ),
            Visibility(
              visible: true,
              child: Padding(
                padding: const EdgeInsets.only(right:8.0),
                child: myTopItems("Top",""),
              ),
            ),

          ],
          staggeredTiles: [
            StaggeredTile.extent(4, 250.0),
            StaggeredTile.extent(2, 250.0),
            StaggeredTile.extent(2, 120.0),
            StaggeredTile.extent(2, 120.0),
            StaggeredTile.extent(4, 250.0),
          ],
        ),
      ),
    );
  }
}