import 'package:flutter/material.dart';

class UXJsonGenerator extends StatefulWidget {
  const UXJsonGenerator({super.key});

  @override
  State<UXJsonGenerator> createState() => _UXJsonGeneratorState();
}

class _UXJsonGeneratorState extends State<UXJsonGenerator> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UX JSON Generator'),
      ),
      body: const Center(
        child: Text('UX JSON Generator - Under construction'),
      ),
    );
  }
}