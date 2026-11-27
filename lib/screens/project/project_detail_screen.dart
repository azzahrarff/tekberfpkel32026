import 'package:flutter/material.dart';

class ProjectDetailScreen extends StatelessWidget {
  final int projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Proyek')),
      body: Center(child: Text('Proyek #$projectId')),
    );
  }
}