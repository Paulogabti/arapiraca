import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pdf/widgets.dart' as pw;
import 'dart:html' as html;
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart'; // Para formatação da data
import 'licitacao.dart'; // Importe a classe Licitacao

// Defina sua URL do backend
const String backendUrl = 'http://localhost:3000';

Future<List<Licitacao>> fetchAllLicitacoes() async {
  final response = await http.get(Uri.parse('$backendUrl/licitacoes'));

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    return data.map((item) => Licitacao.fromMap(item)).toList();
  } else {
    throw Exception('Erro ao buscar licitações');
  }
}

Future<void> generateGeneralReport(BuildContext context, List<Licitacao> licitacoes) async {
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
                      'Relatório Geral',
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            buildGeneralTable(licitacoes),
          ],
        );
      },
    ),
  );

  // Salvar PDF no Flutter Web e abrir em uma nova guia
final bytes = await pdf.save();
final blob = html.Blob([bytes], 'application/pdf');
final url = html.Url.createObjectUrlFromBlob(blob);

html.AnchorElement(href: url)
  ..setAttribute("download", "relatorio_geral.pdf")
  ..target = 'blank'
  ..click();

html.Url.revokeObjectUrl(url);

// Fechar a barra de progresso
Navigator.of(context).pop();
}

pw.Widget buildGeneralTable(List<Licitacao> licitacoes) {
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
