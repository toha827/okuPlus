class User {

  String _uid;
  String _fullName;
  String _displayName;
  String _email;
  String _photoURL;
  String _userType;

  User( this._uid, this._fullName, this._email, this._displayName, this._photoURL, this._userType);

  User.map(dynamic obj) {
    this._uid = obj['uid'];
    this._email = obj['email'];
    this._fullName = obj['fullName'];
    this._displayName = obj['displayName'];
    this._photoURL = obj['photoURL'];
    this._userType = obj['userType'];
  }

  String get uid => _uid;
  set uid(String val) => uid = val;
  String get email => _email;
  String get firstName => _fullName;
  String get displayName => _displayName;
  String get photoURL => _photoURL;
  String get userType => _userType;

  User.fromMap(Map<String,dynamic> map){
    this._uid = map['uid'];
    this._email = map['email'];
    this._fullName = map['fullName'] ?? '';
    this._displayName = map['displayName'] ?? '';
    this._photoURL = map['photoURL'] ?? '';
    this._userType = map['userType'] ?? '';
  }

  Map<String,dynamic> toMap(){
    var map = new Map<String,dynamic>();
    map['uid'] = _uid;
    map['email'] = _email;
    map['fullName'] = _fullName;
    map['displayName'] = _displayName;
    map['photoURL'] = _photoURL;
    map['userType'] = _userType;
    return map;
  }
}