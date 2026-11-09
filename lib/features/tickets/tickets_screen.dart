import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/localization/app_strings.dart';
import '../../core/providers/app_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/models.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentPage = 0;
  final PageController _pageController = PageController(viewportFraction: 0.88);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  List<Ticket> _filteredTickets(TicketStatus status) {
    return MockData.tickets.where((t) => t.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<AppProvider>().isArabic;
    final statuses = [
      TicketStatus.upcoming,
      TicketStatus.completed,
      TicketStatus.cancelled,
    ];
    final currentStatus = statuses[_tabController.index];
    final tickets = _filteredTickets(currentStatus);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('myTickets', isArabic)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.desertGold,
          unselectedLabelColor: AppColors.warmBrown,
          indicatorColor: AppColors.desertGold,
          tabs: [
            Tab(text: AppStrings.get('upcoming', isArabic)),
            Tab(text: AppStrings.get('completed', isArabic)),
            Tab(text: AppStrings.get('cancelled', isArabic)),
          ],
        ),
      ),
      body: tickets.isEmpty
          ? _EmptyState(isArabic: isArabic, status: currentStatus)
          : Column(
              children: [
                const SizedBox(height: 8),
                Text(
                  isArabic
                      ? 'اسحب لعرض تذاكرك — ${_currentPage + 1}/${tickets.length}'
                      : 'Swipe your wallet — ${_currentPage + 1}/${tickets.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: tickets.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          double scale = 1.0;
                          if (_pageController.position.haveDimensions) {
                            final page = _pageController.page ?? index.toDouble();
                            scale = (1 - (page - index).abs() * 0.08)
                                .clamp(0.92, 1.0);
                          }
                          return Transform.scale(
                            scale: scale,
                            child: child,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 16,
                          ),
                          child: _LuxuryTicketCard(
                            ticket: tickets[index],
                            isArabic: isArabic,
                          )
                              .animate()
                              .fadeIn(delay: (index * 80).ms)
                              .slideX(begin: 0.1, end: 0),
                        ),
                      );
                    },
                  ),
                ),
                if (tickets.length > 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      tickets.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? AppColors.desertGold
                              : AppColors.sandBeige,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}

class _LuxuryTicketCard extends StatelessWidget {
  const _LuxuryTicketCard({
    required this.ticket,
    required this.isArabic,
  });

  final Ticket ticket;
  final bool isArabic;

  Color get _statusColor {
    switch (ticket.status) {
      case TicketStatus.upcoming:
        return AppColors.emerald;
      case TicketStatus.completed:
        return AppColors.royalBlue;
      case TicketStatus.cancelled:
        return AppColors.softRed;
    }
  }

  String _statusLabel(bool isArabic) {
    switch (ticket.status) {
      case TicketStatus.upcoming:
        return AppStrings.get('upcoming', isArabic);
      case TicketStatus.completed:
        return AppStrings.get('completed', isArabic);
      case TicketStatus.cancelled:
        return AppStrings.get('cancelled', isArabic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripName = isArabic ? ticket.tripNameAr : ticket.tripName;

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.goldShimmer,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.desertGold.withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -40,
              child: Icon(
                Icons.confirmation_number,
                size: 180,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.explore, color: Colors.white, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        'TouRathi',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _statusLabel(isArabic),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    tripName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.calendar_today,
                    text: ticket.date,
                  ),
                  const SizedBox(height: 4),
                  _InfoRow(
                    icon: Icons.groups,
                    text: ticket.groupName,
                  ),
                  const SizedBox(height: 4),
                  _InfoRow(
                    icon: Icons.confirmation_number_outlined,
                    text: ticket.bookingNumber,
                  ),
                  if (ticket.seat != null) ...[
                    const SizedBox(height: 4),
                    _InfoRow(
                      icon: Icons.event_seat,
                      text: '${isArabic ? 'المقعد' : 'Seat'}: ${ticket.seat}',
                    ),
                  ],
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      child: QrImageView(
                        data: ticket.qrData,
                        version: QrVersions.auto,
                        size: 140,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: AppColors.darkCharcoal,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      isArabic
                          ? 'امسح عند نقطة التجمع'
                          : 'Scan at meeting point',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 6,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isArabic, required this.status});

  final bool isArabic;
  final TicketStatus status;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.confirmation_number_outlined,
            size: 64,
            color: AppColors.warmBrown.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            isArabic ? 'لا توجد تذاكر' : 'No tickets found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
