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
    // Show confirmation dialog before deleting the goal
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Are you sure?"),
          content: Text("Do you want to delete this goal? This action cannot be undone."),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog without deleting
              },
              child: Text("Cancel"),
            ),
            // Delete Button
            ElevatedButton(
              onPressed: () {
                setState(() {
                  goals.removeAt(index); // Remove the goal from the list
                });
                _saveGoalsToFirestore(); // Update Firestore
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Delete"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Use backgroundColor instead of primary
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Goal Setting", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchGoalsFromFirestore,
            tooltip: 'Refresh Goals',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Goals', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Expanded(
              child: goals.isEmpty
                  ? Center(child: Text("No goals yet. Start adding some!"))
                  : ListView.separated(
                itemCount: goals.length,
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (context, index) {
                  final goal = goals[index];
                  final goalName = goal['name'] ?? "Unnamed Goal";
                  final bool allCompleted = goal['subGoals'].every((subGoal) => subGoal['status'] == "completed");

                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: Icon(
                        allCompleted ? Icons.check_circle : Icons.error_outline,
                        color: allCompleted ? Colors.green : Colors.red,
                        size: 30,
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(goalName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editGoal(index),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteGoal(index), // Calls the delete confirmation dialog
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddGoalPage,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
        tooltip: "Add Goal",
      ),
    );
  }
}
