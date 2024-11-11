import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../models/note.dart';
import '../utils/database_helper.dart';
import '../utils/recently_deleted_manager.dart';
import 'note_detail.dart';

class NoteList extends StatefulWidget {
  const NoteList({super.key});

  @override
  State<StatefulWidget> createState() {
    return NoteListState();
  }
}

List<Note> recentlyDeletedNotes = [];

class NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList = [
  ];
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (noteList.isEmpty) {
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        backgroundColor: Colors.blueAccent,
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetail(Note('', '', 2), 'Add Note');
        },
        tooltip: 'Add Note',
        child: const Icon(Icons.add),
      ),
    );
  }

  ListView getNoteListView() {
    TextStyle? titleStyle = Theme.of(context).textTheme.titleSmall;

    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: getPriorityColor(noteList[position].priority),
              child: getPriorityIcon(noteList[position].priority),
            ),
            title: Text(noteList[position].title, style: titleStyle),
            subtitle: Text(noteList[position].date),
            trailing: GestureDetector(
              child: const Icon(Icons.delete, color: Colors.black),
              onTap: () {
                _delete(context, noteList[position]);
              },
            ),
            onTap: () {
              navigateToDetail(noteList[position], 'Edit Note');
            },
          ),
        );
      },
    );
  }

  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.yellow;
      default:
        return Colors.yellow;
    }
  }

  Icon getPriorityIcon(int priority) {
    return priority == 1
        ? const Icon(Icons.play_arrow)
        : const Icon(Icons.keyboard_arrow_right);
  }

  void _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id!);
    if (result != 0) {
      _showSnackBar(context, 'Note Deleted Successfully');
      RecentlyDeletedNotesManager.addDeletedNote(note);
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(Note note, String title) async {
    bool? result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note, title);
    }));

    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    Future<Database> dbFuture = databaseHelper.database;
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        if (noteList.isEmpty) {
          _addDummyData();
        } else {
          setState(() {
            this.noteList = noteList;
            this.count = noteList.length;
          });
        }
      });
    });
  }

  void _addDummyData() {
    List<Note> dummyNotes = [

    ];

    for (var note in dummyNotes) {
      databaseHelper.insertNote(note);
    }

    setState(() {
      noteList = dummyNotes;
      count = dummyNotes.length;
    });
  }
}
