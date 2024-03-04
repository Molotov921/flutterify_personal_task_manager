import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterify_personal_task_manager/helpers/database_helper.dart';
import 'package:flutterify_personal_task_manager/models/task_model.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';
import 'add_task_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late Future<List<Task>> _taskList;
  final DateFormat _dateFormatter = DateFormat('MM, dd, yyyy');

  @override
  void initState() {
    super.initState();
    _updateTaskList();
  }

  _updateTaskList() {
    setState(() {
      _taskList = DatabaseHelper.instance.getTaskList();
    });
  }

  Widget _buildTask(Task task) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        children: <Widget>[
          if (task.status == 0)
            ListTile(
              title: Text(
                task.title!,
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                  decoration: task.status == 0
                      ? TextDecoration.none
                      : TextDecoration.lineThrough,
                ),
              ),
              subtitle: Text(
                '${_dateFormatter.format(task.date!)} • ${task.priority}',
                style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.black,
                  decoration: task.status == 0
                      ? TextDecoration.none
                      : TextDecoration.lineThrough,
                ),
              ),
              trailing: Checkbox(
                onChanged: (value) {
                  setState(() {
                    task.status = value! ? 1 : 0;
                    DatabaseHelper.instance.updateTask(task);
                    Toast.show(
                      "Task Completed",
                      duration: Toast.lengthLong,
                      gravity: Toast.bottom,
                    );
                    _updateTaskList();
                  });
                },
                activeColor: Theme.of(context).primaryColor,
                value: task.status == 1,
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddTaskScreen(
                    updateTaskList: _updateTaskList,
                    task: task,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _navigateToSettingsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        await SystemNavigator.pop();
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          child: const Icon(Icons.add_outlined),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTaskScreen(
                updateTaskList: _updateTaskList,
                task: null,
              ),
            ),
          ),
        ),
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: const IconButton(
            icon: Icon(
              Icons.calendar_today_outlined,
              color: Colors.grey,
            ),
            onPressed: null,
          ),
          title: const Row(
            children: [
              Text(
                "Task",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.normal,
                  letterSpacing: -1.2,
                ),
              ),
              Text(
                "Manager",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 0,
                ),
              )
            ],
          ),
          centerTitle: false,
          elevation: 0,
          actions: [
            Container(
              margin: const EdgeInsets.all(0),
              child: IconButton(
                icon: const Icon(Icons.history_outlined),
                iconSize: 25.0,
                color: Colors.black,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(6.0),
              child: IconButton(
                icon: const Icon(Icons.settings_outlined),
                iconSize: 25.0,
                color: Colors.black,
                onPressed: _navigateToSettingsScreen,
              ),
            )
          ],
        ),
        body: FutureBuilder<List<Task>>(
          future: _taskList,
          builder: (context, AsyncSnapshot<List<Task>> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final int pendingTaskCount =
                snapshot.data!.where((Task task) => task.status == 0).length;

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 0.0),
              itemCount: 1 + snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0.0,
                      vertical: 0.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          margin:
                              const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Colors.blueGrey[200],
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Center(
                            child: Text(
                              'You have [ $pendingTaskCount ] pending tasks out of [ ${snapshot.data!.length} ]',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15.0,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                }
                return _buildTask(snapshot.data![index - 1]);
              },
            );
          },
        ),
      ),
    );
  }
}
