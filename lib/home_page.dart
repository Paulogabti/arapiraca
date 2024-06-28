import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'perfil.dart';
import 'notificacoes.dart';
import 'package:google_fonts/google_fonts.dart';

// Substitua 'http://localhost:3000' pelo endereço do seu servidor backend Node.js
const String backendUrl = 'http://localhost:3000';

class Licitacao {
  final int id;
  final String numero;
  final String modalidade;
  final String objeto;
  final String responsavel;
  final String status;
  final int userId;

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
      map['id'] as int,
      map['numero'] as String,
      map['modalidade'] as String,
      map['objeto'] as String,
      map['responsavel'] as String,
      map['status'] as String,
      map['user_id'] as int,
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

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    final url = Uri.parse('$backendUrl/licitacoes?user_id=$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> licitacoesJson = json.decode(response.body);
        print('Dados recebidos: $licitacoesJson'); // Adicione este print para debug

        setState(() {
          licitacoes = licitacoesJson.map((licitacao) => Licitacao.fromMap(licitacao)).toList();
          _isLoading = false;
        });

        print('Lista de licitações: $licitacoes'); // Adicione este print para verificar a lista
      } else {
        throw Exception('Erro ao buscar licitações: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Erro ao buscar licitações: $error');
    }
  }

  void _showDeleteConfirmationDialog(Licitacao licitacao) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmação de Exclusão'),
          content: Text('Tem certeza que deseja excluir o processo de nº ${licitacao.numero}?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Excluir'),
              onPressed: () {
                _deleteLicitacao(licitacao.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _currentPasswordController = TextEditingController();
    final TextEditingController _newPasswordController = TextEditingController();
    final TextEditingController _confirmNewPasswordController = TextEditingController();

    void _updatePassword() async {
      final userId = Provider.of<AuthProvider>(context, listen: false).currentUser;
      final url = Uri.parse('http://localhost:3000/update-password');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'currentPassword': _currentPasswordController.text,
          'newPassword': _newPasswordController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Senha atualizada com sucesso')));
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Senha atual incorreta')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao atualizar a senha')));
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alterar Senha'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: _currentPasswordController,
                    decoration: InputDecoration(labelText: 'Senha Atual'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a senha atual';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _newPasswordController,
                    decoration: InputDecoration(labelText: 'Nova Senha'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a nova senha';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _confirmNewPasswordController,
                    decoration: InputDecoration(labelText: 'Confirmar Nova Senha'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, confirme a nova senha';
                      }
                      if (value != _newPasswordController.text) {
                        return 'As senhas não coincidem';
                      }
                      return null;
                    },
                  ),
                ],
              ),
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
              child: Text('Alterar'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _updatePassword();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
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
            Spacer(),
            HudsonIcon(),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'alterar_senha') {
                  _showChangePasswordDialog(context);
                } else if (value == 'logout') {
                  Provider.of<AuthProvider>(context, listen: false).logout();
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
              icon: CircleAvatar(
                child: Icon(Icons.person),
              ),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'alterar_senha',
                  child: Text('Alterar Senha'),
                ),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Sair'),
                ),
              ],
            ),
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
                          title: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Modalidade: ',
                                  style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: licitacao.modalidade,
                                  style: GoogleFonts.montserrat(),
                                ),
                              ],
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Número: ',
                                      style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: licitacao.numero,
                                      style: GoogleFonts.montserrat(),
                                    ),
                                  ],
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Objeto: ',
                                      style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: licitacao.objeto,
                                      style: GoogleFonts.montserrat(),
                                    ),
                                  ],
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Responsável: ',
                                      style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: licitacao.responsavel,
                                      style: GoogleFonts.montserrat(),
                                    ),
                                  ],
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Status: ',
                                      style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: licitacao.status,
                                      style: GoogleFonts.montserrat(),
                                    ),
                                  ],
                                ),
                              ),
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
                                  _showDeleteConfirmationDialog(licitacao);
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
    final userId = int.parse(Provider.of<AuthProvider>(context, listen: false).currentUser!); // Converter para int
    final _formKey = GlobalKey<FormState>();

    // Controladores de texto
    final TextEditingController _numeroController = TextEditingController();
    final TextEditingController _objetoController = TextEditingController();
    final TextEditingController _responsavelController = TextEditingController();

    // Variáveis para armazenar os valores selecionados
    String? _modalidade = 'Pregão Eletrônico';
    String? _status = 'Aberto';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Adicionar Licitação'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: _numeroController,
                    decoration: InputDecoration(labelText: 'Nº Processo'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o número do processo';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: _modalidade,
                    onChanged: (String? newValue) {
                      setState(() {
                        _modalidade = newValue!;
                      });
                    },
                    items: <String>['Pregão Eletrônico', 'Concorrência', 'Inexigibilidade', 'Adesão', 'Dispensa']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: InputDecoration(labelText: 'Modalidade'),
                  ),
                  TextFormField(
                    controller: _objetoController,
                    decoration: InputDecoration(labelText: 'Objeto'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o objeto do processo';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _responsavelController,
                    decoration: InputDecoration(labelText: 'Responsável'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o responsável pelo processo';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: _status,
                    onChanged: (String? newValue) {
                      setState(() {
                        _status = newValue!;
                      });
                    },
                    items: <String>[
                      'Aberto', 'Em Análise', 'Em Análise Técnica', 'Elaborando Minuta',
                      'Encaminhado para PGM', 'Elaborando Edital', 'Edital Publicado',
                      'Em Fase Licitatória', 'Em Análise de Proposta', 'Em Análise Documentação',
                      'Fase de Recurso', 'Homologado', 'Elaborando Contrato', 'Contrato Publicado',
                      'Revogado', 'Cancelado', 'Arquivado'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: InputDecoration(labelText: 'Status'),
                  ),
                ],
              ),
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
                if (_formKey.currentState!.validate()) {
                  Licitacao novaLicitacao = Licitacao(
                    0, // ID inicializado como 0, será sobrescrito pelo banco de dados
                    _numeroController.text,
                    _modalidade!,
                    _objetoController.text,
                    _responsavelController.text,
                    _status!,
                    userId, // Passar como int
                  );
                  _addLicitacao(novaLicitacao);
                  Navigator.of(context).pop();
                };
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
                Licitacao licitacaoAtualizada = Licitacao(
                  licitacao.id,
                  numero,
                  modalidade,
                  objeto,
                  responsavel,
                  status,
                  licitacao.userId,
                );
                _updateLicitacao(licitacaoAtualizada);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addLicitacao(Licitacao licitacao) async {
    final url = Uri.parse('$backendUrl/licitacoes');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(licitacao.toMap()),
      );

      if (response.statusCode == 201) {
        _fetchLicitacoes();
      } else {
        throw Exception('Erro ao adicionar licitação: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Erro ao adicionar licitação: $error');
    }
  }

  Future<void> _updateLicitacao(Licitacao licitacao) async {
    final url = Uri.parse('$backendUrl/licitacoes/${licitacao.id}');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(licitacao.toMap()),
      );

      if (response.statusCode == 200) {
        _fetchLicitacoes();
      } else {
        throw Exception('Erro ao atualizar licitação: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Erro ao atualizar licitação: $error');
    }
  }

  Future<void> _deleteLicitacao(int id) async {
    final url = Uri.parse('$backendUrl/licitacoes/$id');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        _fetchLicitacoes();
      } else {
        throw Exception('Erro ao deletar licitação: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Erro ao deletar licitação: $error');
    }
  }
}
