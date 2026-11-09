import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_strings.dart';
import '../../core/providers/app_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/models.dart';
import '../../widgets/common/app_network_image.dart';
import '../../widgets/common/glass_card.dart';

class SocialJournalScreen extends StatefulWidget {
  const SocialJournalScreen({super.key});

  @override
  State<SocialJournalScreen> createState() => _SocialJournalScreenState();
}

class _SocialJournalScreenState extends State<SocialJournalScreen> {
  final Map<String, bool> _likedPosts = {};
  final Map<String, int> _likeCounts = {};

  int _likesFor(JournalPost post) =>
      _likeCounts[post.id] ?? post.likes;

  bool _isLiked(JournalPost post) => _likedPosts[post.id] ?? false;

  void _toggleLike(JournalPost post) {
    setState(() {
      final liked = _isLiked(post);
      _likedPosts[post.id] = !liked;
      _likeCounts[post.id] = _likesFor(post) + (liked ? -1 : 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<AppProvider>().isArabic;
    final posts = MockData.journalPosts;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(AppStrings.get('socialJournal', isArabic)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.desertGradient,
                ),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Icon(
                      Icons.auto_stories_rounded,
                      size: 80,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundImage:
                          NetworkImage(MockData.userAvatar),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            MockData.userName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            isArabic
                                ? 'شارك مغامرتك في الأردن'
                                : 'Share your Jordan adventure',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.edit_note_rounded, color: AppColors.desertGold),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final post = posts[index];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 450),
                    child: SlideAnimation(
                      verticalOffset: 30,
                      child: FadeInAnimation(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: _JournalPostCard(
                            post: post,
                            isArabic: isArabic,
                            liked: _isLiked(post),
                            likeCount: _likesFor(post),
                            onLike: () => _toggleLike(post),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: posts.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JournalPostCard extends StatelessWidget {
  const _JournalPostCard({
    required this.post,
    required this.isArabic,
    required this.liked,
    required this.likeCount,
    required this.onLike,
  });

  final JournalPost post;
  final bool isArabic;
  final bool liked;
  final int likeCount;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.warmBrown.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(post.userAvatar),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 14,
                            color: AppColors.desertGold,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              post.location,
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            ' · ${post.timeAgo}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz_rounded),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          AppNetworkImage(
            imageUrl: post.imageUrl,
            height: 280,
            width: double.infinity,
            borderRadius: 0,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _InteractionButton(
                      icon: liked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: liked ? AppColors.softRed : null,
                      onTap: onLike,
                    ),
                    const SizedBox(width: 16),
                    _InteractionButton(
                      icon: Icons.chat_bubble_outline_rounded,
                      onTap: () {},
                    ),
                    const SizedBox(width: 16),
                    _InteractionButton(
                      icon: Icons.send_rounded,
                      onTap: () {},
                    ),
                    const Spacer(),
                    if (post.isAiGenerated)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.aiGlow,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_awesome,
                                size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              'AI',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '$likeCount ${isArabic ? 'إعجاب' : 'likes'}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: '${post.userName.split(' ').first} ',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: post.caption),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isArabic
                      ? 'عرض ${post.comments} تعليق'
                      : 'View all ${post.comments} comments',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.warmBrown,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

class _InteractionButton extends StatelessWidget {
  const _InteractionButton({
    required this.icon,
    this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          icon,
          size: 26,
          color: color ?? Theme.of(context).iconTheme.color,
        ),
      ),
    );
  }
}
