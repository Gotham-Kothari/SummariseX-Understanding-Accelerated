// lib/app.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'state/chat_controller.dart';
import 'screens/chat_screen.dart';

class SummariseXApp extends StatelessWidget {
  const SummariseXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatController(),
      child: MaterialApp(
        title: 'SummariseX',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: const ChatScreen(),
      ),
    );
  }
}
