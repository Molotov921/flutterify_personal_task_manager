import 'package:flutter/material.dart';
import 'package:flutterify_personal_task_manager/helpers/database_helper.dart';
import 'package:flutterify_personal_task_manager/models/task_model.dart';
import 'home_screen.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';

class AddTaskScreen extends StatefulWidget {
  final Function() updateTaskList;
  final Task? task;

  const AddTaskScreen(
      {super.key, required this.updateTaskList, required this.task});

  @override
  AddTaskScreenState createState() => AddTaskScreenState();
}

class AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  late String _priority;
  DateTime _date = DateTime.now();
  final TextEditingController _dateController = TextEditingController();
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');

  final List<String> _priorities = ['Low', 'Medium', 'High'];

  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      _title = widget.task!.title!;
      _date = widget.task!.date!;
      _priority = widget.task!.priority!;
    }

    _dateController.text = _dateFormatter.format(_date);
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _handleDatePicker() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null && date != _date) {
      setState(() {
        _date = date;
      });
      _dateController.text = _dateFormatter.format(date);
    }
  }

  void _delete() {
    if (widget.task != null) {
      DatabaseHelper.instance.deleteTask(widget.task!.id!);
      widget.updateTaskList();
      Navigator.pop(context);
      Toast.show("Task Deleted",
          duration: Toast.lengthLong, gravity: Toast.bottom);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Task task = Task(title: _title, date: _date, priority: _priority);
      if (widget.task == null) {
        // Insert the task to our user's database
        task.status = 0;
        DatabaseHelper.instance.insertTask(task);
        Toast.show("New Task Added",
            duration: Toast.lengthLong, gravity: Toast.bottom);
      } else {
        // Update the task
        task.id = widget.task!.id;
        task.status = widget.task!.status!;
        DatabaseHelper.instance.updateTask(task);
        Toast.show("Task Updated",
            duration: Toast.lengthLong, gravity: Toast.bottom);
      }
      widget.updateTaskList();
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.task == null ? 'Add Task' : 'Update Task',
          style: const TextStyle(
            color: Colors.redAccent,
            fontSize: 20.0,
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 40.0, vertical: 40.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: TextFormField(
                      style: const TextStyle(fontSize: 18.0),
                      decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: const TextStyle(fontSize: 18.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      validator: (input) => input!.trim().isEmpty
                          ? 'Please enter a task title'
                          : null,
                      onSaved: (input) => _title = input!,
                      initialValue: _title,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: TextFormField(
                      readOnly: true,
                      controller: _dateController,
                      style: const TextStyle(fontSize: 18.0),
                      onTap: _handleDatePicker,
                      decoration: InputDecoration(
                        labelText: 'Date',
                        labelStyle: const TextStyle(fontSize: 18.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: DropdownButtonFormField(
                      isDense: true,
                      icon: const Icon(Icons.arrow_drop_down_circle),
                      iconSize: 22.0,
                      iconEnabledColor: Theme.of(context).primaryColor,
                      items: _priorities.map((String priority) {
                        return DropdownMenuItem(
                          value: priority,
                          child: Text(
                            priority,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18.0,
                            ),
                          ),
                        );
                      }).toList(),
                      style: const TextStyle(fontSize: 18.0),
                      decoration: InputDecoration(
                        labelText: 'Priority',
                        labelStyle: const TextStyle(fontSize: 18.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      validator: (input) {
                        if ((input as String).trim().isEmpty) {
                          return 'Please enter a task title';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _priority = value.toString();
                        });
                      },
                      value: _priority,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 20.0),
                    height: 60.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: TextButton(
                      onPressed: _submit,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Theme.of(context).primaryColor),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                      ),
                      child: Text(
                        widget.task == null ? 'Add' : 'Update',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                  ),
                  if (widget.task != null)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 0.0),
                      height: 60.0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: TextButton(
                        onPressed: _delete,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Theme.of(context).primaryColor),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
