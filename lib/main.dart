import 'package:flutter/material.dart';
import 'views/redacteur_interface.dart';

void main() {
  runApp(const MonApplication());
}

class MonApplication extends StatelessWidget {
  const MonApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magazine Infos - Gestion des rédacteurs',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          leading: const Icon(Icons.menu, color: Colors.white),
          title: const Text('Gestion des rédacteurs', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.pink,
          actions: const [
            Icon(Icons.search, color: Colors.white),
            SizedBox(width: 16),
          ],
        ),
        body: RedacteurInterface(),
      ),
    );
  }
}