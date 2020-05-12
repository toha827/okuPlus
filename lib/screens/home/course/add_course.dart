import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/models/Teacher.dart';
import 'package:flutterapp/models/TeacherCourse.dart';
import 'package:flutterapp/models/course.dart';
import 'package:flutterapp/models/question.dart';
import 'package:flutterapp/models/user.dart';
import 'package:flutterapp/services/auth.dart';
import 'package:flutterapp/services/database.dart';
import 'package:flutterapp/services/teacher_service.dart';
import 'package:flutterapp/shared/constants.dart';
import 'package:flutterapp/shared/loading.dart';
import 'package:image_picker/image_picker.dart';

class AddCourse extends StatefulWidget {
  @override
  _AddCourseState createState() => _AddCourseState();
}

class _AddCourseState extends State<AddCourse> {

  AuthService _authService = new AuthService();
  String photoUrl = '';
  final _formKey = GlobalKey<FormState>();

  final AuthService _auth = AuthService();
  final DatabaseService _dbService = DatabaseService();
  TeacherService teacherService;
  Teacher teacher;
  User CurrentUser;

  String name = '';
  String image = '';
  String description = '';
  String courseDetails = '';
  String promoLink = '';
  File additionalFile;
  int count;
  String error = '';
  List<Question> questions = [];
  bool loading = false;

  @override
  void initState() {
    _auth.profile
        .listen((event) {
          setState(() {
            CurrentUser = User.fromMap(event);
            teacherService = new TeacherService(uid: CurrentUser.uid);
            teacherService.getTeacher()
                .listen((event) {
                  setState(() {
                    teacher = event;
                  });
                });
          });
        });
    _dbService.courses.listen((event) {
      count = event.length;
    });

    super.initState();
  }

  Future<Question> createQuestionDialog(BuildContext context){
    Question newQuestion = new Question();
    TextEditingController descriptionTextController = TextEditingController();
    TextEditingController answerTextController = TextEditingController();
    TextEditingController variantTextController = TextEditingController();
    List<String> variants = [];
    return showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text("Enter the Question"),
        content:  Column(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.description),
              title: TextField(
                controller: descriptionTextController,
              ),
              subtitle: Text("Description"),
            ),

            ListTile(
                leading: Icon(Icons.question_answer),
                title: TextField(
                  controller: variantTextController,
                ),
                subtitle: Text("Variant"),
                trailing: ButtonTheme(
                    minWidth: 50.0,
                    height: 20.0,
                    child: RaisedButton(
                        child: Icon(Icons.add),
                        onPressed: () {
                          if(variantTextController.text.trim() != ""){
                            setState(() {
                              variants.add(variantTextController.text.trim().toString());
                              variantTextController.text = "";
                            });
                          }
                        })
                )
            ),
            ListTile(
              leading: Icon(Icons.call_missed_outgoing),
              title: TextField(
                controller: answerTextController,
              ),
              subtitle: Text("Answer"),
            ),
          ],
        ),
        actions: <Widget>[
          MaterialButton(
            elevation: 3.0,
            child: Text("Add Question"),
            onPressed: (){
              if(descriptionTextController.text.trim() != ""
                && answerTextController.text.trim() != ""
                && variants.length > 0){
                Navigator.of(context)
                    .pop(
                      new Question(
                        description: descriptionTextController.text.toString(),
                        answer: answerTextController.text.toString(),
                        questions: variants
                      )
                );
              }
            },
          )
        ],
      );
    });
  }

  Future<void> _uploadImageToFirebase(File image) async {
    try {
      // Make random image name.
      int randomNumber = Random().nextInt(100000);
      String imageLocation = 'trash/${randomNumber}' + image.path.split('/').last;

      // Upload image to firebase.
      final StorageReference storageReference = FirebaseStorage().ref().child(imageLocation);
      final StorageUploadTask uploadTask = storageReference.putFile(image);
      await uploadTask.onComplete;
      _addPathToDatabase(imageLocation);
    }catch(e){
      print(e.message);
    }
  }
  String FileUrl;
  Future<void> _addPathToDatabase(String text) async {
    try {
      // Get image URL from firebase
      final ref = FirebaseStorage().ref().child(text);
      var imageString = await ref.getDownloadURL();
      setState(() {
        FileUrl = imageString;
      });
    }catch(e){
      print(e.message);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message),
            );
          }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading ?  Loading() : Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        elevation: 0.0,
        title: Text('Add Course'),
        actions: <Widget>[
        ],
      ),
      body: ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                  padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 0.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          leading: Icon(Icons.image),
                          title: Text(photoUrl == "" ? "Select Image" : "Image selected"),
                          trailing: GestureDetector(
                            onTap: () {
                              chooseFile();
                            },
                            child:  new CircleAvatar(
                              backgroundColor: Colors.red,
                              radius: 25.0,
                              child: new Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        ListTile(
                          leading: Icon(Icons.filter_none),
                          title: TextFormField(
                            decoration: textInputDecoration.copyWith(hintText: 'Course Name'),
                            validator: (val) => val.isEmpty ? 'Enter a Name' : null,
                            onChanged: (val) {
                              setState(() => name = val);
                            },
                          ),
                        ),
                        ListTile(
                          leading: Icon(Icons.description),
                          title: TextFormField(
                            decoration: textInputDecoration.copyWith(hintText: 'Description'),
                            validator: (val) => val.isEmpty ? 'Enter a Description' : null,
                            onChanged: (val) {
                              setState(() => description = val);
                            },
                          ),
                        ),
                        ListTile(
                          leading: Icon(Icons.details),
                          title: TextFormField(
                            decoration: textInputDecoration.copyWith(hintText: 'Course Details'),
                            validator: (val) => val.isEmpty ? 'Enter a Course Details' : null,
                            onChanged: (val) {
                              setState(() => courseDetails = val);
                            },
                          ),
                        ),
                        ListTile(
                          leading: Icon(Icons.calendar_today),
                          title: new Text("CourseDate"),
                          subtitle: new Text(courseDate.toString()),
                          onTap: _selectDate,
                        ),
                        Text("Questions"),
                        ListTile(
                          title: questions.length > 0 ? Container(
                            height: 40,
                            child: ListView.builder(
                                padding: const EdgeInsets.all(8),
                                itemCount: questions.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Text(questions[index].description ?? "");
                                }
                            ),
                          ) : Text("Not Added Yet."),
                          trailing: RaisedButton(
                            child: Text("Add Question"),
                            onPressed: (){
                              createQuestionDialog(context).then((value){
                                setState(() {
                                  if(value != null) {
                                    questions.add(value);
                                  }
                                });
                              });
                            },
                          ),
                        ),
                        ListTile(
                          title: Text("Additional Files"),
                          trailing: RaisedButton(
                            child: Text("Add File"),
                            onPressed: () async {
                              File file = await FilePicker.getFile();
                              await _uploadImageToFirebase(file);
                            },
                          ),
                        ),
                        ListTile(
                          leading: Icon(Icons.videocam),
                          title: TextFormField(
                            decoration: textInputDecoration.copyWith(hintText: 'Video Link'),
                            validator: (val) => val.isEmpty ? 'Enter a Video Link' : null,
                            onChanged: (val) {
                              setState(() => promoLink = val);
                            },
                          ),
                        ),
                        RaisedButton(
                          color: Colors.blue[400],
                          child: Text(
                            'Add Course',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState.validate() && FileUrl != null) {
                              setState(() => loading = true);
                              if( photoUrl != "" && courseDate != null) {

                                teacher.teacherCourses.add(TeacherCourse(courseId: count, students: []));
                                dynamic res = teacherService.updateTeacher(teacher);
                                dynamic result = await _dbService.addPost(Course(
                                    id: count,
                                    name: name,
                                    image: photoUrl,
                                    teacherId: teacher.uid,
                                    description: description,
                                    courseDetail: courseDetails,
                                    course_date: courseDate,
                                    questions: questions,
                                    fileUrl: FileUrl,
                                    lesson: promoLink
                                ));
                                if (result == null) {
                                  setState(() =>
                                  {
                                    error = 'Could not sing in with those credentials',
                                    loading = false
                                  });
                                }
                                Navigator.pop(context);
                              } else {
                                setState(() {
                                  error = 'Fill all maintain fields';
                                  loading = false;
                                });
                              }
                            }
                          },
                        ),
                        Text(
                          error,
                          style: TextStyle(color: Colors.red, fontSize: 14.0),
                        ),
                      ],
                    ),
                  )
              ),
            ],
          )
        ],
      )
    );
  }

  DateTime courseDate;

  Future _selectDate() async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: new DateTime(2016),
        lastDate: new DateTime(2022)
    );
    if(picked != null) setState(() => courseDate = picked);
  }


  File _image;
  Future chooseFile() async {
    await ImagePicker.pickImage(source: ImageSource.gallery).then((image) {
      setState(() async {
        _image = image;
        if (_image != null) {
          await _authService.uploadFile(_image).then((value) =>
              value.getDownloadURL().then((url) =>
              photoUrl = url
              )
          );
        }
      });
    });
  }
}
