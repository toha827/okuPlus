import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutterapp/models/user.dart';
import 'package:flutterapp/screens/wrapper.dart';
import 'package:flutterapp/services/auth.dart';
import 'package:image_picker/image_picker.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile>{
  bool _status = true;
  final FocusNode myFocusNode = FocusNode();
  AuthService _authService = new AuthService();
  User currUser;
  String fullName = '';
  String email = '';
  DateTime birthDate;
  List _userTypes =  ["Teacher", "Student"];
  List _userState =  ["School student", "University student", "Employed", "Non-employed"];
  List _userInterests =  ["Science and Mathematics", "Humanities and Arts", "Engineering and I.T."];
  List _userPurposes =  ["Enter university", "Find a job", "Just want to learn this for myself"];

  String _currentUserType;
  String _currentUserState;
  String _currentUserInterest;
  String _currentUserPurpose;

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  List<DropdownMenuItem<String>> _dropDownUserStateItems;
  List<DropdownMenuItem<String>> _dropDownUserInterestsItems;
  List<DropdownMenuItem<String>> _dropDownUserPurposeItems;

  @override
  void initState() {
    _authService.profile.listen((event) {
      setState(() {
        currUser = User.fromMap(event);
        print(currUser.toMap());
        print(event.toString());
        birthDate = currUser.birthDate;
      });
    });

    _dropDownMenuItems = getDropDownMenuItems(_userTypes);
    _dropDownUserStateItems = getDropDownMenuItems(_userState);
    _dropDownUserInterestsItems = getDropDownMenuItems(_userInterests);
    _dropDownUserPurposeItems = getDropDownMenuItems(_userPurposes);

    _currentUserType = _dropDownMenuItems[0].value;
    _currentUserState = _dropDownUserStateItems[0].value;
    _currentUserInterest = _dropDownUserInterestsItems[0].value;
    _currentUserPurpose = _dropDownUserPurposeItems[0].value;

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
         return new Scaffold(
            body: new Container(
              color: Colors.white,
              child: new ListView(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      new Container(
                        height: 250.0,
                        color: Colors.white,
                        child: new Column(
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.only(left: 20.0, top: 20.0),
                                child: new Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                      },
                                        child:new Icon(
                                      Icons.arrow_back_ios,
                                      color: Colors.black,
                                      size: 22.0,
                                        )
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 25.0),
                                      child: new Text('PROFILE',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20.0,
                                              fontFamily: 'sans-serif-light',
                                              color: Colors.black)),
                                    )
                                  ],
                                )),
                            Padding(
                              padding: EdgeInsets.only(top: 20.0),
                              child: new Stack(fit: StackFit.loose, children: <Widget>[
                                new Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    new Container(
                                        width: 140.0,
                                        height: 140.0,
                                        decoration: new BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: new DecorationImage(
                                            image: currUser.photoURL == "" ? AssetImage('assets/profile.png') : NetworkImage(currUser.photoURL),
                                            fit: BoxFit.cover,
                                          ),
                                        )),
                                  ],
                                ),
                                Padding(
                                    padding: EdgeInsets.only(top: 90.0, right: 100.0),
                                    child: new Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        GestureDetector(
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
                                        )
                                      ],
                                    )),
                              ]),
                            )
                          ],
                        ),
                      ),
                      new Container(
                        color: Color(0xffFFFFFF),
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 25.0),
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                  padding: EdgeInsets.only(
                                      left: 25.0, right: 25.0, top: 25.0),
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      new Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          new Text(
                                            'Parsonal Information',
                                            style: TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      new Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          _status ? _getEditIcon() : new Container(),
                                        ],
                                      )
                                    ],
                                  )),
                              Padding(
                                  padding: EdgeInsets.only(
                                      left: 25.0, right: 25.0, top: 25.0),
                                  child: new Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      new Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          new Text(
                                            'Name',
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )),
                              Padding(
                                  padding: EdgeInsets.only(
                                      left: 25.0, right: 25.0, top: 2.0),
                                  child: new Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      new Flexible(
                                        child: _status && currUser.displayName != null ?
                                        new ListTile(
                                          title: new Text(currUser.displayName),
                                        ) :
                                        new TextField(
                                          decoration: const InputDecoration(
                                            hintText: "Enter Your Name",
                                          ),
                                          enabled: !_status,
                                          autofocus: !_status,
                                          onChanged: (val) => currUser.displayName = val,
                                        ),
                                      ),
                                    ],
                                  )),
                              Padding(
                                  padding: EdgeInsets.only(
                                      left: 25.0, right: 25.0, top: 25.0),
                                  child: new Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      new Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          new Text(
                                            'Email',
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )),
                              Padding(
                                  padding: EdgeInsets.only(
                                      left: 25.0, right: 25.0, top: 2.0),
                                  child: new Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      new Flexible(
                                        child: _status && currUser.email != null ?
                                        new ListTile(
                                          title: new Text(currUser.email),
                                        ) :  new TextField(
                                          decoration: const InputDecoration(
                                              hintText: "Enter Email ID"),
                                          enabled: !_status,
                                        ),
                                      ),
                                    ],
                                  )),
                              Padding(
                                  padding: EdgeInsets.only(
                                      left: 25.0, right: 25.0, top: 25.0),
                                  child: new Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      new Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          new Text(
                                            'Birthday',
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )),
                              Padding(
                                  padding: EdgeInsets.only(
                                      left: 25.0, right: 25.0, top: 2.0),
                                  child: new Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      new Flexible(
                                        child: new ListTile(
                                          leading: Icon(Icons.calendar_today),
                                          title: new Text("Birthday"),
                                          subtitle: new Text(birthDate.toString()),
                                          enabled: !_status,
                                          onTap: _selectDate,
                                        ),
                                      ),
                                    ],
                                  )),
                              Padding(
                                  padding: EdgeInsets.only(
                                      left: 25.0, right: 25.0, top: 25.0),
                                  child: new Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          child: new Text(
                                            'User Type',
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        flex: 2,
                                      ),
                                      Expanded(
                                        child: Container(
                                          child: new Text(
                                            'User Status',
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        flex: 2,
                                      ),
                                    ],
                                  )),
                              Padding(
                                  padding: EdgeInsets.only(
                                      left: 25.0, right: 25.0, top: 2.0),
                                  child: new Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Flexible(
                                        child: ListTile(
                                          subtitle: _status ?
                                          Text(currUser.userType) :
                                          DropdownButton(
                                            isExpanded: true,
                                            value: _currentUserType,
                                            items: _dropDownMenuItems,
                                            onChanged: (val) => changedDropDownItem(val,"type"),
                                          ),
                                        ),
                                        flex: 2,
                                      ),
                                      Flexible(
                                        child: ListTile(
                                          subtitle: _status ?
                                          Text(currUser.userState ?? "Empty") :
                                          DropdownButton(
                                            isExpanded: true,
                                            value: _currentUserState,
                                            items: _dropDownUserStateItems,
                                            onChanged: (val) => changedDropDownItem(val,"state"),
                                          ),
                                        ),
                                        flex: 2,
                                      ),
                                    ],
                                  )),
                              Padding(
                                  padding: EdgeInsets.only(
                                      left: 25.0, right: 25.0, top: 25.0),
                                  child: new Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          child: new Text(
                                            'Interests',
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        flex: 2,
                                      ),
                                      Expanded(
                                        child: Container(
                                          child: new Text(
                                            'Purpose',
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        flex: 2,
                                      ),
                                    ],
                                  )),
                              Padding(
                                  padding: EdgeInsets.only(
                                      left: 25.0, right: 25.0, top: 2.0),
                                  child: new Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Flexible(
                                        child: Padding(
                                          padding: EdgeInsets.only(right: 10.0),
                                          child: ListTile(
                                            subtitle: _status ?
                                            Text(currUser.userPurpose ?? "Empty") :DropdownButton(
                                              isExpanded: true,
                                              value: _currentUserPurpose,
                                              items: _dropDownUserPurposeItems,
                                              onChanged: (val) => changedDropDownItem(val,"purpose"),
                                            ),
                                          ),
                                        ),
                                        flex: 2,
                                      ),
                                      Flexible(
                                        child: ListTile(
                                          subtitle: _status ?
                                          Text(currUser.userInterest ?? "Empty") :DropdownButton(
                                            isExpanded: true,
                                            value: _currentUserInterest,
                                            items: _dropDownUserInterestsItems,
                                            onChanged: (val) => changedDropDownItem(val,"interest"),
                                          ),
                                        ),
                                        flex: 2,
                                      ),
                                    ],
                                  )),
                              !_status ? _getActionButtons() : new Container(),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ));
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myFocusNode.dispose();
    super.dispose();
  }

  Widget _getActionButtons() {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 45.0),
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Container(
                  child: new RaisedButton(
                    child: new Text("Save"),
                    textColor: Colors.white,
                    color: Colors.green,
                    onPressed: () async {
                        currUser.userInterest = _currentUserInterest;
                        currUser.userState = _currentUserState;
                        currUser.userPurpose = _currentUserPurpose;
                        currUser.userType = _currentUserType;
                        currUser.birthDate = birthDate;

                        _authService.updateUserData(currUser.uid, currUser);
                      setState(() {
                        _status = true;
                        FocusScope.of(context).requestFocus(new FocusNode());
                      });
                    },
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(20.0)),
                  )),
            ),
            flex: 2,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Container(
                  child: new RaisedButton(
                    child: new Text("Cancel"),
                    textColor: Colors.white,
                    color: Colors.red,
                    onPressed: () {
                      setState(() {
                        _status = true;
                        FocusScope.of(context).requestFocus(new FocusNode());
                      });
                    },
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(20.0)),
                  )),
            ),
            flex: 2,
          ),
        ],
      ),
    );
  }

  Widget _getEditIcon() {
    return new GestureDetector(
      child: new CircleAvatar(
        backgroundColor: Colors.red,
        radius: 14.0,
        child: new Icon(
          Icons.edit,
          color: Colors.white,
          size: 16.0,
        ),
      ),
      onTap: () {
        setState(() {
          _status = false;
        });
      },
    );
  }


  Future _selectDate() async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: new DateTime(2016),
        lastDate: new DateTime(2022)
    );
    if(picked != null) setState(() => birthDate = picked);
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems(List<dynamic> list) {
    List<DropdownMenuItem<String>> items = new List();
    for (String userType in list) {
      // here we are creating the drop down menu items, you can customize the item right here
      // but I'll just use a simple text for this
      items.add(new DropdownMenuItem(
          value: userType,
          child: new Text(userType)
      ));
    }
    return items;
  }

  void changedDropDownItem(String selectedUserType, String type) {
    if ( type == "type" ) {
      setState(() {
        _currentUserType = selectedUserType;
      });
    } else if ( type == "state") {
      setState(() {
        _currentUserState = selectedUserType;
      });
    } else if ( type == "interest") {
      setState(() {
        _currentUserInterest = selectedUserType;
      });
    } else if ( type == "purpose") {
      setState(() {
        _currentUserPurpose = selectedUserType;
      });
    }
  }
  File _image;
  Future chooseFile() async {
    await ImagePicker.pickImage(source: ImageSource.gallery).then((image) {
      setState(() async {
        _image = image;
        if (_image != null) {
          await _authService.uploadFile(_image).then((value) =>
              value.getDownloadURL().then((url) =>
              currUser.photoURL = url
              )
          );
        }
      });
    });
  }
}
