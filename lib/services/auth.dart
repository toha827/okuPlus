
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutterapp/models/user.dart';
import 'package:flutterapp/services/database.dart';
import 'package:flutterapp/services/users.dart';
import 'package:flutterapp/shared/constants.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as Path;

class AuthService {

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Api _usersApi = new Api('users');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;
  Observable<Map<String, dynamic>> profile;
  Observable<FirebaseUser> CurrentUser;
  BehaviorSubject<bool> isTeacher;

  AuthService(){
    isTeacher = BehaviorSubject<bool>();
    isTeacher.add(false);
    CurrentUser = Observable(_auth.onAuthStateChanged);

    profile = CurrentUser.switchMap((FirebaseUser u) {
      if (u != null) {
        return _db.collection('users').document(u.uid).snapshots().map((snap) => snap.data);
      } else {
        return Observable.just({ });
      }
    });
    profile.listen((event) {
      isTeacher.add(User.fromMap(event).userType == "Teacher");
    });
  }

  // create user obj based on FirebaseUser
  User _userFromFirebaeUser(FirebaseUser user) {
    return user != null ? User(uid: user.uid, email: user.email, displayName: user.displayName, photoURL: "") : null;
  }

  // auth change user stream
  Stream<User> get user {
    return _auth.onAuthStateChanged
   //     .map((FirebaseUser user) => _userFromFirebaeUser(user));
    .map((_userFromFirebaeUser));
  }

  // sign In Anon
  Future signInAnon() async {
    try {
      AuthResult result = await _auth.signInAnonymously();
      FirebaseUser user = result.user;
      return _userFromFirebaeUser(user);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  // sign in with email & password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;
      if (user.isEmailVerified) {
        return _userFromFirebaeUser(user);
      }
      return null;
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  // googleSign In
  Future<FirebaseUser> googleSignIn() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final AuthResult authResult = await _auth.signInWithCredential(credential);

    final FirebaseUser user = authResult.user;
    User newUser = new User(uid: user.uid, fullName: user.displayName, email:user.email, displayName: user.displayName, birthDate: null, photoURL: user.photoUrl, userState: "Teacher");
    bool isNew = false;
    await userEmailExist(user.uid)
        .listen((value) => isNew = value.uid != '' ? true : false );
    if (isNew) {
      updateUserData(user.uid, newUser);
    }

    final FirebaseUser currentUser = await _auth.currentUser();

    return user;
  }

  // register with email & password
  Future registerWithEmailAndPassword( User newUser, String password ) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(email: newUser.email, password: password);
      FirebaseUser user = result.user;
      await user.sendEmailVerification();

      updateUserData(user.uid, newUser);

      return _userFromFirebaeUser(user);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  Stream<User> userEmailExist(String uid) {
    return _db.collection('users')
        .document(uid).snapshots()
        .map((event) =>
          User.fromMap(event.data));
  }

  Future<void> updateUserData(String uid, User user) async {
    user.uid = uid;
    return await _db.collection('users').document(uid).setData(
      user.toMap()
    );
  }

  Future<StorageReference> uploadFile(File _image) async {
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('profileImages/${Path.basename(_image.path)}}');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    print('File Uploaded');
    String url;
    return storageReference;
  }


}