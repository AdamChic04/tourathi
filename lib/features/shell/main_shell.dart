import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/app_provider.dart';
import '../extra_features/feature_screens.dart';
import '../explore/explore_screen.dart';
import '../home/home_screen.dart';
import 'more_screen.dart';

/// A focused travel shell with discovery and activity tabs. Account stays in More.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  String _exploreCategory = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AppProvider>().refreshPlaces();
    });
  }

  void _selectTab(int tab) {
    setState(() {
      _index = tab;
      if (tab == 1) _exploreCategory = 'all';
    });
  }

  @override
  Widget build(BuildContext context) {
    final arabic = context.watch<AppProvider>().isArabic;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(
            onSelectTab: _selectTab,
            onExploreCategory:
                (category) => setState(() {
                  _exploreCategory = category;
                  _index = 1;
                }),
          ),
          ExploreScreen(
            key: ValueKey(_exploreCategory),
            initialCategory: _exploreCategory,
          ),
          const ActivitiesScreen(),
          const TicketsScreen(),
          const MoreScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _selectTab,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home_rounded),
            label: arabic ? 'الرئيسية' : 'Home',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.explore_outlined),
            activeIcon: const Icon(Icons.explore_rounded),
            label: arabic ? 'استكشف' : 'Explore',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.local_activity_outlined),
            activeIcon: const Icon(Icons.local_activity_rounded),
            label: arabic ? 'أنشطة' : 'Activities',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.confirmation_number_outlined),
            activeIcon: const Icon(Icons.confirmation_number_rounded),
            label: arabic ? 'تذاكري' : 'Tickets',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.grid_view_rounded),
            activeIcon: const Icon(Icons.grid_view_rounded),
            label: arabic ? 'المزيد' : 'More',
          ),
        ],
      ),
    );
  }
}
