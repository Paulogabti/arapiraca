import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Para trabalhar com a formatação de datas
import 'notificacoes.dart'; // Importar o HudsonIcon
import 'relatorios.dart';

// Substitua 'http://localhost:3000' pelo endereço do seu servidor backend Node.js
const String backendUrl = 'http://localhost:3000';

class Licitacao {
  final int id;
  final String numero;
  final String modalidade;
  final String numeroModalidade; // Novo campo
  final String objeto;
  final String responsavel;
  final String status;
  final String data;
  final String observacoes;
  final int userId;

  Licitacao(
    this.id,
    this.numero,
    this.modalidade,
    this.numeroModalidade, // Novo campo no construtor
    this.objeto,
    this.responsavel,
    this.status,
    this.data,
    this.observacoes,
    this.userId,
  );

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
      case 'Chamada Pública':
        return Colors.green[200]!;
      default:
        return Colors.white;
    }
  }

  factory Licitacao.fromMap(Map<String, dynamic> map) {
    return Licitacao(
      map['id'] as int,
      map['numero'] as String,
      map['modalidade'] as String,
      map['numero_modalidade'] as String? ?? '', // Verifique se é null e defina um valor padrão
      map['objeto'] as String,
      map['responsavel'] as String,
      map['status'] as String,
      map['data'] as String,
      map['observacoes'] as String,
      map['user_id'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numero': numero,
      'modalidade': modalidade,
      'numero_modalidade': numeroModalidade.isEmpty ? 'N/A' : numeroModalidade, // Garanta que não é null
      'objeto': objeto,
      'responsavel': responsavel,
      'status': status,
      'data': data,
      'observacoes': observacoes,
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
  int currentYear = DateTime.now().year;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _fetchLicitacoes(year: currentYear);
    });
  }

  Future<void> _fetchLicitacoes({int? year}) async {
    final userId = Provider.of<AuthProvider>(context, listen: false).currentUser;
    String url = '$backendUrl/licitacoes?user_id=$userId';

    if (year != null) {
      url += '&year=$year';
    }

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> licitacoesJson = json.decode(response.body);

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

  void _updateYear(int year) {
    setState(() {
      currentYear = year;
      _fetchLicitacoes(year: currentYear);
    });
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

  void _filterLicitacoes() {
    setState(() {
      // Isso forçará a reconstrução da interface do usuário com base no searchQuery
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Licitacao> licitacoesFiltradas = filtrosSelecionados.isEmpty
        ? licitacoes
        : licitacoes.where((licitacao) => filtrosSelecionados.contains(licitacao.modalidade)).toList();

    if (searchQuery.isNotEmpty) {
      licitacoesFiltradas = licitacoesFiltradas
          .where((licitacao) =>
              licitacao.numero.contains(searchQuery) ||
              licitacao.modalidade.contains(searchQuery) ||
              licitacao.objeto.contains(searchQuery) ||
              licitacao.responsavel.contains(searchQuery) ||
              licitacao.status.contains(searchQuery) ||
              licitacao.data.contains(searchQuery) ||
              licitacao.observacoes.contains(searchQuery))
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
  title: Row(
    children: [
      Image.asset('assets/logo.png', height: 40),
      SizedBox(width: 10),
      Text('Ambiente de Trabalho - CPC-Obras'),
      Spacer(),
      HudsonIcon(),
      SizedBox(width: 16), // Adicionando espaçamento proporcional
      RelatoriosIcon(), // Adicionar o RelatoriosIcon aqui
      SizedBox(width: 16), // Adicionando espaçamento proporcional
      PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'alterar_senha') {
            _showChangePasswordDialog(context);
          } else if (value == 'logout') {
            Provider.of<AuthProvider>(context, listen: false).logout();
            Navigator.of(context).pushReplacementNamed('/login');
          }
        },
        icon: Tooltip(
          message: 'Opções do usuário',
          child: CircleAvatar(
            child: Icon(Icons.person),
          ),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    _updateYear(currentYear - 1);
                  },
                ),
                Text(
                  '${currentYear - 1}',
                  style: GoogleFonts.montserrat(),
                ),
                SizedBox(width: 20),
                Text(
                  '$currentYear',
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 20),
                Text(
                  '${currentYear + 1}',
                  style: GoogleFonts.montserrat(),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () {
                    _updateYear(currentYear + 1);
                  },
                ),
                Spacer(), // Adicionando um Spacer para empurrar a lupa para a direita
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _filterLicitacoes();
                  },
                ),
                Container(
                  width: 200,
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Procurar processos',
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                  FilterChip(
                    label: Text('Chamada Pública'),
                    selected: filtrosSelecionados.contains('Chamada Pública'),
                    onSelected: (bool selected) {
                      _toggleFiltro('Chamada Pública', selected);
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
                              RichText(
                                text: TextSpan(
    children: [
      TextSpan(
        text: 'Data: ',
        style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text: DateFormat('dd-MM-yyyy').format(DateTime.parse(licitacao.data)), // Formatação da data
        style: GoogleFonts.montserrat(),
                                    ),
                                  ],
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Observações: ',
                                      style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: licitacao.observacoes,
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
  final userId = int.parse(Provider.of<AuthProvider>(context, listen: false).currentUser!);
  final userName = Provider.of<AuthProvider>(context, listen: false).currentUserName!;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _modalidadeController = TextEditingController();
  final TextEditingController _numeroModalidadeController = TextEditingController(); // Novo controlador
  final TextEditingController _objetoController = TextEditingController();
  final TextEditingController _observacoesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  String? _modalidade = 'Pregão Eletrônico';
  String? _status = 'Aberto';

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

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
                  controller: _numeroModalidadeController,
                  decoration: InputDecoration(labelText: 'Número da Modalidade'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o número da modalidade';
                    }
                    return null;
                  },
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
                  controller: TextEditingController(text: userName),
                  decoration: InputDecoration(labelText: 'Responsável'),
                  enabled: false,
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
                Row(
                  children: <Widget>[
                    Text(
                      "Data: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}",
                    ),
                    IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                  ],
                ),
                TextFormField(
                  controller: _observacoesController,
                  decoration: InputDecoration(labelText: 'Observações'),
                  validator: (value) {
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
            child: Text('Adicionar'),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Licitacao novaLicitacao = Licitacao(
                  0, // ID inicializado como 0, será sobrescrito pelo banco de dados
                  _numeroController.text,
                  _modalidade!,
                  _numeroModalidadeController.text, // Novo campo
                  _objetoController.text,
                  userName, // Nome do usuário atual como responsável
                  _status!,
                  DateFormat('yyyy-MM-dd').format(_selectedDate), // Convertendo para yyyy-MM-dd
                  _observacoesController.text,
                  userId, // Passar como int
                );
                _addLicitacao(novaLicitacao);
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      );
    },
  );
}

void _showEditDialog(Licitacao licitacao) {
  TextEditingController numeroController = TextEditingController(text: licitacao.numero);
  TextEditingController modalidadeController = TextEditingController(text: licitacao.modalidade);
  TextEditingController numeroModalidadeController = TextEditingController(text: licitacao.numeroModalidade); // Novo controlador
  TextEditingController objetoController = TextEditingController(text: licitacao.objeto);
  TextEditingController responsavelController = TextEditingController(text: licitacao.responsavel);
  TextEditingController observacoesController = TextEditingController(text: licitacao.observacoes);
  DateTime data = DateFormat('yyyy-MM-dd').parse(licitacao.data);

  String _status = licitacao.status;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: data,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != data) {
      setState(() {
        data = picked;
      });
    }
  }

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
                controller: numeroController,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Modalidade'),
                controller: modalidadeController,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Número da Modalidade'),
                controller: numeroModalidadeController,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Objeto'),
                controller: objetoController,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Responsável'),
                controller: responsavelController,
              ),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: InputDecoration(labelText: 'Status'),
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
              ),
              Row(
                children: <Widget>[
                  Text(
                    "Data: ${DateFormat('dd-MM-yyyy').format(data)}",
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Observações'),
                controller: observacoesController,
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
                numeroController.text,
                modalidadeController.text,
                numeroModalidadeController.text,
                objetoController.text,
                responsavelController.text,
                _status,
                DateFormat('yyyy-MM-dd').format(data),
                observacoesController.text,
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
      _fetchLicitacoes(year: currentYear); // Atualize aqui para incluir o ano
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
        _fetchLicitacoes(year: currentYear);
      } else {
        throw Exception('Erro ao deletar licitação: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Erro ao deletar licitação: $error');
    }
  }
}
