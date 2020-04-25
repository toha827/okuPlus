class Question {
  String description;
  String answer;
  List<String> questions;

  Question({this.questions, this.answer, this.description});

  Map<String,dynamic> toMap(){
    var map = new Map<String,dynamic>();
    map['description'] = description;
    map['answer'] = answer;
    map['questions'] = questions.map((e) => e).toList();
    return map;
  }
  Question.fromMap(Map<String,dynamic> map){
    this.description = map['description'];
    this.answer = map['answer'];

    List<dynamic> parsedJson = map['questions'] ?? [];
    this.questions = parsedJson.map((e) => e.toString()).toList();
  }
}