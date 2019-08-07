import 'dart:core';

class TodoModel {
  int id;
  String title;
  bool completed;

  TodoModel(this.title, {this.id, this.completed = false});

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      json["title"],
      id:json["id"],
      completed: json["completed"],
    );
  }

  void switchState(bool state) {
    this.completed = state;
  }
}
