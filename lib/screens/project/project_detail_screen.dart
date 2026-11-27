import 'package:flutter/material.dart';
import '../review_project/project_review_screen.dart';

// Kompatibel dengan pemanggilan lama tanpa parameter dari HomeScreen.
// Jika ID nyata tersedia, kirim projectId agar langsung membuka rincian.
class ProjectDetailScreen extends StatelessWidget {
  final int? projectId;
  const ProjectDetailScreen({super.key, this.projectId});

  @override
  Widget build(BuildContext context) => ProjectReviewScreen(projectId: projectId);
}
