import 'package:flutter/material.dart';

import '../../core/services/supabase_service.dart';
import '../profile/notification_screen.dart';
import '../profile/profile_screen.dart';

const navy = Color(0xFF142C4E);
const blue = Color(0xFF245B9E);
const background = Color(0xFFF6F8FB);
const grey = Color(0xFF687586);
const border = Color(0xFFDFE6EE);

class ContributionHeader extends StatelessWidget {
  const ContributionHeader({super.key});
  @override
  Widget build(BuildContext context) {
    final user = SupabaseService.currentUser;
    final name = (user?.userMetadata?['full_name'] ?? user?.email ?? 'Pengguna')
        .toString()
        .trim();
    final words = name.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).take(2);
    final initials = words.map((s) => s[0].toUpperCase()).join();
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: border)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: navy,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final item in [
                  (10.0, Colors.white),
                  (17.0, const Color(0xFF63C8C1)),
                  (13.0, Colors.white),
                ])
                  Container(
                    width: 4.7,
                    height: item.$1,
                    decoration: BoxDecoration(
                      color: item.$2,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  children: [
                    TextSpan(
                      text: 'Anggaran',
                      style: TextStyle(color: navy),
                    ),
                    TextSpan(
                      text: 'Terbuka',
                      style: TextStyle(color: blue),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Notifikasi',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationScreen()),
            ),
            icon: const Icon(Icons.notifications_none, color: navy),
          ),
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            child: CircleAvatar(
              radius: 17,
              backgroundColor: const Color(0xFFD9E8F5),
              child: Text(
                initials.isEmpty ? 'P' : initials,
                style: const TextStyle(
                  color: blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ContributionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool secondary;
  final bool arrow;
  const ContributionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.secondary = false,
    this.arrow = true,
  });
  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        if (arrow) ...[
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, size: 18),
        ],
      ],
    );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    );
    final padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 15);
    return secondary
        ? OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: navy,
              side: const BorderSide(color: border),
              padding: padding,
              shape: shape,
            ),
            child: child,
          )
        : FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: blue,
              foregroundColor: Colors.white,
              padding: padding,
              shape: shape,
            ),
            child: child,
          );
  }
}

class ContributionFormShell extends StatelessWidget {
  final int step;
  final String title;
  final VoidCallback? onBack;
  final Widget child;
  const ContributionFormShell({
    super.key,
    required this.step,
    required this.title,
    required this.onBack,
    required this.child,
  });
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 660),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.chevron_left, color: blue),
              label: const Text(
                'Kembali',
                style: TextStyle(color: blue, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'KIRIM DOKUMENTASI',
              style: TextStyle(
                color: grey,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Dokumentasikan kondisi proyek',
              style: TextStyle(
                color: navy,
                fontSize: 26,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Informasi pribadi dan koordinat sensitif tidak dipublikasikan otomatis.',
              style: TextStyle(color: grey, fontSize: 14),
            ),
            const SizedBox(height: 28),
            _Steps(step: step),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: border),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: navy,
                      fontSize: 21,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  child,
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Steps extends StatelessWidget {
  final int step;
  const _Steps({required this.step});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (int i = 1; i <= 3; i++) ...[
        if (i > 1) const SizedBox(width: 7),
        if (i > 1) const SizedBox(width: 12, child: Divider(color: border)),
        if (i > 1) const SizedBox(width: 7),
        Expanded(
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i <= step ? blue : Colors.white,
                  border: Border.all(color: i <= step ? blue : border),
                ),
                child: i < step
                    ? const Icon(Icons.check, size: 15, color: Colors.white)
                    : Text(
                        '$i',
                        style: TextStyle(
                          color: i <= step ? Colors.white : grey,
                          fontSize: 12,
                        ),
                      ),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  ['Proyek & lokasi', 'Deskripsi & bukti', 'Tinjau'][i - 1],
                  style: TextStyle(
                    color: i <= step ? blue : grey,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ],
  );
}

InputDecoration contributionInput(String hint, {Widget? suffix}) =>
    InputDecoration(
      hintText: hint,
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: blue),
      ),
    );

Widget fieldLabel(String label) => Padding(
  padding: const EdgeInsets.only(bottom: 8),
  child: Text(
    label,
    style: const TextStyle(
      color: grey,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    ),
  ),
);

Widget formActions(List<Widget> buttons) => Column(
  children: [
    const SizedBox(height: 20),
    const Divider(color: border),
    const SizedBox(height: 12),
    Align(
      alignment: Alignment.centerRight,
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: 10,
        runSpacing: 8,
        children: buttons,
      ),
    ),
  ],
);

void contributionMessage(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
