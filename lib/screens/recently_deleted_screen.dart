import 'package:flutter/material.dart';
import '../utils/recently_deleted_manager.dart';
import '../utils/database_helper.dart';
import '../models/note.dart';

class RecentlyDeletedScreen extends StatefulWidget {
  const RecentlyDeletedScreen({Key? key}) : super(key: key);

  @override
  _RecentlyDeletedScreenState createState() => _RecentlyDeletedScreenState();
}

class _RecentlyDeletedScreenState extends State<RecentlyDeletedScreen> {
  Color _getPriorityColor(int priority) {
    return priority == 1 ? Colors.red : Colors.yellow;
  }

  Icon _getPriorityIcon(int priority) {
    return priority == 1
        ? const Icon(Icons.play_arrow)
        : const Icon(Icons.keyboard_arrow_right);
  }

  void _recoverNote(BuildContext context, Note note, int index) async {
    if (index < RecentlyDeletedNotesManager.recentlyDeletedNotes.length) {
      setState(() {
        RecentlyDeletedNotesManager.removeDeletedNoteAt(index);
      });
      DatabaseHelper().insertNote(note);
      _showSnackBar(context, 'Note Recovered Successfully');
    }
  }

  void _deleteForever(BuildContext context, Note note, int index) {
    if (index < RecentlyDeletedNotesManager.recentlyDeletedNotes.length) {
      setState(() {
        RecentlyDeletedNotesManager.removeDeletedNoteAt(index);
      });

      _showSnackBar(context, 'Note Deleted Permanently');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final recentlyDeletedNotes =
        RecentlyDeletedNotesManager.recentlyDeletedNotes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recently Deleted Notes'),
        backgroundColor: Colors.blueAccent,
      ),
      body: recentlyDeletedNotes.isEmpty
          ? const Center(child: Text("No recently deleted notes"))
          : ListView.builder(
              itemCount: recentlyDeletedNotes.length,
              itemBuilder: (context, index) {
                final note = recentlyDeletedNotes[index];
                return Card(
                  color: Colors.white,
                  elevation: 2.0,
                  child: ListTile(
                    title: Text(note.title),
                    subtitle: Text(note.date),
                    leading: CircleAvatar(
                      backgroundColor: _getPriorityColor(note.priority),
                      child: _getPriorityIcon(note.priority),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.restore, color: Colors.green),
                          onPressed: () {
                            _recoverNote(context, note, index);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_forever,
                              color: Colors.red),
                          onPressed: () {
                            _deleteForever(context, note, index);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );


  }
}
