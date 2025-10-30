import 'package:flutter/material.dart';

class EnterTaskInfo extends StatefulWidget {
  const EnterTaskInfo({super.key, required this.task});
  final List task;
  @override
  State<EnterTaskInfo> createState() => _EnterTaskInfoState();
}

class _EnterTaskInfoState extends State<EnterTaskInfo> {
  TextEditingController taskName = TextEditingController();
  TextEditingController dueDate = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close, color: Colors.black),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "New Task",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
            SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "What are you planning?",
                  style: TextStyle(
                    color: const Color.fromARGB(255, 113, 113, 113),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30.0,
                vertical: 10,
              ),
              child: TextField(
                controller: taskName,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                cursorColor: Colors.blue.shade500,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.description, color: Colors.black),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue.shade500),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue.shade500),
                  ),
                  hintText: "Task Description",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 50),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "What's the due date?",
                  style: TextStyle(
                    color: const Color.fromARGB(255, 113, 113, 113),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30.0,
                vertical: 10,
              ),
              child: TextField(
                controller: dueDate,
                maxLines: null,
                keyboardType: TextInputType.datetime,
                cursorColor: Colors.blue.shade500,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue.shade500),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue.shade500),
                  ),
                  hintText: "yyyy-mm-dd",
                  prefixIcon: Icon(Icons.calendar_month, color: Colors.black),
                ),
              ),
            ),
            SizedBox(height: 50),
            GestureDetector(
              onTap: () {
                Navigator.pop(context, [taskName.text, dueDate.text, false]);
              },
              child: Container(
                padding: EdgeInsets.all(20),
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.blue.shade500,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Create Task",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
