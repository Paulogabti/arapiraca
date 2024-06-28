import 'package:flutter/material.dart';

class HudsonIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showHudsonOptions(context);
      },
      child: CircleAvatar(
        child: Icon(Icons.notifications),
        radius: 20,
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
                leading: Image.asset('assets/hudson.png', width: 30, height: 30),
                title: Text('Avisar ao Hudson'),
                onTap: () {
                  // Função a ser implementada
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Image.asset('assets/melania.png', width: 30, height: 30),
                title: Text('Imprimir para Melania'),
                onTap: () {
                  _showPrintOptions(context);
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

  void _showPrintOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Imprimir para Melania'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Individual'),
                onTap: () {
                  // Função a ser implementada para imprimir individualmente
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Imprimir de Todos'),
                onTap: () {
                  // Função a ser implementada para imprimir de todos
                  Navigator.of(context).pop();
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
}
