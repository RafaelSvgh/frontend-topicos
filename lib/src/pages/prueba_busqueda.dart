import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class LeyesSearchPage extends StatefulWidget {
  @override
  _LeyesSearchPageState createState() => _LeyesSearchPageState();
}

class _LeyesSearchPageState extends State<LeyesSearchPage> {
  List<String> _particiones = [];
  List<String> _resultados = [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadLeyes();
  }

  Future<void> _loadLeyes() async {
    final data = await rootBundle.loadString('assets/leyes.json');
    final json = jsonDecode(data);
    setState(() {
      _particiones = List<String>.from(json['particiones']);
      _resultados = _particiones;
    });
  }

  void _buscar(String query) {
    setState(() {
      _query = query;
      _resultados = _particiones
          .where((ley) => ley.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Buscar Leyes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar...',
                border: OutlineInputBorder(),
              ),
              onChanged: _buscar,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _resultados.length,
              itemBuilder: (context, i) => ListTile(
                title: Text(_resultados[i],
                    maxLines: 3, overflow: TextOverflow.ellipsis),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
