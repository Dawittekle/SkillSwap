import 'package:flutter/material.dart';
import 'package:skill_swap/data/repositories/chat_repository.dart';
import 'package:skill_swap/data/services/auth_service.dart';
import 'package:skill_swap/src/app.dart';
import 'package:skill_swap/src/core/theme/app_colors.dart';
import 'package:skill_swap/src/features/tabs/discover_tab.dart';
import 'package:skill_swap/src/features/tabs/home_tab.dart';
import 'package:skill_swap/src/features/tabs/messages_tab.dart';
import 'package:skill_swap/src/features/tabs/profile_tab.dart';
import 'package:skill_swap/src/features/tabs/swaps_tab.dart';

class BottomNavigationShell extends StatefulWidget {
  const BottomNavigationShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<BottomNavigationShell> createState() => _BottomNavigationShellState();
}

class _BottomNavigationShellState extends State<BottomNavigationShell> {
  late int _selectedIndex = widget.initialIndex;
  String _discoverQuery = '';

  void _selectTab(int index) {
    setState(() => _selectedIndex = index);
  }

  void _openDiscoverWithQuery(String query) {
    setState(() {
      _discoverQuery = query;
      _selectedIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService().currentUser;
    final tabs = [
      HomeTab(
        onSelectTab: _selectTab,
        onDiscoverSearch: _openDiscoverWithQuery,
      ),
      DiscoverTab(initialQuery: _discoverQuery),
      SwapsTab(onSelectTab: _selectTab),
      const MessagesTab(),
      const ProfileTab(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: tabs),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.addSkill),
        tooltip: 'Add skill',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.cardWhite,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: StreamBuilder<int>(
            stream: currentUser == null
                ? Stream.value(0)
                : ChatRepository().watchUnreadConversationCount(
                    currentUser.uid,
                  ),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;

              return BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _selectTab,
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: _SelectedNavIcon(icon: Icons.home_rounded),
                    label: 'Home',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.explore_outlined),
                    activeIcon: _SelectedNavIcon(icon: Icons.explore),
                    label: 'Discover',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.swap_horiz_outlined),
                    activeIcon: _SelectedNavIcon(icon: Icons.swap_horiz),
                    label: 'Swaps',
                  ),
                  BottomNavigationBarItem(
                    icon: _NavIconWithBadge(
                      icon: Icons.chat_bubble_outline,
                      count: unreadCount,
                    ),
                    activeIcon: _NavIconWithBadge(
                      icon: Icons.chat_bubble,
                      count: unreadCount,
                      selected: true,
                    ),
                    label: 'Messages',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: _SelectedNavIcon(icon: Icons.person),
                    label: 'Profile',
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavIconWithBadge extends StatelessWidget {
  const _NavIconWithBadge({
    required this.icon,
    required this.count,
    this.selected = false,
  });

  final IconData icon;
  final int count;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final iconWidget = selected ? _SelectedNavIcon(icon: icon) : Icon(icon);

    if (count <= 0) return iconWidget;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        iconWidget,
        Positioned(
          right: selected ? 4 : -8,
          top: selected ? -4 : -8,
          child: Container(
            width: count > 9 ? 24 : 18,
            height: 18,
            padding: const EdgeInsets.symmetric(horizontal: 5),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.danger,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              count > 9 ? '9+' : count.toString(),
              style: const TextStyle(
                color: AppColors.cardWhite,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectedNavIcon extends StatelessWidget {
  const _SelectedNavIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.accentGold,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Icon(icon, color: AppColors.primaryDark),
    );
  }
}
