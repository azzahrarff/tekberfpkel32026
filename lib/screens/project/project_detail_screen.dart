import 'package:flutter/material.dart';
import '../review_project/project_review_screen.dart';

class ProjectDetailScreen extends StatelessWidget {
  final int projectId;

  const ProjectDetailScreen({
    super.key,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    return ProjectReviewScreen(
      projectId: projectId,
    );
  }
}