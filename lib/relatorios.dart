import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pdf/widgets.dart' as pw;
import 'dart:html' as html;
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'licitacao.dart';
import 'relatorios_geral.dart';
import 'package:intl/intl.dart';
import 'relatorio_hudson.dart';

// Defina sua URL do backend
const String backendUrl = 'http://localhost:3000';

class RelatoriosIcon extends StatefulWidget {
  @override
  _RelatoriosIconState createState() => _RelatoriosIconState();
}

class _RelatoriosIconState extends State<RelatoriosIcon> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Tooltip(
        message: 'Relatórios',
        child: Transform.scale(
          scale: _isHovering ? 1.2 : 1.0,
          child: GestureDetector(
            onTap: () {
              _showRelatoriosOptions(context);
            },
            child: CircleAvatar(
              child: Icon(Icons.print),
              radius: 20,
            ),
          ),
        ),
      ),
    );
  }

  void _showRelatoriosOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Opções de Relatório'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.person), // Ícone para Relatório Individual
                title: Text('Relatório Individual'),
                onTap: () async {
                  try {
                    showDialog(
                      context: context,
                      barrierDismissible: false, // Impedir que o usuário feche o diálogo tocando fora dele
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 20),
                              Text('Gerando relatório...'),
                            ],
                          ),
                        );
                      },
                    );

                    // Obter o ID e o nome do usuário logado
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    int userId = int.parse(authProvider.currentUser!);
                    String responsavel = authProvider.currentUserName!; // Obter o nome do usuário

                    List<Licitacao> licitacoes = await _fetchLicitacoes(userId);
                    await _generateIndividualReport(context, responsavel, licitacoes);

                    // Fechar a barra de progresso
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  } catch (e) {
                    // Handle error
                    print(e);
                    Navigator.of(context).pop(); // Fechar a barra de progresso em caso de erro também
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.group), // Ícone para Relatório Geral
                title: Text('Relatório Geral'),
                onTap: () async {
                  try {
                    showDialog(
                      context: context,
                      barrierDismissible: false, // Impedir que o usuário feche o diálogo tocando fora dele
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 20),
                              Text('Gerando relatório...'),
                            ],
                          ),
                        );
                      },
                    );

                    List<Licitacao> licitacoes = await fetchAllLicitacoes();
                    await generateGeneralReport(context, licitacoes);

                    // Fechar a barra de progresso
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  } catch (e) {
                    // Handle error
                    print(e);
                    Navigator.of(context).pop(); // Fechar a barra de progresso em caso de erro também
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.assignment), // Ícone para Relatório Hudson
                title: Text('Relatório para SIAP/TCE'),
                onTap: () async {
                  try {
                    showDialog(
                      context: context,
                      barrierDismissible: false, // Impedir que o usuário feche o diálogo tocando fora dele
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 20),
                              Text('Gerando relatório...'),
                            ],
                          ),
                        );
                      },
                    );


                    await generateHudsonReport(context);

                    // Fechar a barra de progresso
                    Navigator.of(context).pop();
                  } catch (e) {
                    // Handle error
                    print(e);
                    Navigator.of(context).pop(); // Fechar a barra de progresso em caso de erro também
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _generateIndividualReport(BuildContext context, String responsavel, List<Licitacao> licitacoes) async {
    final pdf = pw.Document();

    // Carregar a imagem do logo fora da função de construção da página
    final logo = pw.MemoryImage(
      (await rootBundle.load('assets/logo.png')).buffer.asUint8List(),
    );

    // Cabeçalho com logo e título
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape, // Mudar para paisagem
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center, // Centralizar
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Image(logo, width: 100, height: 100),
                  pw.SizedBox(width: 20), // Espaçamento entre logo e título
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center, // Centralizar
                    children: [
                      pw.Text(
                        'CPC - Obras',
                        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        'Relatório Individual',
                        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              _buildTable(licitacoes),
            ],
          );
        },
      ),
    );

    // Função para salvar e abrir o PDF no Flutter Web
    final bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    html.AnchorElement(href: url)
      ..setAttribute("download", "relatorio_individual.pdf")
      ..target = 'blank'
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  pw.Widget _buildTable(List<Licitacao> licitacoes) {
    final dateFormat = DateFormat('dd-MM-yyyy'); // Defina o formato desejado

    return pw.Table.fromTextArray(
      headers: [
        'Nº Processo',
        'Modalidade',
        'Objeto',
        'Responsável',
        'Status',
        'Data do Status',
        'Observações',
      ],
      data: licitacoes.map((licitacao) {
        return [
          licitacao.numero,
          licitacao.modalidade,
          licitacao.objeto,
          licitacao.responsavel,
          licitacao.status,
          dateFormat.format(DateTime.parse(licitacao.data)), // Formate a data aqui
          licitacao.observacoes ?? '',
        ];
      }).toList(),
      cellStyle: pw.TextStyle(fontSize: 10),
      headerStyle: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
      headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
      columnWidths: {
        0: pw.FlexColumnWidth(1.0),
        1: pw.FlexColumnWidth(2.0),
        2: pw.FlexColumnWidth(3.0),
        3: pw.FlexColumnWidth(2.0),
        4: pw.FlexColumnWidth(2.0),
        5: pw.FlexColumnWidth(2.0),
        6: pw.FlexColumnWidth(3.0),
      }, // Ajuste as larguras das colunas conforme necessário
      cellAlignment: pw.Alignment.centerLeft, // Justificar o texto na tabela
    );
  }

  Future<List<Licitacao>> _fetchLicitacoes(int userId) async {
    final response = await http.get(Uri.parse('$backendUrl/licitacoes?user_id=$userId'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => Licitacao.fromMap(item)).toList();
    } else {
      throw Exception('Erro ao buscar licitações');
    }
  }
}



