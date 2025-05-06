import 'package:chat_app/src/pages/pages.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final goRouter = GoRouter(
    initialLocation: '/',
    errorBuilder: (_, __) => const Scaffold(
          body: Center(
            child: Text('Error'),
          ),
        ),
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => LeyesSearchPage(),
      ),
      GoRoute(
        path: '/ia-chat',
        builder: (context, state) => const ChatPage(),
      )
    ]);
