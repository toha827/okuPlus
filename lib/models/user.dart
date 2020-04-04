class User {

  String uid;
  String fullName;
  String displayName;
  String email;
  DateTime birthDate;
  String photoURL;
  String userType;
  String userState;
  String userInterest;
  String userPurpose;

  User({
    this.uid,
    this.fullName,
    this.email,
    this.displayName,
    this.birthDate,
    this.photoURL,
    this.userType,
    this.userState,
    this.userInterest,
    this.userPurpose
  });

  User.map(dynamic obj) {
    this.uid = obj['uid'];
    this.email = obj['email'];
    this.fullName = obj['fullName'];
    this.displayName = obj['displayName'];
    this.birthDate = obj['birthDate'];
    this.photoURL = obj['photoURL'];
    this.userType = obj['userType'];
  }

//  String get uid => _uid;
//  set uid(String val) => uid = val;
//  String get email => _email;
//  String get firstName => _fullName;
//  String get displayName => _displayName;
//  DateTime get birthDate => _birthDate;
//  set birthDate(DateTime val) => _birthDate = val;
//  String get photoURL => _photoURL;
//  String get userType => _userType;

  User.fromMap(Map<String,dynamic> map){
    this.uid = map['uid'];
    this.email = map['email'];
    this.fullName = map['fullName'] ?? '';
    this.displayName = map['displayName'] ?? '';
    this.photoURL = map['photoURL'] ?? '';
    this.userType = map['userType'] ?? '';
  }

  Map<String,dynamic> toMap(){
    var map = new Map<String,dynamic>();
    map['uid'] = uid;
    map['email'] = email;
    map['fullName'] = fullName;
    map['displayName'] = displayName;
    map['birthDate'] = birthDate;
    map['photoURL'] = photoURL;
    map['userType'] = userType;
    map['userState'] = userState;
    map['userInterest'] = userInterest;
    map['userPurpose'] = userPurpose;
    return map;
  }
}