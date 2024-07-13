import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime selectedDate = DateTime.now();
  Map<DateTime, String> notes = {};

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    final response = await http.get(Uri.parse('http://localhost:3000/notes'));
    if (response.statusCode == 200) {
      List<dynamic> notesJson = json.decode(response.body);
      setState(() {
        notes = {
          for (var note in notesJson)
            DateTime.parse(note['note_date']): note['note']
        };
      });
    } else {
      throw Exception('Erro ao buscar anotações');
    }
  }

  void _addNoteDialog(DateTime date) {
    TextEditingController noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Adicionar Anotação'),
          content: TextField(
            controller: noteController,
            decoration: InputDecoration(labelText: 'Anotação'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Salvar'),
              onPressed: () async {
                if (noteController.text.isNotEmpty) {
                  try {
                    await _saveNote(date, noteController.text);
                    setState(() {
                      notes[date] = noteController.text;
                    });
                    Navigator.of(context).pop();
                  } catch (e) {
                    // Exibir mensagem de erro se a chamada da API falhar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao adicionar anotação: $e'),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveNote(DateTime date, String note) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/notes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': 1, // Substitua pelo ID do usuário atual
        'note_date': date.toIso8601String(),
        'note': note,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Erro ao adicionar anotação');
    }
  }

  @override
  Widget build(BuildContext context) {
    int daysInMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
    List<Widget> dayWidgets = [];

    for (int i = 1; i <= daysInMonth; i++) {
      DateTime day = DateTime(selectedDate.year, selectedDate.month, i);
      dayWidgets.add(
        GestureDetector(
          onDoubleTap: () {
            _addNoteDialog(day);
          },
          child: Container(
            margin: EdgeInsets.all(4.0),
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: notes.containsKey(day) ? Colors.blueAccent : Colors.grey[200],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat.d().format(day),
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                if (notes.containsKey(day))
                  Text(
                    notes[day]!,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat.yMMMM().format(selectedDate)),
      ),
      body: GridView.count(
        crossAxisCount: 7,
        children: dayWidgets,
      ),
    );
  }
}
