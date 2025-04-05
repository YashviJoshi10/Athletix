import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShowGoalPage extends StatefulWidget {
  final Map<String, dynamic> goal;

  ShowGoalPage({required this.goal});

  @override
  _ShowGoalPageState createState() => _ShowGoalPageState();
}

class _ShowGoalPageState extends State<ShowGoalPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.goal['name'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(  // Wrap the Column with a SingleChildScrollView
          child: Column(
            children: [
              for (int index = 0; index < widget.goal['subGoals'].length; index++)
                _buildSubGoalItem(index, widget.goal['subGoals']),
              // Add the Congratulations message if all subgoals are completed
              if (_areAllSubGoalsCompleted(widget.goal['subGoals']))
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Congratulations! You have completed the Goal - ${widget.goal['name']}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to check if all subgoals are completed
  bool _areAllSubGoalsCompleted(List<dynamic> subGoals) {
    return subGoals.every((subGoal) => subGoal['status'] == "completed");
  }

  Widget _buildSubGoalItem(int index, List<dynamic> subGoals) {
    final subGoal = subGoals[index];
    bool isLast = index == subGoals.length - 1;
    bool isCompleted = subGoal['status'] == "completed";

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFixedIcon(isCompleted),
            if (!isLast) _buildConnectingLine(index, subGoals),
          ],
        ),
        SizedBox(width: 12),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      subGoal['text'],
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Row(
                    children: [
                      // Edit button
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editGoalName(index),
                      ),
                      // Check button
                      IconButton(
                        icon: Icon(
                          isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                          color: isCompleted ? Colors.green : null,
                        ),
                        onPressed: () => _toggleGoalStatus(index),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Edit goal name dialog
  Future<void> _editGoalName(int index) async {
    final TextEditingController controller = TextEditingController();
    controller.text = widget.goal['subGoals'][index]['text'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Goal Name'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter new goal name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateGoalNameInFirestore(index, controller.text);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Updates the goal name in Firestore
  Future<void> _updateGoalNameInFirestore(int index, String newGoalName) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      DocumentReference goalRef = FirebaseFirestore.instance.collection('goal_setting').doc(user.uid);
      DocumentSnapshot snapshot = await goalRef.get();
      if (!snapshot.exists) return;

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      List<dynamic> goals = List.from(data['goals']);

      int goalIndex = goals.indexWhere((g) => g['name'] == widget.goal['name']);
      if (goalIndex == -1) return;

      List<dynamic> subGoals = List.from(goals[goalIndex]['subGoals']);
      subGoals[index]['text'] = newGoalName;

      goals[goalIndex]['subGoals'] = subGoals;
      await goalRef.update({'goals': goals});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error updating goal name: $e")));
    }
  }

  Widget _buildConnectingLine(int index, List<dynamic> subGoals) {
    bool previousCompleted = subGoals[index]['status'] == "completed";

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: previousCompleted ? 60 : 0),
      duration: Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Container(
          width: 4,
          height: value,
          decoration: BoxDecoration(
            color: previousCompleted ? Colors.green : Colors.grey,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      },
    );
  }

  Widget _buildFixedIcon(bool isCompleted) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: isCompleted ? Colors.green : Colors.grey, width: 2),
      ),
      child: Center(
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? Colors.green : Colors.grey,
          ),
        ),
      ),
    );
  }

  Future<void> _toggleGoalStatus(int index) async {
    setState(() {
      final subGoal = widget.goal['subGoals'][index];
      subGoal['status'] = subGoal['status'] == "completed" ? "pending" : "completed";
    });

    await _updateSubGoalStatusInFirestore(index);
  }

  Future<void> _updateSubGoalStatusInFirestore(int index) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      DocumentReference goalRef = FirebaseFirestore.instance.collection('goal_setting').doc(user.uid);
      DocumentSnapshot snapshot = await goalRef.get();
      if (!snapshot.exists) return;

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      List<dynamic> goals = List.from(data['goals']);

      int goalIndex = goals.indexWhere((g) => g['name'] == widget.goal['name']);
      if (goalIndex == -1) return;

      List<dynamic> subGoals = List.from(goals[goalIndex]['subGoals']);
      subGoals[index]['status'] = subGoals[index]['status'] == "completed" ? "pending" : "completed";

      goals[goalIndex]['subGoals'] = subGoals;
      await goalRef.update({'goals': goals});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error updating status: $e")));
    }
  }
}
