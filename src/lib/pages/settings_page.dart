import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ibuki/classes/settings.dart';

class SettingsPage extends HookWidget {
    const SettingsPage({super.key, required this.settings});
    final Settings settings;

    @override
    Widget build(BuildContext context) {

        return const Center(child: Text("Settings page"));
    }
}