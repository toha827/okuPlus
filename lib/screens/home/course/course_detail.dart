import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutterapp/models/Teacher.dart';
import 'package:flutterapp/models/TeacherCourse.dart';
import 'package:flutterapp/models/TeacherRequest.dart';
import 'package:flutterapp/models/course.dart';
import 'package:flutterapp/models/myCourse.dart';
import 'package:flutterapp/models/schedule.dart';
import 'package:flutterapp/models/user.dart';
import 'package:flutterapp/screens/home/course/test.dart';
import 'package:flutterapp/screens/home/course/video_course.dart';
import 'package:flutterapp/services/auth.dart';
import 'package:flutterapp/services/myCourses.dart';
import 'package:flutterapp/services/teacher_service.dart';
import 'package:flutterapp/shared/cardDetatil.dart';
import 'package:flutterapp/shared/common.dart';
import 'package:flutterapp/shared/loading.dart';
import 'package:flutterapp/shared/textStyle.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../main.dart';


class CourseDetail extends StatefulWidget {
  Course course;
  String uid;
   CourseDetail(this.course, this.uid);

  @override
  _CourseDetailState createState() => _CourseDetailState(this.course,this.uid);
}

class _CourseDetailState extends State<CourseDetail> {
  Course course;
  String uid;
  User CurrUser;
  MyCoursesService _myCoursesService;
  TeacherService _teacherService;
  Teacher _teacher;
  bool isBought = false;
  bool isStudent = false;
  List<Course> list = [];
  bool _isLoading;
  bool _permissionReady;
  String _localPath;

  bool isExpand = false;
  _CourseDetailState(this.course, this.uid);
  bool isLoading = true;
  final AuthService _auth = AuthService();
  final Firestore _db = Firestore.instance;
  @override
  void initState() {
    _auth.CurrentUser.listen((event) {
      setState(() {
        uid = event.uid;
        _myCoursesService = MyCoursesService(event.uid);
        _teacherService = TeacherService(uid: course.teacherId);
      });
      _auth.isStudent.listen((event) {
        setState(() {
          isStudent = event;
        });
      });
      _db.collection('users').document(uid).snapshots().listen((event) {
        setState(() {
          CurrUser = User.fromMap(event.data);
        });
      });
      _myCoursesService.courses.listen((el) {
        list = el ?? new List<Course>();
        el.forEach((element) {
          if(element.id == course.id) {
            setState(() {
              isBought = true;
            });
          }
        });
      });
      _teacherService.getTeacher().listen((el) {
        setState(() {
          _teacher = el;
          isLoading = false;
        });
      });
    });

    super.initState();
    FlutterDownloader.registerCallback(downloadCallback);

  }
  ReceivePort _port = ReceivePort();

  @override
  Widget build(BuildContext context) {
    return isLoading ? new Loading() : new Scaffold(
              body: new Container(
            constraints: new BoxConstraints.expand(),
            color: new Color(0xFF736AB7),
            child: new Stack (
              children: <Widget>[
                _getBackground(),
                _getGradient(),
                _getContent(),
                _getToolbar(context),
              ],
            ),
          ),
        );
  }
  Container _getBackground () {
    var _opacity = 1.0;
    var _xOffset = 0.0;
    var _yOffset = 0.0;
    var _blurRadius = 10.0;
        return new Container(
              child:  Image.network(course.image,
                fit: BoxFit.cover,
                height: 300.0,
              ),
            constraints: new BoxConstraints.expand(height: 300.0),
        );
  }

  Container _getGradient() {
        return new Container(
          margin: new EdgeInsets.only(top: 190.0),
          height: 110.0,
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
              colors: <Color>[
                new Color(0x00736AB7),
                new Color(0xFF736AB7)
              ],
              stops: [0.0, 0.9],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(0.0, 1.0),
            ),
          ),
        );
      }

  Widget _getContent() {
        return StreamBuilder<String>(
        stream: _auth.CurrentUser.map((event) => event.uid),
        builder: (context, snapshot) {
          return Container(
            child: new ListView(
              padding: new EdgeInsets.fromLTRB(0.0, 72.0, 0.0, 32.0),
              children: <Widget>[
                new PlanetSummary(course,
                  horizontal: false,
                ),
                new Container(
                  padding: new EdgeInsets.symmetric(horizontal: 32.0),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (index) {
                          return IconButton(
                            onPressed: onChanged != null
                                ? () {
                              onChanged(_teacher.rating == index + 1 ? index : index + 1);
                            }
                                : null,
                            color: index < _teacher.rating ? Colors.amber : null,
                            iconSize: 26.0,
                            icon: Icon(
                              index < _teacher.rating
                                  ? filledStar ?? Icons.star
                                  : unfilledStar ?? Icons.star_border,
                            ),
                            padding: EdgeInsets.zero,
                            tooltip: "${index + 1} of 5",
                          );
                        }),
                      ),
                      new Text(course.name,
                        style: Style.headerTextStyle,),
                      new Separator(),
                      new Text(
                          course.description, style: Style.commonTextStyle),
                    ],
                  ),
                ),
                ExpansionTile(
                    key: PageStorageKey(this.widget.key),
                    title: Container(
                        width: double.infinity,

                        child: Text("Course Detail",style: TextStyle(fontSize: 18))
                    ),
                    trailing: Icon(Icons.arrow_drop_down,size: 32,color: Colors.pink,),
                    onExpansionChanged: (value){
                      setState(() {
                        isExpand=value;
                      });
                    },
                    children: <Widget>[
                      Text(course.courseDetail)
                    ],
                ),
                ListTile(
                  leading: Text("Lessons"),
                ),
                ListTile(
                  title: Text("Additional Files"),
                  trailing: RaisedButton(
                    child: Icon(Icons.arrow_downward),
                    onPressed: () async {
                      //_downloadFile(course.fileUrl, course.name);
                      if (await Permission.storage.request().isGranted) {
                        final taskId = await FlutterDownloader.enqueue(
                          url: course.fileUrl,
                          fileName: course.name,
                          savedDir: (await getExternalStorageDirectory())
                              .path,
                          showNotification: true,
                          // show download progress in status bar (for Android)
                          openFileFromNotification: true, // click on notification to open downloaded file (for Android)
                        );
                      }
                    },
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.video_library),
                  title: Text("Promo Video"),
                  onTap: () => {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => VideoCourse(course.lesson)))
                  },
                ),
                ButtonTheme(
                    buttonColor: Colors.amber,
                    minWidth: 50.0,
                    height: 20.0,
                    child: RaisedButton(
                        child: Icon(Icons.queue),
                        onPressed: () async {
                          await _selectDate();
                          TeacherRequest request = TeacherRequest(studentId: uid, courseId: course.id, timestamp: requestDate,submitted: false);
                          _teacher.teacherRequests.add(request);
                          await _teacherService.updateTeacher(_teacher);
                        })
                ),
                new Visibility(
                visible: isBought && isStudent,
                child: RaisedButton(
                    color: Colors.blue[400],
                    child: Text(
                      'Questions',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Test(questions: course.questions)));
                    }
                ),
                ),
                new Visibility(
                      visible: !isBought && isStudent,
                      child: RaisedButton(
                          color: Colors.blue[400],
                          child: Text(
                            'Add Course',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            CurrUser.schedule.add(new Schedule(name: course.name, desc: "Lesson", complete: false, complete_date: course.course_date));
                            _auth.updateUserData(uid, CurrUser);
                            list.add(course);
                            _teacher.teacherCourses.forEach((element) {
                              if( element.courseId == course.id) {
                                element.students.add(uid);
                                element.timestamp.add(DateTime.now());
                                element.confirmed.add(false);
                              }
                            });
                            _teacherService.updateTeacher(_teacher);
                            _myCoursesService.updateUserData(MyCourse(myCourses: list));
                          }
                      )
                ) 
              ],
            ),
          );
        });

  }

  static var httpClient = new HttpClient();
  Future<File> _downloadFile(String url, String filename) async {
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getDownloadsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    if (debug) {
      print(
          'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
    }
    final SendPort send =
    IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  DateTime requestDate;

  Future _selectDate() async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: new DateTime(2016),
        lastDate: new DateTime(2022)
    );
    if(picked != null) setState(() => requestDate = picked);
  }

  final IconData filledStar = Icons.star;
  final IconData unfilledStar = Icons.star_border;

  void onChanged (int index) {
    if( isStudent ) {
      setState(() {
        _teacher.rating = ((_teacher.rating + index) / 2).toInt();
        _teacherService.updateTeacher(_teacher);
      });
    }
  }

  Container _getToolbar(BuildContext context) {
        return new Container(
            margin: new EdgeInsets.only(
                top: MediaQuery
                    .of(context)
                        .padding
                        .top),
                child: new BackButton(color: Colors.white),
              );
      }

}
