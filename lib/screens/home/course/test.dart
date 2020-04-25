import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/models/course.dart';
import 'package:flutterapp/models/top.dart';
import 'package:flutterapp/services/users.dart';
import 'package:flutterapp/models/question.dart';
import 'package:flutterapp/screens/home/course/course_detail.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class Test extends StatefulWidget {
  List<Question> questions;


  Test({this.questions});

  @override
  _TestState createState() => _TestState(questinos: questions);
}

class _TestState extends State<Test> {

  _TestState({this.questinos});
  List<String> userAnswers = [];
  List<int> userAnswersRadio = [];
  List arr = ["1", "2", "2", "2","2", "2","2", "2"];
  List<Question> questinos;
  String uid;
  Top top;
  TopService topService;
  bool isExpand = true;


  @override
  void initState() {
    questinos.forEach((element) {
      setState(() {
        userAnswers.add("");
        userAnswersRadio.add(-1);
      });
    });
    FirebaseAuth.instance.onAuthStateChanged.listen((event) {
      setState(() {
        uid = event.uid;
        topService = TopService(uid: uid);
        topService.teacherCoursesStream.listen((event) {
          setState(() {
            top = event;
          });
        });
      } );
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue[50],
        appBar: AppBar(
          title: Text('OkuPlus'),
          backgroundColor: Colors.blue[400],
          elevation: 0.0,
          actions: <Widget>[

          ],
        ),
        body: ListView.builder(
          itemBuilder: (context, position) {
            return Card(
              child: listItem(position, questinos[position].description, questinos[position]),
            );
          },
          itemCount: questinos.length,
        ),
      floatingActionButton: RaisedButton(
        child: Text("End Test"),
        onPressed: () async {
          int score = 0;
          questinos.forEach((element1) {
            userAnswers.forEach((element2) {

              if (element1.answer == element2){
                score++;
              }
            });
          });
          Fluttertoast.showToast(
            msg: "You Have Scored " + score.toString() + " of " + questinos.length.toString(),
            toastLength: Toast.LENGTH_SHORT,
            webBgColor: "#e74c3c",
            timeInSecForIosWeb: 1,
          );
          if (score == questinos.length){
            Top newTop = new Top(name: top.name, score: top.score + 50);
            topService.updateTop(newTop);
          }
        },
      ),
    );
  }

  Widget listItem(int id, String title, Question question) => Container(
      height: 300.0,
      color: Colors.white,
      child: Column(
        children: <Widget>[
          ExpansionTile(
              key: PageStorageKey(this.widget.key),
              title: Container(
                  width: double.infinity,

                  child: Text(title,style: TextStyle(fontSize: 18))
              ),
              trailing: Icon(Icons.arrow_drop_down,size: 32,color: Colors.pink,),
              onExpansionChanged: (value){
                setState(() {
                  isExpand=value;
                });
              },
              children: getStudents(id, question)
          ),
          ListTile(
            title: TextField(
              onChanged: (val){
                userAnswers[id] = val;
              },
            ),
            subtitle: Text("Answer"),
          )
        ],
      )
  );

  List<Widget> getStudents(int id, Question question) {
    List<Widget> ll = [];
    for(int i = 0; i < question.questions.length; i++){
      ll.add(
        new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              (i + 1).toString() + ")" + questinos[id].questions[i],
              style: new TextStyle(fontSize: 16.0),
            )
          ],
        ),
      );
    }
    return ll;
  }
}
