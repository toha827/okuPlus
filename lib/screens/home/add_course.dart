import 'package:flutter/material.dart';
import 'package:flutterapp/models/course.dart';
import 'package:flutterapp/services/database.dart';
import 'package:flutterapp/shared/constants.dart';
import 'package:flutterapp/shared/loading.dart';

class AddCourse extends StatefulWidget {
  @override
  _AddCourseState createState() => _AddCourseState();
}

class _AddCourseState extends State<AddCourse> {

  final _formKey = GlobalKey<FormState>();


  final DatabaseService _dbService = DatabaseService();

  String name = '';
  String image = '';
  String description = '';
  int count;
  String error = '';

  bool loading = false;

  @override
  void initState() {

    _dbService.courses.listen((event) {
      count = event.length;
    });

    super.initState();
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
      body: Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                SizedBox(height: 20.0),
                TextFormField(
                  decoration: textInputDecoration.copyWith(hintText: 'Course Name'),
                  validator: (val) => val.isEmpty ? 'Enter a Name' : null,
                  onChanged: (val) {
                    setState(() => name = val);
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  obscureText: true,
                  decoration: textInputDecoration.copyWith(hintText: 'Description'),
                  validator: (val) => val.isEmpty ? 'Enter a Description' : null,
                  onChanged: (val) {
                    setState(() => description = val);
                  },
                ),
                SizedBox(height: 20.0,),
                RaisedButton(
                  color: Colors.blue[400],
                  child: Text(
                    'Add Course',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      setState(() => loading = true);
                      dynamic result = await _dbService.addPost(Course.fromMap({'id': count, 'name': name, 'image': '', 'description': description}));
                      if (result == null) {
                        setState(() => {
                          error = 'Could not sing in with those credentials',
                          loading = false
                        });
                      }
                      Navigator.pop(context, 'Yep!');
                    }
                  },
                ),
                SizedBox(height: 12.0),
                Text(
                  error,
                  style: TextStyle(color: Colors.red, fontSize: 14.0),
                ),
              ],
            ),
          )
      ),
    );
  }
}
