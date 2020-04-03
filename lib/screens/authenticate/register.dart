
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
  String _currentUserType;

  List<DropdownMenuItem<String>> _dropDownMenuItems;

  @override
  void initState() {
    _dropDownMenuItems = getDropDownMenuItems();
    _currentUserType = _dropDownMenuItems[0].value;
    super.initState();
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
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                SizedBox(height: 10.0),
                TextFormField(
                  decoration: const InputDecoration(
                      icon: const Icon(Icons.person),
                      hintText: 'Fullname'),
                  validator: (val) => val.isEmpty ? 'Enter Full Name' : null,
                  onChanged: (val) {
                    setState(() => fullName = val.trim());
                  },
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  decoration: const InputDecoration(
                      icon: const Icon(Icons.email),
                      hintText: 'Email Address'),
                  validator: (val) => val.isEmpty ? 'Enter an Email' : null,
                  onChanged: (val) {
                    setState(() => email = val.trim());
                  },
                ),
                SizedBox(height: 10.0,),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                      icon: Icon(Icons.vpn_key),
                      hintText: 'Password'),
                  validator: (val) => val.length < 6 ? 'Enter an Password with length of 6 characters' : null,
                  onChanged: (val) {
                    setState(() => password = val.trim());
                  },
                ),
                SizedBox(height: 10.0,),
                DropdownButton(
                  icon: Icon(Icons.accessibility),
                  isExpanded: true,
                  value: _currentUserType,
                  items: _dropDownMenuItems,
                  onChanged: changedDropDownItem,
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
          )
      ),
    );
  }

  Future<void> register() async {
    if (_formKey.currentState.validate()) {
      setState(() => loading = true );
      User newUser = new User(null, fullName, email, fullName, "", _currentUserType);
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
  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String userType in _userTypes) {
      // here we are creating the drop down menu items, you can customize the item right here
      // but I'll just use a simple text for this
      items.add(new DropdownMenuItem(
          value: userType,
          child: new Text(userType)
      ));
    }
    return items;
  }

  void changedDropDownItem(String selectedUserType) {
    print("Selected city $selectedUserType, we are going to refresh the UI");
    setState(() {
      _currentUserType = selectedUserType;
    });
  }
}
