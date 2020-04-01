class Course {
  int id;
  String name;
  String image;
  String description;

  Course({this.id, this.name, this.image, this.description});

  Map<String,dynamic> toMap(){
    var map = new Map<String,dynamic>();
    map['id'] = id;
    map['name'] = name;
    map['image'] = image;
    map['description'] = description;
    return map;
  }
  Course.fromMap(Map<String,dynamic> map){
    this.id = map['id'];
    this.name = map['name'];
    this.image = map['image'] ?? '';
    this.description = map['description'] ?? '';
  }
}