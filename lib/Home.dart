import 'package:flutter/material.dart';
import 'package:my_notes/helper/NoteHelper.dart';
import 'package:my_notes/model/Note.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  TextEditingController _controllerTitle = TextEditingController();
  TextEditingController _controllerDescription = TextEditingController();
  var _db = NoteHelper();
  List<Note> _notes = List<Note>();

  _displayCreateDialog({Note note}) {
    String saveEditText = "";
    if (note == null) {
      _controllerTitle.text = "";
      _controllerDescription.text = "";
      saveEditText = "Add";
    } else {
      _controllerTitle.text = note.title;
      _controllerDescription.text = note.description;
      saveEditText = "Edit";
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("$saveEditText note"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
               controller: _controllerTitle,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: "Title",
                  hintText: "Type title..."
                ),
              ),
              TextField(
               controller: _controllerDescription,
                decoration: InputDecoration(
                  labelText: "Description",
                  hintText: "Type description..."
                ),
              ),
            ],
          ),
          actions: [
            FlatButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            FlatButton(
              onPressed: () {
                // Save
                _saveUpdateNote(selectedNote: note);
                Navigator.pop(context);
              },
              child: Text(saveEditText),
            ),
          ],
        );
      }
    );
  }

  _getNotes() async {
    List receivedNotes = await _db.getNotes();
    List<Note> notesTemp = List<Note>();
    for (var item in receivedNotes) {
      Note note = Note.fromMap(item);
      notesTemp.add(note);
    }
    setState(() {
      _notes = notesTemp;
    });
    notesTemp = null;
  }

  _saveUpdateNote({Note selectedNote}) async {
    String title = _controllerTitle.text;
    String description = _controllerDescription.text;

    if (selectedNote == null) {
      Note note = Note(title, description, DateTime.now().toString());
      int result = await _db.saveNote(note);
    } else {
      selectedNote.title = title;
      selectedNote.description = description;
      selectedNote.date = DateTime.now().toString();
      int result = await _db.updateNote(selectedNote);
    }

    _controllerTitle.clear();
    _controllerDescription.clear();

    _getNotes();
  }

  _formatDate(String date) {
    initializeDateFormatting("pt_BR");
    //var formatter = DateFormat("d/MMMM/y H:m:s");
    var formatter = DateFormat.yMd("pt_BR");
    DateTime convertedDate = DateTime.parse(date);
    String formattedDate = formatter.format(convertedDate);
    return formattedDate;
  }

  _removeNote(int id) async {
    await _db.removeNote(id);
    _getNotes();
  }

  @override
  void initState() {
    super.initState();
    _getNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Notes"),
        backgroundColor: Colors.lightGreen,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                final note = _notes[index];
                return Card(
                  child: ListTile(
                    title: Text(note.title),
                    subtitle: Text("${_formatDate(note.date)} - ${note.description}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _displayCreateDialog(note: note);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: Icon(
                              Icons.edit,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _removeNote(note.id);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(right: 0),
                            child: Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              itemCount: _notes.length,
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
        onPressed: () {
          _displayCreateDialog();
        },
      ),
    );
  }
}
