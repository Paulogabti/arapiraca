import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pdf/widgets.dart' as pw;
import 'dart:html' as html;
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'licitacao.dart';

// Defina sua URL do backend
const String backendUrl = 'http://localhost:3000';

class StatusHistorico {
  final String responsavel;
  final String modalidade;
  final String objeto;
  final String status;
  final String dataStatus;
  final String observacoes;

  StatusHistorico(this.responsavel, this.modalidade, this.objeto, this.status, this.dataStatus, this.observacoes);

  factory StatusHistorico.fromMap(Map<String, dynamic> map) {
    return StatusHistorico(
      map['responsavel'],
      map['modalidade'],
      map['objeto'],
      map['status'],
      map['data_status'],
      map['observacoes'] ?? '',
    );
  }
}

Future<List<StatusHistorico>> fetchStatusHistorico() async {
  final response = await http.get(Uri.parse('$backendUrl/historico_status'));

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    return data.map((item) => StatusHistorico.fromMap(item)).toList();
  } else {
    print('Erro ao buscar histórico de status: ${response.body}');
    throw Exception('Erro ao buscar histórico de status');
  }
}

Future<void> generateHudsonReport(BuildContext context) async {
  showDialog(
    context: context,
    barrierDismissible: false,
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

  try {
    final pdf = pw.Document();

    // Carregar a imagem do logo fora da função de construção da página
    final logo = pw.MemoryImage(
      (await rootBundle.load('assets/logo.png')).buffer.asUint8List(),
    );

    List<StatusHistorico> historicos = await fetchStatusHistorico();

    if (historicos.isEmpty) {
      print('Nenhum histórico de status encontrado.');
      Navigator.of(context).pop();
      return;
    }

    // Remover duplicados
    List<StatusHistorico> historicosUnicos = [];
    for (var historico in historicos) {
      if (!historicosUnicos.any((h) =>
          h.responsavel == historico.responsavel &&
          h.modalidade == historico.modalidade &&
          h.objeto == historico.objeto &&
          h.status == historico.status &&
          h.dataStatus == historico.dataStatus &&
          h.observacoes == historico.observacoes)) {
        historicosUnicos.add(historico);
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Image(logo, width: 100, height: 100),
                  pw.SizedBox(width: 20),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'CPC - Obras',
                        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        'Relatório SIAP/TCE',
                        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              buildHudsonTable(historicosUnicos),
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
      ..setAttribute("download", "relatorio_hudson.pdf")
      ..target = 'blank'
      ..click();

    html.Url.revokeObjectUrl(url);
  } catch (e) {
    print('Erro ao gerar relatório: $e');
  } finally {
    // Fechar a barra de progresso
    Navigator.of(context).pop();
  }
}

pw.Widget buildHudsonTable(List<StatusHistorico> historicos) {
  final dateFormat = DateFormat('dd-MM-yyyy'); // Defina o formato desejado

  return pw.TableHelper.fromTextArray(
    headers: [
      'Responsável',
      'Modalidade',
      'Objeto',
      'Status',
      'Data do Status',
      'Observações',
    ],
    data: historicos.map((historico) {
      return [
        historico.responsavel,
        historico.modalidade,
        historico.objeto,
        historico.status,
        dateFormat.format(DateTime.parse(historico.dataStatus)),
        historico.observacoes ?? '',
      ];
    }).toList(),
    cellStyle: pw.TextStyle(fontSize: 10),
    headerStyle: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
    headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
    cellAlignment: pw.Alignment.centerLeft, // Justificar o texto na tabela
    columnWidths: {
      0: pw.FlexColumnWidth(2.0),
      1: pw.FlexColumnWidth(2.0),
      2: pw.FlexColumnWidth(3.0),
      3: pw.FlexColumnWidth(2.0),
      4: pw.FlexColumnWidth(2.0),
      5: pw.FlexColumnWidth(3.0),
    }, // Ajuste as larguras das colunas conforme necessário
  );
}