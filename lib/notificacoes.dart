import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importar Clipboard e ClipboardData
import 'dart:html' as html; // Importar para abrir URLs

class HudsonIcon extends StatefulWidget {
  @override
  _HudsonIconState createState() => _HudsonIconState();
}

class _HudsonIconState extends State<HudsonIcon> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Tooltip(
        message: 'Opções adicionais',
        child: Transform.scale(
          scale: _isHovering ? 1.2 : 1.0,
          child: GestureDetector(
            onTap: () {
              _showHudsonOptions(context);
            },
            child: CircleAvatar(
            radius: 20,
            child: Icon(
              Icons.list_alt, // Ícone a ser exibido
            ),
            ),
          ),
        ),
      ),
    );
  }

  void _showHudsonOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Opções Adicionais'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.numbers), // Ícone para Numerador
                title: Text('Número Ofício'),
                onTap: () {
                  // Abrir nova guia no navegador
                  Navigator.of(context).pop();
                  _launchURL('https://docs.google.com/spreadsheets/d/1yuo3VcCbxkdTAzeZz8exRTZgjUsh1ibbsoNJT95Skbo/edit?usp=drive_link');
                },
              ),
              ListTile(
                leading: Icon(Icons.publish), // Ícone para Publicar
                title: Text('Publicar'),
                onTap: () {
                  _showPublishOptions(context);
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

  void _showPublishOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Publicar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Publicar na AMA'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showCredentialsDialog(
                    context,
                    'Publicar na AMA',
                    'https://autenticacao.diariomunicipal.com.br/',
                    'Login: usuario\nSenha: 123',
                  );
                },
              ),
              ListTile(
                title: Text('Publicar no DOE'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showCopyDialog(
                    context,
                    'Publicar no DOE',
                    "Para publicar no DOE atualmente, basta copiar o e-mail abaixo e abrir o e-mail do nosso setor e escrever para o seguinte e-mail: materias.imprensaoficialal@gmail.com.\n\nSegue abaixo um modelo de exemplo.\n\n'Boa tarde, Imprensa, Por gentileza, publicar o documento abaixo em anexo para circular dia 28/06 - Sexta-feira.\n\nDesde já agradecemos.'\n\nFeito isso, anexa o documento word ao e-mail e envia.",
                  );
                },
              ),
              ListTile(
                title: Text('Publicar no DOU'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showCopyDialog(
                    context,
                    'Publicar no DOU',
                    "Para publicar no DOU atualmente, basta copiar o e-mail abaixo e abrir o e-mail do nosso setor e escrever para o seguinte e-mail: eloahpublicidade@gmail.com.\n\nSegue abaixo um modelo de exemplo.\n\n'Boa tarde, Imprensa, Por gentileza, publicar o documento abaixo em anexo para circular dia 28/06 - Sexta-feira, no Diário Oficial da União.\n\nDesde já agradecemos.'\n\nFeito isso, anexa o documento word ao e-mail e envia.",
                  );
                },
              ),
              ListTile(
                title: Text('Publicar no Jornal'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showCopyDialog(
                    context,
                    'Publicar no Jornal',
                    "Para publicar no jornal atualmente, basta copiar o e-mail abaixo e abrir o e-mail do nosso setor e escrever para o seguinte e-mail: eloahpublicidade@gmail.com.\n\nSegue abaixo um modelo de exemplo.\n\n'Boa tarde, Imprensa, Por gentileza, publicar o documento abaixo em anexo para circular dia 28/06 - Sexta-feira, no Jornal de grande circulação de Alagoas.\n\nDesde já agradecemos.'\n\nFeito isso, anexa o documento word ao e-mail e envia.",
                  );
                },
              ),
              ListTile(
                title: Text('Publicar no Site de Arapiraca'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showCredentialsDialog(
                    context,
                    'Publicar no Site de Arapiraca',
                    'https://transparencia.arapiraca.al.gov.br/login',
                    'Login: usuario\nSenha: 123',
                  );
                },
              ),
              ListTile(
                title: Text('Publicar no PNCP'),
                onTap: () {
                  Navigator.of(context).pop();
                  _launchURL('https://www.gov.br/compras/pt-br');
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

  void _showCredentialsDialog(BuildContext context, String title, String url, String credentials) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SelectableText(credentials),
          actions: [
            TextButton(
              child: Text('Copiar Credenciais'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: credentials));
              },
            ),
            TextButton(
              child: Text('Publicar'),
              onPressed: () {
                Navigator.of(context).pop();
                _launchURL(url);
              },
            ),
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

  void _showCopyDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SelectableText(content),
          actions: [
            TextButton(
              child: Text('Copiar Texto'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: content));
              },
            ),
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

  void _launchURL(String url) {
    html.window.open(url, '_blank');
  }
}
