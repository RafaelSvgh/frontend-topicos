import 'package:chat_app/base_dato_hepler.dart';
import 'package:flutter/material.dart';

class LeyesSearchPage extends StatefulWidget {
  LeyesSearchPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LeyesSearchPageState createState() => _LeyesSearchPageState();
}

class _LeyesSearchPageState extends State<LeyesSearchPage> {
  BaseDatoHepler baseDatoHepler = BaseDatoHepler();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Buscar Leyes')),
      body: Column(
        children: [
          TextButton(
              onPressed: () async {
                await baseDatoHepler.insertUsuario('Juan Perez');
              },
              child: Text('Insertar')),
        ],
      ),
    );
  }
}
