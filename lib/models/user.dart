class User {

  String _uid;
  String _firstName;
  String _lastName;
  String _displayName;
  String _email;
  String _photoURL;
  String _userType;

  User( this._uid, this._firstName, this._lastName, this._email, this._displayName, this._photoURL, _userType);

  User.map(dynamic obj) {
    this._uid = obj['uid'];
    this._email = obj['email'];
    this._firstName = obj['firstName'];
    this._lastName = obj['firstName'];
    this._displayName = obj['displayName'];
    this._photoURL = obj['photoURL'];
    this._userType = obj['userType'];
  }

  String get uid => _uid;
  String get email => _email;
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get displayName => _displayName;
  String get photoURL => _photoURL;
  String get userType => _userType;

  User.fromMap(Map<String,dynamic> map){
    this._uid = map['uid'];
    this._email = map['email'];
    this._firstName = map['firstName'] ?? '';
    this._lastName = map['lastName'] ?? '';
    this._displayName = map['displayName'] ?? '';
    this._photoURL = map['photoURL'] ?? '';
    this._userType = map['userType'] ?? '';
  }

  Map<String,dynamic> toMap(){
    var map = new Map<String,dynamic>();
    map['uid'] = _uid;
    map['email'] = _email;
    map['firstName'] = _firstName;
    map['lastName'] = _lastName;
    map['displayName'] = _displayName;
    map['photoURL'] = _photoURL;
    map['userType'] = _userType;
    return map;
  }
}