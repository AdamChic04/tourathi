import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/app_provider.dart';
import '../home/home_screen.dart';
import '../explore/explore_screen.dart';

/// Only the two implemented feature pages appear in the navigation.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final arabic = context.watch<AppProvider>().isArabic;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(onSelectTab: (tab) => setState(() => _index = tab)),
          const ExploreScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (tab) => setState(() => _index = tab),
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
        ],
      ),
    );
  }
}
