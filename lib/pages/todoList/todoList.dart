import "package:flutter/material.dart";
import 'package:dio/dio.dart';
import "dart:math" show Random;
import 'model.dart';

class TodoList extends StatefulWidget {
  @override
  _ListState createState() => new _ListState();
}

class _ListState extends State<TodoList> with SingleTickerProviderStateMixin {
  List<TodoModel> _todoList = [];
  TextEditingController _addController = new TextEditingController();
  TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final List tabs = ["All", "Completed", "Uncompleted"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    fetchTodo();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void fetchTodo({int currentPage = 1}) async {
    try {
      final Response<List<dynamic>> response = await Dio().get<List<dynamic>>(
          "https://jsonplaceholder.typicode.com/todos");
      final List<TodoModel> todoList =
          response.data.map((todo) => TodoModel.fromJson(todo)).toList();
      setState(() {
        _todoList.addAll(todoList);
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<TodoModel> _completedTodoList =
        _todoList.where((todo) => todo.completed).toList();
    List<TodoModel> _uncompletedTodoList =
        _todoList.where((todo) => !todo.completed).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo List"),
        bottom: TabBar(
            controller: _tabController,
            tabs: tabs.map((tab) => Tab(text: tab)).toList()),
      ),
      body: TabBarView(controller: _tabController, children: [
        _buildList(_todoList),
        _buildList(_completedTodoList),
        _buildList(_uncompletedTodoList),
      ]),
      floatingActionButton:
          FloatingActionButton(child: Icon(Icons.add), onPressed: _addTodo),
    );
  }

  _addTodo() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Add Todo"),
            content: Form(
                key: _formKey,
                child: TextFormField(
                    controller: _addController,
                    validator: (v) =>
                        v.trim().isEmpty ? "Please enter some text" : null)),
            actions: <Widget>[
              FlatButton(
                child: Text('Add'),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    final TodoModel newTodo = TodoModel(_addController.text,
                        id: Random().nextInt(1000));
                    setState(() {
                      _todoList.add(newTodo);
                    });
                    _addController.clear();
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        });
  }

  _switchState(TodoModel current) {
    setState(() {
      current.switchState(!current.completed);
    });
  }

  _buildList(List<TodoModel> currentList) {
    if (_todoList.isEmpty) {
      return Container(
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      itemCount: currentList.length,
      itemBuilder: (BuildContext context, int index) {
        final TodoModel current = currentList[index];
        return GestureDetector(
            onTap: () {
              _switchState(current);
            },
            child: Card(
              key: ValueKey(current.id),
              child: ListTile(
                  leading: Checkbox(
                      value: current.completed,
                      onChanged: (value) {
                        _switchState(current);
                      }),
                  title: Text(
                    current.title,
                    style: TextStyle(
                        decoration: current.completed
                            ? TextDecoration.lineThrough
                            : null,
                        color: current.completed ? Colors.grey : null),
                  ),
                  trailing: IconButton(
                      icon: Icon(
                        Icons.delete,
                      ),
                      onPressed: () {
                        setState(() {
                          _todoList.remove(current);
                          Scaffold.of(context)
                            ..removeCurrentSnackBar()
                            ..showSnackBar(SnackBar(
                                action: SnackBarAction(
                                    label: "Undo",
                                    onPressed: () {
                                      setState(() {
                                        _todoList.insert(index, current);
                                      });
                                    }),
                                content: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    child: Text(
                                        'You delete Todo - ${current.title}'))));
                        });
                      })),
            ));
      },
    );
  }
}
