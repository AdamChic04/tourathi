import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/providers/app_provider.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arabic = context.watch<AppProvider>().isArabic;
    final entries = <({String en, String ar, String detailEn, String detailAr, IconData icon, String route})>[
      (en: 'Food in Jordan', ar: 'الطعام في الأردن', detailEn: 'Local dishes and food experiences', detailAr: 'أطباق وتجارب طعام محلية', icon: Icons.restaurant_menu_rounded, route: '/food'),
      (en: 'Adventure rewards', ar: 'مكافآت المغامرة', detailEn: 'Collect rewards as you explore', detailAr: 'اجمع المكافآت أثناء الاستكشاف', icon: Icons.stars_rounded, route: '/rewards'),
      (en: 'My itineraries', ar: 'خططي المحفوظة', detailEn: 'Continue planning your trip', detailAr: 'تابع تخطيط رحلتك', icon: Icons.route_rounded, route: '/my-plans'),
      (en: 'Explore in AR', ar: 'استكشف بالواقع المعزز', detailEn: 'Open the augmented reality experience', detailAr: 'افتح تجربة الواقع المعزز', icon: Icons.view_in_ar_rounded, route: '/ar-hub'),
      (en: 'Travel journal', ar: 'مذكرات السفر', detailEn: 'Keep your memories and stories', detailAr: 'احتفظ بذكرياتك وقصصك', icon: Icons.auto_stories_rounded, route: '/social-journal'),
      (en: 'Profile and settings', ar: 'الملف الشخصي والإعدادات', detailEn: 'Manage your Tourathi account', detailAr: 'إدارة حساب تراثي', icon: Icons.person_outline_rounded, route: '/profile'),
    ];
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? const Color(0xFFF8F2E9) : const Color(0xFF22221F);
    final muted = dark ? const Color(0xFFAEA89F) : const Color(0xFF89867F);
    final accent = dark ? const Color(0xFFD9A67D) : const Color(0xFF9B6548);

    return Scaffold(
      appBar: AppBar(
        title: Text(arabic ? 'المزيد' : 'More'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Text(
            arabic ? 'كل أدوات رحلتك في مكان واحد' : 'Everything for your journey, in one place',
            style: TextStyle(color: muted, fontSize: 14),
          ),
          const SizedBox(height: 14),
          for (final entry in entries) ...[
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                leading: CircleAvatar(
                  backgroundColor: accent.withValues(alpha: .12),
                  child: Icon(entry.icon, color: accent),
                ),
                title: Text(
                  arabic ? entry.ar : entry.en,
                  style: TextStyle(color: ink, fontWeight: FontWeight.w700),
                ),
                subtitle: Text(arabic ? entry.detailAr : entry.detailEn),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push(entry.route),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
