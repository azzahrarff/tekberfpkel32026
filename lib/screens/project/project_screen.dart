import 'package:flutter/material.dart';
import '../review_project/project_review_screen.dart';

// Gunakan file ini hanya bila ProjectScreen masih berupa placeholder.
// BottomNavbar tetap milik project awal: tab Proyek memuat daftar + review.
class ProjectScreen extends StatelessWidget {
  const ProjectScreen({super.key});

  @override
  Widget build(BuildContext context) => const ProjectReviewScreen();
}
