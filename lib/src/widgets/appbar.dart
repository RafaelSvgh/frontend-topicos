import 'package:flutter/material.dart';

AppBar appBar(ThemeData theme, String title) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
      ),
      backgroundColor: theme.colorScheme.surface,
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(
          color: Colors.grey.withAlpha(100),
          height: 1,
        ),
      ),
      elevation: 1,
      actions: [
        IconButton(
          icon: const Icon(
            Icons.chat_bubble_outline,
            size: 24,
          ),
          onPressed: () {},
        ),
      ],
    );
  }