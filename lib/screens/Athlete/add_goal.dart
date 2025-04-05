import 'package:flutter/material.dart';

class AddGoalPage extends StatefulWidget {
  const AddGoalPage({Key? key}) : super(key: key);

  @override
  AddGoalPageState createState() => AddGoalPageState();
}

class AddGoalPageState extends State<AddGoalPage> {
  final TextEditingController goalNameController = TextEditingController();
  final TextEditingController subGoalController = TextEditingController();
  String? selectedGoalType;
  List<Map<String, String>> subGoals = [];
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Goal", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Goal Name input
              Text("Goal Name", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              TextField(
                controller: goalNameController,
                decoration: InputDecoration(
                  hintText: "Enter your goal name",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              SizedBox(height: 20),

              // Goal Type dropdown
              Text("Goal Type", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              DropdownButton<String>(
                hint: Text("Select Goal Type"),
                value: selectedGoalType,
                isExpanded: true,
                items: <String>['Small', 'Large'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(fontSize: 16)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedGoalType = value;
                  });
                },
              ),
              SizedBox(height: 20),

              // Sub Goal input
              Text("Add your Sub Goal", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              TextField(
                controller: subGoalController,
                decoration: InputDecoration(
                  hintText: "Enter your sub-goal",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              SizedBox(height: 20),

              // Save sub-goal button
              SizedBox(
                width: double.infinity, // Set width to occupy the available space
                child: ElevatedButton.icon(
                  onPressed: isLoading
                      ? null // Disable button while loading
                      : () {
                    if (subGoalController.text.isNotEmpty && selectedGoalType != null) {
                      setState(() {
                        isLoading = true;
                      });
                      subGoals.add({
                        'text': subGoalController.text,
                        'type': selectedGoalType!,
                      });
                      subGoalController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Sub-goal added!")),
                      );
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  icon: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Icon(Icons.add, size: 24),
                  label: Text(isLoading ? "Adding..." : "Save this Sub Goal"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Save all button
              SizedBox(
                width: double.infinity, // Set width to occupy the available space
                child: ElevatedButton.icon(
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
                  icon: Icon(Icons.save),
                  label: Text("Save All Goals"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
