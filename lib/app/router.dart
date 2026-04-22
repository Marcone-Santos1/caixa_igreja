import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/events/change_dots_screen.dart';
import '../features/events/dot_management_screen.dart';
import '../features/events/event_hub_screen.dart';
import '../features/events/event_sales_register_screen.dart';
import '../features/events/events_list_screen.dart';
import '../features/events/new_sale_screen.dart';
import '../features/export/export_screen.dart';
import '../features/products/products_list_screen.dart';
import '../features/shell/main_scaffold.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/events',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/events',
                builder: (context, state) => const EventsListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/products',
                builder: (context, state) => const ProductsListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/export',
                builder: (context, state) => const ExportScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/event/:eventId',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['eventId']!);
          return EventHubScreen(eventId: id);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/event/:eventId/fichas',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['eventId']!);
          return DotManagementScreen(eventId: id);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/event/:eventId/vendas',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['eventId']!);
          return EventSalesRegisterScreen(eventId: id);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/event/:eventId/sale',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['eventId']!);
          return NewSaleScreen(eventId: id);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/event/:eventId/sale/:saleId/troco',
        builder: (context, state) {
          final eid = int.parse(state.pathParameters['eventId']!);
          final sid = int.parse(state.pathParameters['saleId']!);
          final change = int.tryParse(
                state.uri.queryParameters['change'] ?? '',
              ) ??
              0;
          return ChangeDotsScreen(
            eventId: eid,
            saleId: sid,
            changeCents: change,
          );
        },
      ),
    ],
  );
});
