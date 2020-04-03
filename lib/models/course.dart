class Course {
  int id;
  String name;
  String image;
  String description;
  String tag;
  Course({this.id, this.name, this.image, this.description, this.tag});

  Map<String,dynamic> toMap(){
    var map = new Map<String,dynamic>();
    map['id'] = id;
    map['name'] = name;
    map['image'] = image;
    map['description'] = description;
    map['tag'] = tag;
    return map;
  }
  Course.fromMap(Map<String,dynamic> map){
    this.id = map['id'];
    this.name = map['name'];
    this.image = map['image'] ?? '';
    this.description = map['description'] ?? '';
    this.tag = map['tag'];
  }
}