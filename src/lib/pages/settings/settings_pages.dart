import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ibuki/classes/settings.dart';

class SettingsPages extends HookWidget {
    const SettingsPages({super.key, required this.settings});
    final Settings settings;

    static Widget general({required Settings settings}) {
        return Scaffold(
            appBar: AppBar(title: const Text('General')),
            body: const Text('General Settings')
        );
    }

    static Widget appearance({required Settings settings}) {
        return Scaffold(
            appBar: AppBar(title: const Text('Appearance')),
            body: const Text('Appearance Settings')
        );
    }

    @override
    Widget build(BuildContext context) {
        return const Center(child: Text('This page should not be here...'));
    }
}