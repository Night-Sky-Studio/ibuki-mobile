import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ibuki/classes/settings.dart';
import 'package:ibuki/pages/settings/settings_pages.dart';
import 'package:ibuki/pages/settings/settings_page_route.dart';

class SettingsPage extends HookWidget {
    const SettingsPage({super.key, required this.settings});
    final Settings settings;

    @override
    Widget build(BuildContext context) {
        final List<Map<String, dynamic>> pages = [
            {
                "title": "General",
                "subtitle": "Language, behavior",
                "icon": Icon(Icons.tune, color: Theme.of(context).colorScheme.primary), 
                "page": SettingsPages.general(settings: settings)
            },
            {
                "title": "Appearance", 
                "subtitle": "App theme, tags",
                "icon": Icon(Icons.palette, color: Theme.of(context).colorScheme.primary), 
                "page": SettingsPages.appearance(settings: settings)
            }
        ];

        return Scaffold(
            appBar: AppBar(
                title: const Text("Settings"),
            ),
            body: ListView.builder(
                itemCount: pages.length,
                itemBuilder: (context, index) => ListTile(
                    title: Text(pages[index]["title"]),
                    leading: pages[index]["icon"],
                    subtitle: Text(pages[index]["subtitle"]),
                    onTap: () => Navigator.push(context, createIbukiSettingsPageRoute(page: pages[index]["page"]))
                )
            )
        );
    }
}