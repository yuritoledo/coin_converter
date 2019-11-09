import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const url = 'https://api.hgbrasil.com/finance?format=json-cors&key=afadb197';

Future<Map> getData() async {
  http.Response response = await http.get(url);
  Map resp = json.decode(response.body);
  return resp;
}

void main() {
  runApp(Home());
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double dollar;
  double euro;

  final realController = TextEditingController();
  final dollarController = TextEditingController();
  final euroController = TextEditingController();

  void _clearAll() {
    realController.clear();
    dollarController.clear();
    euroController.clear();
  }

  void _onChangedReal(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    final double real = double.parse(text);
    dollarController.text = (real / dollar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _onChangedDolar(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    final double _dollar = double.parse(text);
    realController.text = (_dollar * dollar).toStringAsFixed(2);
    euroController.text = (_dollar * dollar / euro).toStringAsFixed(2);
  }

  void _onChangedEuro(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    final double euro = double.parse(text);
    realController.text = (euro * euro).toStringAsFixed(2);
    dollarController.text = (euro * euro / dollar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.amber, hintColor: Colors.amber),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber,
          title: buildTitle(),
        ),
        body: FutureBuilder(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return CircularProgressIndicator(
                  semanticsLabel: 'alou',
                );

              default:
                if (snapshot.hasError) {
                  return buildCenterText('Aconteceu algum erro :(');
                } else {
                  dollar = snapshot.data['results']['currencies']['USD']['buy'];
                  euro = snapshot.data['results']['currencies']['EUR']['buy'];

                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 50.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(Icons.attach_money,
                            size: 150.0, color: Colors.amber),
                        buildTextField(
                            label: 'Reais',
                            prefix: 'R\$',
                            ctrl: realController,
                            onChanged: _onChangedReal),
                        Divider(),
                        buildTextField(
                            label: 'Dólar',
                            prefix: 'USD',
                            ctrl: dollarController,
                            onChanged: _onChangedDolar),
                        Divider(),
                        buildTextField(
                            label: 'Euro',
                            prefix: 'EUR',
                            ctrl: euroController,
                            onChanged: _onChangedEuro),
                      ],
                    ),
                  );
                }
            }
          },
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  Row buildTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Coin converter',
          style: TextStyle(color: Colors.black),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.0),
          child: Icon(
            Icons.monetization_on,
            color: Colors.black,
          ),
        )
      ],
    );
  }

  Center buildCenterText(String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(color: Colors.amber),
      ),
    );
  }

  TextField buildTextField(
      {String label,
      String prefix,
      TextEditingController ctrl,
      Function onChanged}) {
    return TextField(
      controller: ctrl,
      onChanged: onChanged,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.amber),
          prefix: Padding(
            padding: EdgeInsets.only(right: 10.0),
            child: Text(prefix),
          ),
          border: OutlineInputBorder()),
      style: TextStyle(
        color: Colors.amber,
      ),
    );
  }
}
