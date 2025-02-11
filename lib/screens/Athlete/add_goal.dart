import 'package:flutter/material.dart';

class AddGoalPage extends StatefulWidget {
  @override
  _AddGoalPageState createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> {
  final TextEditingController goalNameController = TextEditingController();
  final TextEditingController goalTextController = TextEditingController();
  String? selectedGoalType;
  List<Map<String, String>> subGoals = []; // Stores sub-goals

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Goal")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Goal Name"),
            TextField(controller: goalNameController),
            SizedBox(height: 20),
            Text("Goal Type"),
            DropdownButton<String>(
              hint: Text("Select Goal Type"),
              value: selectedGoalType,
              items: <String>['Small', 'Large'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedGoalType = value;
                });
              },
            ),
            SizedBox(height: 20),
            Text("Goal Description"),
            TextField(controller: goalTextController),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (goalNameController.text.isNotEmpty && selectedGoalType != null && goalTextController.text.isNotEmpty) {
                  subGoals.add({
                    'text': goalTextController.text,
                    'type': selectedGoalType!,
                  });
                  goalTextController.clear(); // Clear the text field
                  // Ask for another goal
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Goal added!")),
                  );
                }
              },
              child: Text("Add Another Goal"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (goalNameController.text.isNotEmpty && subGoals.isNotEmpty) {
                  Navigator.pop(context, {
                    'goalName': goalNameController.text,
                    'subGoals': subGoals,
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please enter a goal name and at least one sub-goal.")),
                  );
                }
              },
              child: Text("Save Goals"),
            ),
          ],
        ),
      ),
    );
  }
}
