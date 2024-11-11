import 'package:flutter/material.dart';
import '../models/note.dart';
import '../utils/database_helper.dart';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  const NoteDetail(this.note, this.appBarTitle, {Key? key}) : super(key: key);

  @override
  State<NoteDetail> createState() => _NoteDetailState();
}

class _NoteDetailState extends State<NoteDetail> {
  static final _priorities = ['High', 'Low'];
  final DatabaseHelper _helper = DatabaseHelper();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _descriptionController = TextEditingController(text: widget.note.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle? textStyle = Theme.of(context).textTheme.titleLarge;

    return WillPopScope(
      onWillPop: () async {
        _moveToLastScreen();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.appBarTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _moveToLastScreen,
          ),
          backgroundColor: Colors.blueAccent,
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView(
            children: <Widget>[
              ListTile(
                title: DropdownButton<String>(
                  items: _priorities.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  style: textStyle,
                  value: _getPriorityAsString(widget.note.priority),
                  onChanged: (String? newValue) {
                    setState(() {
                      _updatePriorityAsInt(newValue!);
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: TextField(
                  controller: _titleController,
                  style: textStyle,
                  onChanged: (value) => _updateTitle(),
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: TextField(
                  controller: _descriptionController,
                  style: textStyle,
                  onChanged: (value) => _updateDescription(),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Theme.of(context).primaryColorLight,
                          backgroundColor: Theme.of(context).primaryColorDark,
                        ),
                        onPressed: _save,
                        child: const Text(
                          'Save',
                          textScaleFactor: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5.0),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Theme.of(context).primaryColorLight,
                          backgroundColor: Theme.of(context).primaryColorDark,
                        ),
                        onPressed: _delete,
                        child: const Text(
                          'Delete',
                          textScaleFactor: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _moveToLastScreen() {
    Navigator.pop(context, true);
  }

  void _updatePriorityAsInt(String value) {
    widget.note.priority = (value == 'High') ? 1 : 2;
  }

  String _getPriorityAsString(int value) {
    return (value == 1) ? 'High' : 'Low';
  }

  void _updateTitle() {
    widget.note.title = _titleController.text;
  }

  void _updateDescription() {
    widget.note.description = _descriptionController.text;
  }

  Future<void> _save() async {
    _moveToLastScreen();

    widget.note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (widget.note.id != null) {
      result = await _helper.updateNote(widget.note);
    } else {
      result = await _helper.insertNote(widget.note);
    }

    _showAlertDialog(
      context, 'Status',
      result != 0 ? 'Note Saved Successfully' : 'Problem Saving Note',
    );
  }

  Future<void> _delete() async {
    _moveToLastScreen();

    if (widget.note.id == null) {
      _showAlertDialog(context, 'Status', 'No Note was deleted');
      return;
    }

    int result = await _helper.deleteNote(widget.note.id!);
    _showAlertDialog(
      context,
      'Status',
      result != 0 ? 'Note Deleted Successfully' : 'Error Occurred while Deleting Note',
    );
  }

  void _showAlertDialog(BuildContext context, String title, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
