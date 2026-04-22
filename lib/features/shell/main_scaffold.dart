import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack keeps all branch Navigators mounted (Offstage). FABs and
      // other implicit Heroes would share one PageRoute → duplicate-tag asserts
      // and jank unless Hero is disabled for this subtree (runtime evidence:
      // "multiple heroes ... default FloatingActionButton tag").
      body: HeroMode(
        enabled: false,
        child: navigationShell,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Eventos',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Produtos',
          ),
          NavigationDestination(
            icon: Icon(Icons.ios_share_outlined),
            selectedIcon: Icon(Icons.ios_share),
            label: 'Exportar',
          ),
        ],
      ),
    );
  }
}
