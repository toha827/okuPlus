
import 'package:flutter/material.dart';
import 'package:flutterapp/models/user.dart';
import 'package:flutterapp/services/auth.dart';
import 'package:flutterapp/shared/constants.dart';
import 'package:flutterapp/shared/loading.dart';

class Register extends StatefulWidget {

  final Function toggleView;
  Register({ this.toggleView });

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  // text field state
  String fullName = '';
  String email = '';
  String password = '';
  String error = '';

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

  DateTime birthDate;

  Future _selectDate() async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: new DateTime(2016),
        lastDate: new DateTime(2022)
    );
    if(picked != null) setState(() => birthDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        elevation: 0.0,
        title: Text('Register'),
        actions: <Widget>[
          FlatButton.icon(
              onPressed: () {
                widget.toggleView();
              },
              icon: Icon(Icons.person),
              label: Text('Sign in'))
        ],
      ),
      body: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          child: SingleChildScrollView(child:
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 10.0),
                  ListTile(
                    leading: Icon(Icons.person),
                    subtitle: new TextField(
                      decoration: new InputDecoration(
                        hintText: "Fullname",
                      ),
                      onChanged: (val) {
                        setState(() => fullName = val.trim());
                      },
                    ),
                    onTap: _selectDate,
                  ),
                  SizedBox(height: 10.0),
                  ListTile(
                    leading: Icon(Icons.email),
                    subtitle: new TextFormField(
                      decoration: new InputDecoration(
                        hintText: "Email",
                      ),
                      validator: (val) => val.isEmpty ? 'Enter an Email' : null,
                      onChanged: (val) {
                        setState(() => email = val.trim());
                      },
                    ),
                    onTap: _selectDate,
                  ),
                  SizedBox(height: 10.0),
                  ListTile(
                    leading: Icon(Icons.calendar_today),
                    title: new Text("Birthday"),
                    subtitle: new Text(birthDate.toString()),
                    onTap: _selectDate,
                  ),
                  SizedBox(height: 10.0),
                  ListTile(
                    leading: Icon(Icons.vpn_key),
                    subtitle: TextFormField(
                      obscureText: true,
                      decoration: const InputDecoration(
                          hintText: 'Password'),
                      validator: (val) => val.length < 6 ? 'Enter an Password with length of 6 characters' : null,
                      onChanged: (val) {
                        setState(() => password = val.trim());
                      },
                    )
                  ),
                  SizedBox(height: 10.0),
                  ListTile(
                      leading: Icon(Icons.accessibility),
                      title: new Text("Select one"),
                      subtitle: DropdownButton(
                        isExpanded: true,
                        value: _currentUserType,
                        items: _dropDownMenuItems,
                        onChanged: (val) => changedDropDownItem(val,"type"),
                      ),
                  ),
                  SizedBox(height: 10.0),
                  ListTile(
                    leading: Icon(Icons.work),
                    subtitle: DropdownButton(
                      isExpanded: true,
                      value: _currentUserState,
                      items: _dropDownUserStateItems,
                      onChanged: (val) => changedDropDownItem(val,"state"),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  ListTile(
                    leading: Icon(Icons.list),
                    title: const Text("What are your interests?"),
                    subtitle: DropdownButton(
                      isExpanded: true,
                      value: _currentUserInterest,
                      items: _dropDownUserInterestsItems,
                      onChanged: (val) => changedDropDownItem(val,"interest"),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  ListTile(
                    leading: Icon(Icons.list),
                    title: const Text("What is your purpose of studying these courses?"),
                    subtitle: DropdownButton(
                      isExpanded: true,
                      value: _currentUserPurpose,
                      items: _dropDownUserPurposeItems,
                      onChanged: (val) => changedDropDownItem(val,"purpose"),
                    ),
                  ),
                  SizedBox(height: 20.0,),
                  RaisedButton(
                    color: Colors.blue[400],
                    child: Text(
                      'Register',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      register();
                    },
                  ),
                  SizedBox(height: 12.0),
                  Text(
                    error,
                    style: TextStyle(color: Colors.red, fontSize: 14.0),
                  )
                ],
              ),
            ),
          )
      ),
    );
  }

  Future<void> register() async {
    if (_formKey.currentState.validate()) {
      setState(() => loading = true );
      User newUser = new User(
          uid: null,
          fullName: fullName,
          displayName: fullName,
          email: email,
          photoURL: "",
          birthDate: birthDate,
          userType: _currentUserType,
          userInterest: _currentUserInterest,
          userPurpose: _currentUserPurpose,
          userState: _currentUserState
      );
      dynamic result = await _auth.registerWithEmailAndPassword(newUser, password);
      if (result == null) {
        setState(() => {
          error = 'Please supply a valid email',
          loading = false
        });
      }
    }
  }

  // here we are creating the list needed for the DropDownButton
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
}
