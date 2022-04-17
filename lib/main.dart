// ignore_for_file: unused_import, unused_element, prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_spinkit/flutter_spinkit.dart';

const request = 'https://api.hgbrasil.com/finance?key=7a4e5b0c';
main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

Future<Map> getData() async {
  final response = await http.get(Uri.parse(request));
  final json = jsonDecode(response.body);
  return json as Map;
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home> {
  late double dolar;
  late double euro;
  final realController = TextEditingController();
  final euroController = TextEditingController();
  final dolarController = TextEditingController();
  late double euroDouble;
  late double realDouble;
  late double dolarDouble;

  void _clearAll() {
    realController.clear();
    dolarController.clear();
    euroController.clear();
  }

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    euroController.text = (double.parse(text) / euro).toStringAsFixed(2);
    dolarController.text = (double.parse(text) / dolar).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    realController.text = (double.parse(text) * dolar).toStringAsFixed(2);
    euroController.text =
        (double.parse(realController.text) / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    realController.text = (double.parse(text) * euro).toStringAsFixed(2);
    dolarController.text =
        (double.parse(realController.text) / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.amberAccent,
        title: Text("Conversor",
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
              fontSize: 24,
              shadows: [
                Shadow(
                  color: Color.fromARGB(155, 97, 97, 97),
                  offset: Offset(2, 3),
                  blurRadius: 10,
                ),
              ],
            )),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[700],
      body: FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitCircle(
                    color: Colors.amberAccent,
                    size: 50.0,
                  ),
                  Text(
                    "Carregando dados...",
                    style: TextStyle(color: Colors.amberAccent, fontSize: 24),
                  )
                ],
              ));
            default:
              if (snapshot.hasError) {
                return const Center(
                  child: Text("Erro ao carregar dados"),
                );
              } else {
                Map infos = snapshot.data as Map;
                dolar = infos['results']['currencies']['USD']['buy'];
                euro = infos['results']['currencies']['EUR']['buy'];
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14.0, horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.currency_exchange,
                          size: 80,
                          color: Colors.amberAccent,
                        ),
                        CustomTextField(
                          onChanged: _realChanged,
                          controller: realController,
                          prefixText: 'R\$ ',
                          currency: 'Real',
                        ),
                        CustomTextField(
                          onChanged: _dolarChanged,
                          controller: dolarController,
                          prefixText: 'US\$ ',
                          currency: 'Dolar',
                        ),
                        CustomTextField(
                          onChanged: _euroChanged,
                          controller: euroController,
                          prefixText: '€ ',
                          currency: 'Euro',
                        ),
                      ],
                    ),
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

class CustomTextField extends StatefulWidget {
  String prefixText;
  String currency;
  TextEditingController controller;
  void Function(String) onChanged;

  CustomTextField({
    Key? key,
    required this.prefixText,
    required this.currency,
    required this.controller,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextField(
        onChanged: widget.onChanged,
        controller: widget.controller,
        keyboardType: TextInputType.number,
        style: TextStyle(
          color: Colors.amberAccent,
          fontSize: 23,
        ),
        cursorColor: Colors.amberAccent,
        cursorWidth: 1,
        decoration: InputDecoration(
          prefixText: widget.prefixText,
          prefixStyle: TextStyle(color: Colors.amberAccent),
          labelText: widget.currency,
          labelStyle: TextStyle(color: Colors.amberAccent, fontSize: 20),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey[400]!,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.amberAccent,
            ),
          ),
        ),
      ),
    );
  }
}
