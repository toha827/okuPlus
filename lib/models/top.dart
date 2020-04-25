class Top {

  String name;
  int score;

  Top({
    this.name,
    this.score
  });

  Top.map(dynamic obj) {
    this.name = obj['name'];
    this.score = obj['score'];
  }

  Top.fromMap(Map<String,dynamic> map){
    this.name = map['name'];
    this.score = map['score'];
  }

  Map<String,dynamic> toMap(){
    var map = new Map<String,dynamic>();
    map['name'] = name;
    map['score'] = score;
    return map;
  }
}