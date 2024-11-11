import '../models/note.dart';

class RecentlyDeletedNotesManager {
  static final List<Note> _recentlyDeletedNotes = [];

  static List<Note> get recentlyDeletedNotes => _recentlyDeletedNotes;

  static void addDeletedNote(Note note) {
    _recentlyDeletedNotes.add(note);
  }

  static void removeDeletedNoteAt(int index) {
    _recentlyDeletedNotes.removeAt(index);
  }

  static void clear() {
    _recentlyDeletedNotes.clear();
  }
}

