import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_strings.dart';
import '../../core/providers/app_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock/mock_data.dart';
import '../../widgets/common/glass_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final isArabic = app.isArabic;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.desertGradient,
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 44,
                          backgroundImage:
                              NetworkImage(MockData.userAvatar),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        MockData.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isArabic ? 'مستكشف الأردن' : 'Jordan Explorer',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                AppStrings.get('settings', isArabic),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.dark_mode_rounded,
                      title: AppStrings.get('darkMode', isArabic),
                      trailing: Switch.adaptive(
                        value: isDark,
                        activeColor: AppColors.desertGold,
                        onChanged: (_) => app.toggleTheme(),
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 56,
                      color: AppColors.sandBeige.withValues(alpha: 0.3),
                    ),
                    _SettingsTile(
                      icon: Icons.language_rounded,
                      title: AppStrings.get('language', isArabic),
                      subtitle: isArabic ? 'العربية' : 'English',
                      trailing: TextButton(
                        onPressed: app.toggleLanguage,
                        child: Text(
                          isArabic ? 'EN' : 'ع',
                          style: const TextStyle(
                            color: AppColors.desertGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Text(
                isArabic ? 'استكشف المزيد' : 'Explore More',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _MenuLink(
                  icon: Icons.emoji_events_rounded,
                  title: AppStrings.get('rewards', isArabic),
                  route: '/rewards',
                  color: AppColors.desertGold,
                ),
                _MenuLink(
                  icon: Icons.auto_stories_rounded,
                  title: AppStrings.get('socialJournal', isArabic),
                  route: '/social-journal',
                  color: AppColors.royalBlue,
                ),
                _MenuLink(
                  icon: Icons.view_in_ar_rounded,
                  title: AppStrings.get('arHub', isArabic),
                  route: '/ar-hub',
                  color: AppColors.emerald,
                ),
                _MenuLink(
                  icon: Icons.storefront_rounded,
                  title: AppStrings.get('marketplace', isArabic),
                  route: '/marketplace',
                  color: AppColors.warmBrown,
                ),
                _MenuLink(
                  icon: Icons.menu_book_rounded,
                  title: AppStrings.get('passport', isArabic),
                  route: '/jordan-passport',
                  color: AppColors.desertGold,
                ),
                _MenuLink(
                  icon: Icons.shield_rounded,
                  title: AppStrings.get('emergency', isArabic),
                  route: '/emergency',
                  color: AppColors.softRed,
                ),
                _MenuLink(
                  icon: Icons.history_edu_rounded,
                  title: AppStrings.get('aiImageGen', isArabic),
                  route: '/ai-image-generator',
                  color: AppColors.royalBlue,
                ),
                _MenuLink(
                  icon: Icons.groups_rounded,
                  title: isArabic ? 'مخطط المجموعات' : 'AI Group Planner',
                  route: '/ai-group-planner',
                  color: AppColors.emerald,
                ),
                _MenuLink(
                  icon: Icons.hiking_rounded,
                  title: AppStrings.get('travelGroups', isArabic),
                  route: '/travel-groups',
                  color: AppColors.warmBrown,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.desertGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.desertGold, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _MenuLink extends StatelessWidget {
  const _MenuLink({
    required this.icon,
    required this.title,
    required this.route,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String route;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: InkWell(
          onTap: () => context.push(route),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.warmBrown.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
