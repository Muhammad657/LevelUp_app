import 'package:flutter/material.dart';
import 'package:flutter_club/state_management/project_todo/reference/create_task.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TodoApp extends StatefulWidget {
  const TodoApp({super.key});
  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  final tasksBox = Hive.box("tasks_box");
  List globalTaskList = [];

  @override
  void initState() {
    globalTaskList = tasksBox.get("tasks", defaultValue: []);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(globalTaskList);
    return Scaffold(
      appBar: AppBar(
        title: Text("T o    D o ", style: TextStyle(color: Colors.white)),
        toolbarHeight: 100,
        backgroundColor: Colors.blue.shade500,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade500,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(50),
        ),
        tooltip: "Add Todo",
        onPressed: () async {
          dynamic newTask = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EnterTaskInfo(task: globalTaskList),
            ),
          );
          if (newTask != null) {
            setState(() {
              globalTaskList.add(newTask);
            });
            tasksBox.put("tasks", globalTaskList);
          }
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: globalTaskList.length,
              itemBuilder: (context, index) {
                final currentTask = globalTaskList[index];
                return Padding(
                  padding: const EdgeInsets.only(
                    top: 40.0,
                    left: 40,
                    right: 40,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: BoxBorder.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              currentTask[2] = !currentTask[2];
                            });
                          },
                          icon: Checkbox.adaptive(
                            value: currentTask[2],
                            onChanged: (value) {
                              setState(() {
                                currentTask[2] = value;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentTask[0],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                decoration: !currentTask[2]
                                    ? TextDecoration.none
                                    : TextDecoration.lineThrough,
                                decorationThickness: 3,
                              ),
                            ),
                            Text(
                              currentTask[1],
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    globalTaskList.removeAt(index);
                                    tasksBox.put("tasks", globalTaskList);
                                  });
                                },
                                icon: Icon(
                                  Icons.delete_outlined,
                                  color: const Color.fromARGB(255, 177, 58, 50),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// with hive

class TodoAppWithHive extends StatefulWidget {
  const TodoAppWithHive({super.key});
  @override
  State<TodoAppWithHive> createState() => _TodoAppWithHiveState();
}

class _TodoAppWithHiveState extends State<TodoAppWithHive> {
  final tasksBox = Hive.box("tasks_box");
  List globalTaskList = [];

  @override
  void initState() {
    globalTaskList = tasksBox.get("tasks", defaultValue: []);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(globalTaskList);
    return Scaffold(
      appBar: AppBar(
        title: Text("T o    D o ", style: TextStyle(color: Colors.white)),
        toolbarHeight: 100,
        backgroundColor: Colors.blue.shade500,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade500,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(50),
        ),
        tooltip: "Add Todo",
        onPressed: () async {
          dynamic newTask = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EnterTaskInfo(task: globalTaskList),
            ),
          );
          if (newTask != null) {
            setState(() {
              globalTaskList.add(newTask);
            });
            tasksBox.put("tasks", globalTaskList);
          }
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: globalTaskList.length,
              itemBuilder: (context, index) {
                final currentTask = globalTaskList[index];
                return Padding(
                  padding: const EdgeInsets.only(
                    top: 40.0,
                    left: 40,
                    right: 40,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: BoxBorder.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              currentTask[2] = !currentTask[2];
                            });
                          },
                          icon: Checkbox.adaptive(
                            value: currentTask[2],
                            onChanged: (value) {
                              setState(() {
                                currentTask[2] = value;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentTask[0],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                decoration: !currentTask[2]
                                    ? TextDecoration.none
                                    : TextDecoration.lineThrough,
                                decorationThickness: 3,
                              ),
                            ),
                            Text(
                              currentTask[1],
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    globalTaskList.removeAt(index);
                                    tasksBox.put("tasks", globalTaskList);
                                  });
                                },
                                icon: Icon(
                                  Icons.delete_outlined,
                                  color: const Color.fromARGB(255, 177, 58, 50),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
