import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_strings.dart';
import '../../core/providers/app_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/models.dart';
import '../../widgets/common/app_network_image.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/common/section_header.dart';

class CommunityDetailsScreen extends StatefulWidget {
  const CommunityDetailsScreen({super.key, required this.communityId});

  final String communityId;

  @override
  State<CommunityDetailsScreen> createState() =>
      _CommunityDetailsScreenState();
}

class _CommunityDetailsScreenState extends State<CommunityDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Community get _community => MockData.communities.firstWhere(
        (c) => c.id == widget.communityId,
        orElse: () => MockData.communities.first,
      );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<AppProvider>().isArabic;
    final community = _community;
    final name = isArabic ? community.nameAr : community.name;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  AppNetworkImage(
                    imageUrl: community.coverImage,
                    width: double.infinity,
                    height: double.infinity,
                    borderRadius: 0,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 60,
                    left: 20,
                    right: 20,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.desertGold,
                              width: 3,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 36,
                            backgroundColor: Colors.white,
                            child: ClipOval(
                              child: AppNetworkImage(
                                imageUrl: community.logoUrl,
                                width: 72,
                                height: 72,
                                borderRadius: 36,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (community.isVerified) ...[
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.verified,
                                      color: AppColors.emerald,
                                      size: 22,
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                AppStrings.get(community.category, isArabic),
                                style: TextStyle(
                                  color: AppColors.desertGold,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: AppColors.desertGold,
              unselectedLabelColor: AppColors.warmBrown,
              indicatorColor: AppColors.desertGold,
              tabs: [
                Tab(text: isArabic ? 'الرحلات' : 'Trips'),
                Tab(text: isArabic ? 'الأعضاء' : 'Members'),
                Tab(text: AppStrings.get('reviews', isArabic)),
                Tab(text: isArabic ? 'الدردشة' : 'Chat'),
              ],
            ),
          ),
        ],
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _TripsTab(community: community, isArabic: isArabic),
                  _MembersTab(community: community, isArabic: isArabic),
                  _ReviewsTab(isArabic: isArabic),
                  _ChatPreviewTab(isArabic: isArabic),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: GradientButton(
            label: AppStrings.get('joinCommunity', isArabic),
            icon: Icons.chat_bubble_outline,
            onPressed: () => context.push('/group-chat/${community.id}'),
            width: double.infinity,
          ),
        ),
      ),
    );
  }

}

class _OverviewContent extends StatelessWidget {
  const _OverviewContent({
    required this.community,
    required this.description,
    required this.isArabic,
  });

  final Community community;
  final String description;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _StatChip(
                icon: Icons.people,
                label: '${community.memberCount}',
                subtitle: isArabic ? 'عضو' : 'Members',
              ),
              const SizedBox(width: 12),
              _StatChip(
                icon: Icons.star,
                label: community.rating.toString(),
                subtitle: AppStrings.get('reviews', isArabic),
              ),
            ],
          ),
          if (community.achievements != null &&
              community.achievements!.isNotEmpty) ...[
            const SizedBox(height: 24),
            SectionHeader(
              title: isArabic ? 'الإنجازات' : 'Achievements',
            ),
            const SizedBox(height: 12),
            ...community.achievements!.map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        color: AppColors.desertGold,
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(a)),
                    ],
                  ),
                ),
              ),
            ),
          ],
          if (community.upcomingTrips != null &&
              community.upcomingTrips!.isNotEmpty) ...[
            const SizedBox(height: 24),
            SectionHeader(
              title: isArabic ? 'الرحلات القادمة' : 'Upcoming Trips',
            ),
            const SizedBox(height: 12),
            ...community.upcomingTrips!.map(
              (trip) => _TripCard(trip: trip, isArabic: isArabic),
            ),
          ],
          if (community.pastAdventures != null &&
              community.pastAdventures!.isNotEmpty) ...[
            const SizedBox(height: 24),
            SectionHeader(
              title: isArabic ? 'مغامرات سابقة' : 'Past Adventures',
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: community.pastAdventures!.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) => AppNetworkImage(
                  imageUrl: community.pastAdventures![i],
                  width: 100,
                  height: 100,
                  borderRadius: AppTheme.radiusSmall,
                ),
              ),
            ),
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.subtitle,
  });

  final IconData icon;
  final String label;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: AppColors.desertGold),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip, required this.isArabic});

  final Activity trip;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          AppNetworkImage(
            imageUrl: trip.imageUrl,
            width: 80,
            height: 80,
            borderRadius: AppTheme.radiusSmall,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? trip.titleAr : trip.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(trip.date, style: Theme.of(context).textTheme.bodySmall),
                Text(
                  trip.price,
                  style: TextStyle(
                    color: AppColors.desertGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TripsTab extends StatelessWidget {
  const _TripsTab({required this.community, required this.isArabic});

  final Community community;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return _OverviewContent(
      community: community,
      description: isArabic ? community.descriptionAr : community.description,
      isArabic: isArabic,
    );
  }
}

class _MembersTab extends StatelessWidget {
  const _MembersTab({required this.community, required this.isArabic});

  final Community community;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final members = [
      (MockData.userName, MockData.userAvatar, isArabic ? 'منظم' : 'Organizer'),
      ('Layla Al-Hassan',
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
          isArabic ? 'عضو' : 'Member'),
      ('Omar Al-Rashid',
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
          isArabic ? 'عضو' : 'Member'),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: members.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final (name, avatar, role) = members[i];
        return GlassCard(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(avatar),
                radius: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: Theme.of(context).textTheme.titleMedium),
                    Text(role, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.warmBrown),
            ],
          ),
        );
      },
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  const _ReviewsTab({required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final reviews = [
      (
        'Sara Al-Masri',
        5.0,
        isArabic
            ? 'مجتمع رائع! الرحلات منظمة بشكل ممتاز.'
            : 'Amazing community! Trips are incredibly well organized.'
      ),
      (
        'Ahmad K.',
        4.8,
        isArabic
            ? 'تجربة لا تُنسى مع مرشدين محترفين.'
            : 'Unforgettable experience with professional guides.'
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: reviews.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final (author, rating, text) = reviews[i];
        return GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(author,
                      style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: AppColors.desertGold, size: 16),
                      Text(' $rating'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(text, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        );
      },
    );
  }
}

class _ChatPreviewTab extends StatelessWidget {
  const _ChatPreviewTab({required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline,
                size: 64, color: AppColors.desertGold.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              isArabic
                  ? 'انضم للمجتمع للوصول إلى الدردشة'
                  : 'Join the community to access group chat',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
