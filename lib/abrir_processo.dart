import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, String>> _processos = [];

  void _adicionarProcesso(BuildContext context) {
    String responsavel = '';
    String modalidade = '';
    String numeroProcesso = '';
    String objeto = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Novo Processo'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(labelText: 'Responsável'),
                  onChanged: (value) {
                    responsavel = value;
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Modalidade'),
                  items: ['Pregão Eletrônico', 'Concorrência', 'Adesão', 'Inexigibilidade', 'Credenciamento', 'Dispensa']
                      .map((modalidade) => DropdownMenuItem(
                            child: Text(modalidade),
                            value: modalidade,
                          ))
                      .toList(),
                  onChanged: (value) {
                    modalidade = value!;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Nº processo'),
                  onChanged: (value) {
                    numeroProcesso = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Objeto'),
                  onChanged: (value) {
                    objeto = value;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (responsavel.isNotEmpty && modalidade.isNotEmpty && numeroProcesso.isNotEmpty && objeto.isNotEmpty) {
                  setState(() {
                    _processos.insert(0, {
                      'Responsável': responsavel,
                      'Modalidade': modalidade,
                      'Nº processo': numeroProcesso,
                      'Objeto': objeto,
                    });
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Adicionar'),
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
        title: Text('Home Page'),
        actions: [
          IconButton(
            onPressed: () {
              _adicionarProcesso(context);
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Tabela de processos
            if (_processos.isNotEmpty)
              DataTable(
                columns: [
                  DataColumn(label: Text('Responsável')),
                  DataColumn(label: Text('Modalidade')),
                  DataColumn(label: Text('Nº processo')),
                  DataColumn(label: Text('Objeto')),
                ],
                rows: _processos.map((processo) {
                  return DataRow(cells: [
                    DataCell(Text(processo['Responsável']!)),
                    DataCell(Text(processo['Modalidade']!)),
                    DataCell(Text(processo['Nº processo']!)),
                    DataCell(Text(processo['Objeto']!)),
                  ]);
                }).toList(),
              )
            else
              Text('Nenhum processo adicionado.'),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}
