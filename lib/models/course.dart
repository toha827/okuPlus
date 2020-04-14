class Course {
  int id;
  String name;
  String image;
  String description;
  String teacherId;
  String tag;
  String lesson;

  Course({this.id, this.name, this.image, this.description, this.teacherId, this.tag, this.lesson});

  Map<String,dynamic> toMap(){
    var map = new Map<String,dynamic>();
    map['id'] = id;
    map['name'] = name;
    map['image'] = image;
    map['description'] = description;
    map['teacherId'] = teacherId;
    map['tag'] = tag;
    map['lesson'] = lesson;
    return map;
  }
  Course.fromMap(Map<String,dynamic> map){
    this.id = map['id'];
    this.name = map['name'];
    this.image = map['image'] ?? '';
    this.description = map['description'] ?? '';
    this.teacherId = map['teacherId'] ?? '';
    this.tag = map['tag'];
    this.lesson = map['lesson'];
  }
}