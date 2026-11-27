import 'package:flutter/material.dart';
import '../contribution/contribution_widgets.dart';

const reviewTeal = Color(0xFF159A91);

String display(dynamic value) => value == null || value.toString().trim().isEmpty ? 'Belum tersedia' : value.toString();
double? number(dynamic value) => value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '');
String decimal(double n, {int digits = 1}) => n.toStringAsFixed(digits).replaceAll('.', ',');
String percent(double? n) => n == null ? '—' : '${decimal(n)}%';
double? ratio(double? numerator, double? denominator) => numerator == null || denominator == null || denominator == 0 ? null : numerator / denominator * 100;
String rupiah(dynamic value) {
  final n = number(value);
  if (n == null) return 'Belum tersedia';
  if (n.abs() >= 1000000000000) return 'Rp${decimal(n / 1000000000000, digits: 2)} triliun';
  if (n.abs() >= 1000000000) return 'Rp${decimal(n / 1000000000, digits: 2)} miliar';
  if (n.abs() >= 1000000) return 'Rp${decimal(n / 1000000, digits: 2)} juta';
  return 'Rp${n.round()}';
}
String dateLabel(dynamic value) {
  final d = DateTime.tryParse(value?.toString() ?? '');
  if (d == null) return 'Belum tersedia';
  const months = ['Januari','Februari','Maret','April','Mei','Juni','Juli','Agustus','September','Oktober','November','Desember'];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

class ReviewCard extends StatelessWidget {
  final List<Widget> children;
  final Color color;
  const ReviewCard({super.key, required this.children, this.color = Colors.white});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: color, border: Border.all(color: border), borderRadius: BorderRadius.circular(15)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
  );
}

Widget reviewTitle(String text) => Padding(padding: const EdgeInsets.only(bottom: 14), child: Text(text, style: const TextStyle(color: navy, fontSize: 20, fontWeight: FontWeight.w500)));
Widget reviewLabel(String text) => Text(text, style: const TextStyle(color: grey, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.1));
Widget reviewBody(String text) => Text(text, style: const TextStyle(color: grey, fontSize: 13, height: 1.6));
Widget detailRow(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  const SizedBox(height: 12), Text(label, style: const TextStyle(color: grey, fontSize: 12)), const SizedBox(height: 6),
  Text(value, style: const TextStyle(color: navy, fontSize: 14, fontWeight: FontWeight.w700)), const SizedBox(height: 12), const Divider(color: border, height: 1),
]);
Widget progressBar(double? value, Color color) => ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: ((value ?? 0) / 100).clamp(0.0, 1.0).toDouble(), minHeight: 8, color: color, backgroundColor: const Color(0xFFE6EBF0)));
Widget statusBadge(String status) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFE1F3EE), borderRadius: BorderRadius.circular(18)), child: Text('●  $status', style: const TextStyle(color: Color(0xFF167B6E), fontSize: 11, fontWeight: FontWeight.w600)));
Widget simulationBadge() => Align(alignment: Alignment.centerLeft, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(color: const Color(0xFFFFF9EA), border: Border.all(color: const Color(0xFFE9D8A8)), borderRadius: BorderRadius.circular(6)), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.info_outline, size: 15, color: Color(0xFF79571C)), SizedBox(width: 7), Flexible(child: Text('DATA SIMULASI — BUKAN DATA RESMI', style: TextStyle(color: Color(0xFF79571C), fontSize: 10, fontWeight: FontWeight.w700)))])));

void showReviewInfo(BuildContext context, String title, String message) {
  showDialog<void>(context: context, builder: (context) => AlertDialog(title: Text(title), content: SingleChildScrollView(child: SelectableText(message)), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup'))]));
}
