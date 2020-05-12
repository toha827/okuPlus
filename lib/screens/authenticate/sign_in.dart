import 'package:flutter/material.dart';
import 'package:flutterapp/screens/home/profile.dart';
import 'package:flutterapp/services/auth.dart';
import 'package:flutterapp/shared/button.dart';
import 'package:flutterapp/shared/constants.dart';
import 'package:flutterapp/shared/loading.dart';

class SignIn extends StatefulWidget {

  final Function toggleView;
  SignIn({ this.toggleView });

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  // text field state
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return loading ?  Loading() : Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        elevation: 0.0,
        title: Text('Sign in'),
        actions: <Widget>[
          FlatButton.icon(
              onPressed: () {
                widget.toggleView();
              },
              icon: Icon(Icons.person),
              label: Text('Register'))
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
                decoration: textInputDecoration.copyWith(hintText: 'Email Address'),
                validator: (val) => val.isEmpty ? 'Enter an Email' : null,
                onChanged: (val) {
                  setState(() => email = val);
                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                obscureText: true,
                decoration: textInputDecoration.copyWith(hintText: 'Password'),
                validator: (val) => val.length < 6 ? 'Enter an Password with length of 6 characters' : null,
                onChanged: (val) {
                  setState(() => password = val);
                },
              ),
              SizedBox(height: 20.0,),
              RaisedButton(
                color: Colors.cyan,
                child: Text(
                  'Sign in',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    setState(() => loading = true);
                    dynamic result = await _auth.signInWithEmailAndPassword(email, password);
                    if (result == null) {
                      setState(() => {
                        error = 'Could not sing in with those credentials',
                        loading = false
                      });
                    }
                  }
                },
              ),
              SizedBox(height: 12.0),
              Text(
                error,
                style: TextStyle(color: Colors.red, fontSize: 14.0),
              ),
              MaterialButton(
                child: button('Google', 'assets/google.png'),
                onPressed: () async {
                  setState(() => loading = true);
                  dynamic result = await _auth.googleSignIn();
                  print("GOOGLE " + result.toString());
                  if (result == null) {
                    setState(() => {
                      error = 'Could not sign in with those credentials',
                      loading = false
                    });
                  }
                  else {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));
                  }
                },
                color: Colors.white,
              ),
              MaterialButton(
                child: button('Facebook', 'assets/facebook.png'),
                onPressed: () async {
                  setState(() => loading = true);
                  dynamic result = await _auth.facebookSignIn();
                  print("GOOGLE " + result);
                  if (result == null) {
                    setState(() => {
                      error = 'Could not sign in with those credentials',
                      loading = false
                    });
                  }
                  else {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));
                  }
                },
                color: Colors.white,
              ),
            ],
          ),
        )
      ),
    );
  }
}
