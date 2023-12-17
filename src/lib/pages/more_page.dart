import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ibuki/classes/settings.dart';
// import 'package:ibuki/pages/more/accounts_page.dart';
import 'package:ibuki/pages/more/extensions_page.dart';
import 'package:ibuki/pages/more/settings_page.dart';
import 'package:ibuki/pages/settings/settings_page_route.dart';

class MorePage extends HookWidget {
    const MorePage({super.key, required this.settings});
    final Settings settings;

    @override
    Widget build(BuildContext context) {


        return ListView(
            children: [
                const Row(children: [
                    Padding(padding: EdgeInsets.only(right: 16), child: Image(image: AssetImage("assets/images/logo_150px@2x.png"), width: 160)),
                    Text("Ibuki", style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold))
                ]),
                ListTile(
                    title: const Text("Extensions"),
                    leading: Icon(Icons.extension, color: Theme.of(context).colorScheme.primary),
                    onTap: () => Navigator.push(context, createIbukiSettingsPageRoute(page: ExtensionsPage(settings: settings)))
                ),
                // ListTile(
                //     title: const Text("Accounts"),
                //     leading: Icon(Icons.account_circle, color: Theme.of(context).colorScheme.primary),
                //     onTap: () => Navigator.push(context, createIbukiSettingsPageRoute(page: AccountsPage(settings: settings)))
                // ),
                ListTile(
                    title: const Text("Settings"),
                    leading: Icon(Icons.settings, color: Theme.of(context).colorScheme.primary),
                    onTap: () => Navigator.push(context, createIbukiSettingsPageRoute(page: SettingsPage(settings: settings)))
                )
            ],
        );
    }
}