import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'dart:convert'; // Importe o pacote dart:convert para usar json.decode
import 'package:http/http.dart' as http;

const String supabaseUrl = 'https://uiublaevwngtqbklkjjz.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVpdWJsYWV2d25ndHFia2xramp6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTc5MzY2MzAsImV4cCI6MjAzMzUxMjYzMH0.b8DR31fj8gAi54e3KxyrIT3kn7FmT90IZ4AZOBOYSmo';

class Licitacao {
  final String id;
  String numero;
  String modalidade;
  String objeto;
  String responsavel;
  String status;
  String userId;

  Licitacao(this.id, this.numero, this.modalidade, this.objeto, this.responsavel, this.status, this.userId);


  Color getBackgroundColor() {
    switch (modalidade) {
      case 'Pregão Eletrônico':
        return Colors.orange[100]!;
      case 'Concorrência':
        return Colors.blue[100]!;
      case 'Inexigibilidade':
        return Colors.purple[100]!;
      case 'Adesão':
        return Colors.green[100]!;
      case 'Dispensa':
        return Colors.grey[200]!;
      default:
        return Colors.white;
    }
  }

  factory Licitacao.fromMap(Map<String, dynamic> map) {
    return Licitacao(
      map['id'],
      map['numero'],
      map['modalidade'],
      map['objeto'],
      map['responsavel'],
      map['status'],
      map['user_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numero': numero,
      'modalidade': modalidade,
      'objeto': objeto,
      'responsavel': responsavel,
      'status': status,
      'user_id': userId,
    };
  }
}

class LicitacoesScreen extends StatefulWidget {
  @override
  _LicitacoesScreenState createState() => _LicitacoesScreenState();
}

class _LicitacoesScreenState extends State<LicitacoesScreen> {
  final supabase = Supabase.instance.client; // Supondo que você tenha inicializado o Supabase
  List<Licitacao> licitacoes = [];
  List<String> filtrosSelecionados = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _fetchLicitacoes();
    });
  }


  Future<void> _fetchLicitacoes() async {
    final userId = Provider.of<AuthProvider>(context, listen: false).currentUser;
    final url = Uri.parse('$supabaseUrl/rest/v1/licitacoes?user_id=$userId');

    try {
      final response = await http.get(url, headers: {
        'apikey': '$supabaseAnonKey',
        'Authorization': 'Bearer $supabaseAnonKey'
      });

      if (response.statusCode == 200) {
        List<dynamic> licitacoesJson = json.decode(response.body); // Corrigido com a importação de dart:convert
        setState(() {
          licitacoes = licitacoesJson.map((licitacao) => Licitacao.fromMap(licitacao)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Erro ao buscar licitações: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Erro ao buscar licitações: $error');
    }
}



  @override
  Widget build(BuildContext context) {
    List<Licitacao> licitacoesFiltradas = filtrosSelecionados.isEmpty
        ? licitacoes
        : licitacoes.where((licitacao) => filtrosSelecionados.contains(licitacao.modalidade)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 40),
            SizedBox(width: 10),
            Text('Ambiente de Trabalho - CPC-Obras'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: Text('Concorrência'),
                    selected: filtrosSelecionados.contains('Concorrência'),
                    onSelected: (bool selected) {
                      _toggleFiltro('Concorrência', selected);
                    },
                  ),
                  FilterChip(
                    label: Text('Pregão Eletrônico'),
                    selected: filtrosSelecionados.contains('Pregão Eletrônico'),
                    onSelected: (bool selected) {
                      _toggleFiltro('Pregão Eletrônico', selected);
                    },
                  ),
                  FilterChip(
                    label: Text('Dispensa'),
                    selected: filtrosSelecionados.contains('Dispensa'),
                    onSelected: (bool selected) {
                      _toggleFiltro('Dispensa', selected);
                    },
                  ),
                  FilterChip(
                    label: Text('Adesão'),
                    selected: filtrosSelecionados.contains('Adesão'),
                    onSelected: (bool selected) {
                      _toggleFiltro('Adesão', selected);
                    },
                  ),
                  FilterChip(
                    label: Text('Inexigibilidade'),
                    selected: filtrosSelecionados.contains('Inexigibilidade'),
                    onSelected: (bool selected) {
                      _toggleFiltro('Inexigibilidade', selected);
                    },
                  ),
                ],
              ),
            ),
          ),
          Divider(),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: licitacoesFiltradas.length,
                    itemBuilder: (context, index) {
                      final licitacao = licitacoesFiltradas[index];
                      return Card(
                        color: licitacao.getBackgroundColor(),
                        child: ListTile(
                          title: Text('Modalidade: ${licitacao.modalidade}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Número: ${licitacao.numero}'),
                              Text('Objeto: ${licitacao.objeto}'),
                              Text('Responsável: ${licitacao.responsavel}'),
                              Text('Status: ${licitacao.status}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  _showEditDialog(licitacao);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  _deleteLicitacao(licitacao.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _toggleFiltro(String filtro, bool selected) {
    setState(() {
      if (selected) {
        filtrosSelecionados.add(filtro);
      } else {
        filtrosSelecionados.remove(filtro);
      }
    });
  }

  void _showAddDialog() {
    final userId = Provider.of<AuthProvider>(context, listen: false).currentUser;
    String numero = '';
    String modalidade = '';
    String objeto = '';
    String responsavel = '';
    String status = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Adicionar Licitação'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(labelText: 'Número'),
                  onChanged: (value) {
                    setState(() {
                      numero = value;
                    });
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Modalidade'),
                  onChanged: (value) {
                    setState(() {
                      modalidade = value;
                    });
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Objeto'),
                  onChanged: (value) {
                    setState(() {
                      objeto = value;
                    });
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Responsável'),
                  onChanged: (value) {
                    setState(() {
                      responsavel = value;
                    });
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Status'),
                  onChanged: (value) {
                    setState(() {
                      status = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
  child: Text('Adicionar'),
  onPressed: () {
    Licitacao novaLicitacao = Licitacao(
      '', // UUID não é necessário aqui, pois é gerado automaticamente
      numero,
      modalidade,
      objeto,
      responsavel,
      status,
      userId!, // Força que userId não seja null
    );
    _addLicitacao(novaLicitacao);
    Navigator.of(context).pop();
  },
),

          ],
        );
      },
    );
  }

  void _showEditDialog(Licitacao licitacao) {

    String numero = licitacao.numero;
    String modalidade = licitacao.modalidade;
    String objeto = licitacao.objeto;
    String responsavel = licitacao.responsavel;
    String status = licitacao.status;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Licitação'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(labelText: 'Número'),
                  controller: TextEditingController(text: numero),
                  onChanged: (value) {
                    setState(() {
                      numero = value;
                    });
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Modalidade'),
                  controller: TextEditingController(text: modalidade),
                  onChanged: (value) {
                    setState(() {
                      modalidade = value;
                    });
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Objeto'),
                  controller: TextEditingController(text: objeto),
                  onChanged: (value) {
                    setState(() {
                      objeto = value;
                    });
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Responsável'),
                  controller: TextEditingController(text: responsavel),
                  onChanged: (value) {
                    setState(() {
                      responsavel = value;
                    });
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Status'),
                  controller: TextEditingController(text: status),
                  onChanged: (value) {
                    setState(() {
                      status = value;
                    });
                  },
                ),
              ],
            ),
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
              onPressed: () {
                licitacao.numero = numero;
                licitacao.modalidade = modalidade;
                licitacao.objeto = objeto;
                licitacao.responsavel = responsavel;
                licitacao.status = status;
                _updateLicitacao(licitacao);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

Future<void> _addLicitacao(Licitacao licitacao) async {
  try {
    await supabase
     .from('licitacoes')
     .insert(licitacao.toMap());
    _fetchLicitacoes();
  } catch (error) {
    print('Erro ao adicionar licitação: $error');
  }
}

Future<void> _updateLicitacao(Licitacao licitacao) async {
  try {
    await supabase
     .from('licitacoes')
       .update(licitacao.toMap())
       .eq('id', licitacao.id);
    _fetchLicitacoes();
  } catch (error) {
    print('Erro ao atualizar licitação: $error');
  }
}

Future<void> _deleteLicitacao(String id) async {
  try {
    await supabase
     .from('licitacoes')
       .delete()
       .eq('id', id);
    _fetchLicitacoes();
  } catch (error) {
    print('Erro ao deletar licitação: $error');
  }
}
}