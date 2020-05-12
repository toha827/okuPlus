import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/models/schedule.dart';
import 'package:flutterapp/models/user.dart';
import 'package:flutterapp/services/auth.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import './task_detail.dart';
import './globals.dart' as globals;

class TaskList extends StatefulWidget{

  final _TaskListState _taskListState = _TaskListState();
  Function addNew;

  void filterList(search){
    _taskListState.searchListUpdate(search);
  }

  @override
  State<TaskList> createState() {
    addNew  = _taskListState.taskDetailWork;
    return _taskListState;
  }
}

class _TaskListState extends State<TaskList>{

  List<Schedule> _taskList;
  List<Schedule> _currentList;
  User _currentUser;
  AuthService _authService = AuthService();
  final Firestore _db = Firestore.instance;
  @override
  void initState(){
    getTaskList();
    super.initState();
  }

  void searchListUpdate(search){
    if(search==""){
      _currentList = List.from(_taskList);
    } else{
      search = search.toLowerCase();
      _currentList.clear();
      for(int i=0; i<_taskList.length;i++){
        var task = _taskList[i];
        if(task.name.toLowerCase().contains(search))
          _currentList.add(task);
      }
    }
    setState(() {
    });
  }

  void getTaskList() async {
    _authService.user.listen((event) {
      setState(() {
        _currentUser = event;
      });
      _db.collection('users').document(_currentUser.uid).snapshots().listen((event) {
        setState(() {
          _currentUser = User.fromMap(event.data);
          _taskList = _currentUser.schedule;
          _currentList = _currentUser.schedule;
        });
      });
    });
  }

  void updateCurrentTaskJson(pos) async {
    http.Response resp = await http.get(globals.url+pos.toString()+'/.json');
    final updated_task = json.decode(resp.body);
    _taskList[pos].complete = _currentList[pos].complete = updated_task['complete'];
    setState(() {
    });
  }

  void taskDetailWork(Schedule task,isNew) async {
      if(isNew==true) {
        task.pos = _taskList.length;
      }
      bool changed = await Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return TaskDetail(task);
          }
      )
      );
      if(changed==true) {
        if(isNew){
          _taskList.add(task);
          _currentList.add(task);
          setState(() {
            _currentUser.schedule = _taskList;
            _authService.updateUserrData(_currentUser.uid, _currentUser);
          });
        } else {
          updateCurrentTaskJson(task) ;
        }
      }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentList == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Fetching your tasks...",
              style: TextStyle(
                  fontSize: 20
              ),
            )
          ],
        ),
      );
    }

    if (_currentList.length == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "No tasks to show",
              style: TextStyle(
                  fontSize: 20
              ),
            )
          ],
        ),
      );
    }

    return ListView.separated(
        itemCount: _currentList.length,
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            height: 4,
            color: Colors.grey,
          );
        },
        itemBuilder: (context, i) {
          var task = _currentList[i];
          return GestureDetector(
              child: _TaskBlock(task),
              onTap: () {
                taskDetailWork(task, false);
              }
          );
        }
    );
  }
}

class _TaskBlock extends StatelessWidget{

  final Schedule _task;

  _TaskBlock(this._task);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          Container(
            child: Center(
              child: Text(
                _task.name[0],
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20
                ),
              ),
            ),
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blueGrey[900],
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _task.name,
                    style: TextStyle(
                        fontSize: 20
                    ),
                  ),
                  Text(
                    _task.complete==true?"Completed":"Finish by : "+_task.complete_date.toString(),
                    style: TextStyle(
                        fontSize: 15,
                        color: _task.complete==true?Colors.green:Colors.red,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  Text(
                    _task.desc,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<List> getTaskJson() async {
  var url = globals.url+'.json';
  http.Response response = await http.get(url);
  return json.decode(response.body);
}