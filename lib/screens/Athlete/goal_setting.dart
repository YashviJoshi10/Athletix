import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_goal.dart';
import 'show_goal.dart';

class GoalSettingPage extends StatefulWidget {
  @override
  _GoalSettingPageState createState() => _GoalSettingPageState();
}

class _GoalSettingPageState extends State<GoalSettingPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> goals = [];

  @override
  void initState() {
    super.initState();
    _fetchGoalsFromFirestore();
  }

  Future<void> _fetchGoalsFromFirestore() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('goal_setting').doc(user.uid).get();
    if (doc.exists) {
      setState(() {
        goals = List<Map<String, dynamic>>.from(doc['goals']);
      });
    }
  }

  void _navigateToAddGoalPage() async {
    final newGoal = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddGoalPage()),
    );

    if (newGoal != null) {
      setState(() {
        _addGoal(newGoal);
      });
      await _saveGoalsToFirestore();
    }
  }

  void _addGoal(Map<String, dynamic> newGoal) {
    goals.add({
      'name': newGoal['goalName'],
      'subGoals': newGoal['subGoals'],
    });
  }

  Future<void> _saveGoalsToFirestore() async {
    User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User not logged in!")));
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('goal_setting').doc(user.uid).set({
        'uid': user.uid,
        'goals': goals,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Goals saved successfully!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error saving goals: $e")));
    }
  }

  void _editGoal(int index) async {
    final currentGoal = goals[index]['name'];
    String? newGoalName = await showDialog(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController(text: currentGoal);
        return AlertDialog(
          title: Text("Edit Goal"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: "Goal Name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text("Save"),
            ),
          ],
        );
      },
    );

    if (newGoalName != null && newGoalName.isNotEmpty) {
      setState(() {
        goals[index]['name'] = newGoalName;
      });
      await _saveGoalsToFirestore();
    }
  }

  void _deleteGoal(int index) {
    setState(() {
      goals.removeAt(index);
    });
    _saveGoalsToFirestore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Goal Setting")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Goals', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  final goal = goals[index];
                  final goalName = goal['name'] ?? "Unnamed Goal";
                  final bool allCompleted = goal['subGoals'].every((subGoal) => subGoal['status'] == "completed");

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: Icon(
                        allCompleted ? Icons.check_circle : Icons.error_outline,
                        color: allCompleted ? Colors.green : Colors.red,
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(goalName)),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _editGoal(index),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _deleteGoal(index),
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShowGoalPage(goal: goal),
                          ),
                        );
                        setState(() {}); // Refresh UI after returning
                      },
                    ),
                  );
                },
              ),

            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _navigateToAddGoalPage,
                child: Text("Add Goal"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
