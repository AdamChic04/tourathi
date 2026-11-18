import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import '../../core/theme/app_colors.dart';
import 'adventure_rewards_models.dart';
import 'adventure_rewards_repository.dart';
import 'reward_catalog.dart';

class AdventureRewardsScreen extends StatefulWidget {
  const AdventureRewardsScreen({super.key});

  @override
  State<AdventureRewardsScreen> createState() => _AdventureRewardsScreenState();
}

class _AdventureRewardsScreenState extends State<AdventureRewardsScreen> {
  final AdventureRewardsRepository _repository =
      LocalAdventureRewardsRepository.instance;
  AdventureRewardsSnapshot? _snapshot;
  Object? _loadError;
  bool _loading = true;
  final Set<String> _redeeming = {};

  bool get _ar => Localizations.localeOf(context).languageCode == 'ar';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final snapshot = await _repository.load();
      if (!mounted) return;
      setState(() {
        _snapshot = snapshot;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error;
        _loading = false;
      });
    }
  }

  Future<void> _redeem(RewardCatalogItem reward) async {
    final snapshot = _snapshot;
    if (snapshot == null || _redeeming.contains(reward.id)) return;
    if (snapshot.pointsBalance < reward.pointsCost) {
      _message(
        _ar
            ? 'نقاطك غير كافية لهذه المكافأة.'
            : 'You do not have enough points for this reward.',
      );
      return;
    }

    final confirmed =
        await showDialog<bool>(
          context: context,
          builder:
              (dialogContext) => AlertDialog(
                title: Text(_ar ? 'تأكيد الاستبدال' : 'Confirm redemption'),
                content: Text(
                  _ar
                      ? 'هل تريد استبدال ${reward.pointsCost} نقطة مقابل ${reward.titleAr}؟'
                      : 'Redeem ${reward.pointsCost} points for ${reward.title}?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: Text(_ar ? 'إلغاء' : 'Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: Text(_ar ? 'استبدال' : 'Redeem'),
                  ),
                ],
              ),
        ) ??
        false;
    if (!confirmed || !mounted || _redeeming.contains(reward.id)) return;

    setState(() => _redeeming.add(reward.id));
    try {
      final transactionId =
          'redeem-${reward.id}-${DateTime.now().microsecondsSinceEpoch}';
      final result = await _repository.redeem(
        transactionId: transactionId,
        reward: reward,
      );
      if (!mounted) return;
      if (result.status == RedemptionStatus.insufficientPoints) {
        _message(
          _ar
              ? 'تغيّر رصيدك وأصبحت نقاطك غير كافية.'
              : 'Your balance changed and is now too low for this reward.',
        );
      } else if (result.status == RedemptionStatus.redeemed) {
        await _load();
        _message(
          _ar
              ? 'تم تسجيل الاستبدال التجريبي. المرجع ${result.redemption!.referenceCode}'
              : 'Demo redemption recorded. Reference ${result.redemption!.referenceCode}',
        );
      } else {
        await _load();
        _message(
          _ar
              ? 'تم تسجيل هذه العملية مسبقاً.'
              : 'This redemption was already recorded.',
        );
      }
    } catch (_) {
      if (mounted) {
        _message(
          _ar
              ? 'تعذر إتمام الاستبدال. حاول مرة أخرى.'
              : 'Redemption failed. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _redeeming.remove(reward.id));
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final title = _ar ? 'مكافآت المغامرة' : 'Adventure Rewards';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _loadError != null
              ? _ErrorState(ar: _ar, onRetry: _load)
              : RefreshIndicator(onRefresh: _load, child: _content(_snapshot!)),
    );
  }

  Widget _content(AdventureRewardsSnapshot snapshot) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
    children: [
      _PointsCard(points: snapshot.pointsBalance, ar: _ar),
      const SizedBox(height: 16),
      _LoyaltyCard(snapshot: snapshot, ar: _ar),
      const SizedBox(height: 26),
      _SectionTitle(_ar ? 'المكافآت المتاحة' : 'Available rewards'),
      const SizedBox(height: 12),
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          _ar
              ? 'مكافآت تجريبية: يُسجل الاستبدال على هذا الجهاز، ولم يتم ربط تنفيذ المكافآت بالشركاء بعد.'
              : 'Sample rewards: redemptions are stored on this device; partner fulfillment is not connected yet.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
      ...RewardCatalog.items.map(
        (reward) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _RewardCard(
            reward: reward,
            ar: _ar,
            busy: _redeeming.contains(reward.id),
            onRedeem: () => _redeem(reward),
          ),
        ),
      ),
      const SizedBox(height: 22),
      _SectionTitle(_ar ? 'سجل النقاط' : 'Points activity'),
      const SizedBox(height: 10),
      if (snapshot.transactions.isEmpty)
        _EmptyState(
          icon: Icons.stars_outlined,
          text:
              _ar
                  ? 'ستظهر هنا النقاط المكتسبة والمستبدلة.'
                  : 'Points you earn and redeem will appear here.',
        )
      else
        ...snapshot.transactions.map(
          (transaction) => _TransactionTile(transaction: transaction, ar: _ar),
        ),
      const SizedBox(height: 22),
      _SectionTitle(_ar ? 'سجل الاستبدال' : 'Redemption history'),
      const SizedBox(height: 10),
      if (snapshot.redemptions.isEmpty)
        _EmptyState(
          icon: Icons.redeem_rounded,
          text:
              _ar
                  ? 'لم تستبدل أي مكافآت بعد.'
                  : 'You have not redeemed a reward yet.',
        )
      else
        ...snapshot.redemptions.map(
          (redemption) => _RedemptionTile(redemption: redemption, ar: _ar),
        ),
    ],
  );
}

class _PointsCard extends StatelessWidget {
  const _PointsCard({required this.points, required this.ar});
  final int points;
  final bool ar;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.desertGold, AppColors.warmBrown],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(22),
    ),
    child: Row(
      children: [
        const Icon(Icons.stars_rounded, color: Colors.white, size: 38),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ar ? 'رصيد النقاط' : 'Your points balance',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 2),
              Text(
                '$points',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        Text(
          ar ? 'نقطة' : 'PTS',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _LoyaltyCard extends StatelessWidget {
  const _LoyaltyCard({required this.snapshot, required this.ar});
  final AdventureRewardsSnapshot snapshot;
  final bool ar;

  @override
  Widget build(BuildContext context) {
    final memberCode = snapshot.memberId.substring(0, 8).toUpperCase();
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF382A21), Color(0xFF78553B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.explore_rounded, color: AppColors.sandBeige),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'TouRathi',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
                Text(
                  ar ? 'بطاقة المغامر' : 'ADVENTURER CARD',
                  style: const TextStyle(
                    color: AppColors.sandBeige,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ar ? 'مستكشف توراثي' : 'TouRathi Explorer',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${ar ? 'رقم العضوية' : 'Member ID'}  $memberCode',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        '${snapshot.pointsBalance} ${ar ? 'نقطة' : 'points'}',
                        style: const TextStyle(
                          color: AppColors.sandBeige,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Semantics(
                  label:
                      ar
                          ? 'رمز الاستجابة السريعة الفريد لعضويتك'
                          : 'Unique loyalty membership QR barcode',
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: SizedBox(
                      width: 112,
                      height: 112,
                      child: PrettyQrView.data(
                        data: 'tourathi:v1:member:${snapshot.memberId}',
                        decoration: const PrettyQrDecoration(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  const _RewardCard({
    required this.reward,
    required this.ar,
    required this.busy,
    required this.onRedeem,
  });
  final RewardCatalogItem reward;
  final bool ar;
  final bool busy;
  final VoidCallback onRedeem;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: colors.primary.withValues(alpha: .12),
              foregroundColor: colors.primary,
              child: Icon(_rewardIcon(reward.category)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ar ? reward.titleAr : reward.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    ar ? reward.descriptionAr : reward.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${reward.pointsCost} ${ar ? 'نقطة' : 'points'}',
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              tooltip: ar ? 'استبدل المكافأة' : 'Redeem reward',
              onPressed: busy ? null : onRedeem,
              icon:
                  busy
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.redeem_rounded),
            ),
          ],
        ),
      ),
    );
  }

  IconData _rewardIcon(String category) => switch (category) {
    'food' => Icons.coffee_rounded,
    'experience' => Icons.landscape_rounded,
    _ => Icons.handyman_rounded,
  };
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction, required this.ar});
  final PointsTransaction transaction;
  final bool ar;

  @override
  Widget build(BuildContext context) {
    final earned = transaction.pointsDelta > 0;
    final color = earned ? AppColors.emerald : AppColors.softRed;
    final subtitle =
        transaction.tripId != null
            ? (ar ? 'رحلة مكتملة ومضافة للمجلة' : 'Completed trip journaled')
            : (ar ? 'استبدال مكافأة' : 'Reward redemption');
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: .12),
        foregroundColor: color,
        child: Icon(earned ? Icons.add_rounded : Icons.remove_rounded),
      ),
      title: Text(
        transaction.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(subtitle),
      trailing: Text(
        '${earned ? '+' : ''}${transaction.pointsDelta}',
        style: TextStyle(color: color, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _RedemptionTile extends StatelessWidget {
  const _RedemptionTile({required this.redemption, required this.ar});
  final RewardRedemption redemption;
  final bool ar;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const CircleAvatar(child: Icon(Icons.redeem_rounded)),
    title: Text(redemption.rewardTitle),
    subtitle: Text(
      '${ar ? 'المرجع' : 'Reference'}: ${redemption.referenceCode}',
    ),
    trailing: Text('-${redemption.pointsCost}'),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Icon(icon, color: AppColors.warmBrown),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    ),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.ar, required this.onRetry});
  final bool ar;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 45),
          const SizedBox(height: 12),
          Text(
            ar
                ? 'تعذر تحميل بيانات المكافآت.'
                : 'Could not load your rewards data.',
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: onRetry,
            child: Text(ar ? 'إعادة المحاولة' : 'Retry'),
          ),
        ],
      ),
    ),
  );
}
