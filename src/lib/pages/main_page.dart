import 'dart:convert';
import 'package:chips_input/chips_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ibuki/classes/extension/booru.dart';
import 'package:ibuki/classes/extension/booru_post.dart';
import 'package:ibuki/classes/extension/types.dart';
import 'package:ibuki/classes/helpers.dart';
import 'package:ibuki/classes/settings.dart';
import 'package:ibuki/classes/widgets/tag_widgets.dart';
import 'package:ibuki/pages/dashboard_page.dart';
import 'package:ibuki/pages/settings_page.dart';

class MainPage extends HookWidget {
    MainPage({super.key, required this.settings});
    final Settings settings;

    Widget _processIcon(String? icon) {
        if (icon == null || icon == "") return const Icon(Icons.broken_image);
        if (icon.startsWith("http")) return Image(image: NetworkImage(icon));
        return Image.memory(const Base64Decoder().convert(icon));
    }

    Future<List<Tag>?> _searchTag(String query) async {
        final booru = settings.activeBooru;
        final tags = await booru.getTagSuggestion(search: query, limit: 10);
        return tags;
    }

    List<Tag> searchQuery = [];

    @override
    Widget build(BuildContext context) {
        final selectedIndex = useState(0);
        // find index of active booru using id from settings and list of loaded boorus
        final activeBooru = useState(settings.boorus.indexWhere((element) => element.id == settings.activeBooruId));
        final title = useState(settings.boorus[activeBooru.value].name ?? "Ibuki");
        final searchActive = useState(false);
        final search = useState("");
        final debugString = useState("");

        final List<Widget> pages = <Widget>[
            DashboardPage(activeBooru: settings.boorus[activeBooru.value], search: search.value),
            DashboardPage(activeBooru: settings.boorus[activeBooru.value], search: "ordfav:lilystilson"),
            SettingsPage(settings: settings)
        ];

        // const knownBoorus 

        void searchFinished() {
            if (searchActive.value) {
                title.value = Tag.tagListToString(searchQuery);
                search.value = Tag.tagListToString(searchQuery);
            }
            searchActive.value = !searchActive.value;
        }

        final chipInput = ChipsInput<Tag>(
            chipBuilder: (context, state, tag) => TagChip(
                key: ObjectKey(tag),
                tag: tag
            ), 
            suggestionBuilder: (context, tag) => TagListTile(
                key: ObjectKey(tag),
                tag: tag,
            ),
            findSuggestions: (String query) async {
                if (query.isNotEmpty) {
                    final results = await _searchTag(query.toLowerCase()) ?? [];
                    return results;
                }
                return [];
            },
            initialValue: searchQuery,
            onChanged: (value) => searchQuery = value,
            onEditingComplete: searchFinished,
        );

        return Scaffold(
            appBar: AppBar(
                title: searchActive.value ? chipInput : Text(title.value),
                actions: [
                    IconButton(
                        onPressed: searchFinished,
                        icon: const Icon(Icons.search)
                    ),
                    Visibility(
                        visible: search.value.isNotEmpty || searchActive.value,
                        child: IconButton(
                            onPressed: () {
                                searchActive.value = false;
                                searchQuery = [];
                                search.value = "";
                                title.value = settings.boorus[activeBooru.value].name ?? "Ibuki";
                            }, 
                            icon: const Icon(Icons.close)
                        )
                    )
                ],
                backgroundColor: searchActive.value ? Theme.of(context).colorScheme.background : null,
            ),
            body: Center(
                child: pages.elementAt(selectedIndex.value),
            ),
            bottomNavigationBar: BottomNavigationBar(
                items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
                    BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Followed"),
                    BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
                ],
                showUnselectedLabels: false,
                currentIndex: selectedIndex.value,
                selectedItemColor: Theme.of(context).colorScheme.primary,
                onTap: (int index) {
                    selectedIndex.value = index;
                    if (index == 2) {
                        title.value = "Settings";
                    } else {
                        title.value = settings.boorus[activeBooru.value].name!;
                    }
                },
            ),
            drawer: Drawer(
                child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: settings.boorus.length + 1,
                    itemBuilder: (context, index) {
                        switch(index) {
                            case 0:
                                return DrawerHeader(
                                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
                                    child: Container(
                                        alignment: Alignment.bottomLeft,
                                        child: Row(children: const [
                                            Padding(padding: EdgeInsets.only(right: 16),child: Image(image: AssetImage("assets/images/logo_150px@2x.png"), width: 96)),
                                            Text("Ibuki", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold))
                                        ],)
                                    ),
                                );
                            default:
                                return ListTile(
                                    title: Text(settings.boorus[index - 1].name!),
                                    leading: (_processIcon(settings.boorus[index - 1].icon)),
                                    tileColor: activeBooru.value == index - 1 ? Theme.of(context).colorScheme.primary.withAlpha(150) : null,
                                    onTap: () {
                                        activeBooru.value = index - 1;
                                        settings.activeBooruId = settings.boorus[index - 1].id;
                                        title.value = settings.boorus[index - 1].name.toString();
                                    },
                                );
                        }
                    },
                )
            ),
            // floatingActionButton: FloatingActionButton(
            //     onPressed: () async {
            //         Booru danbooru = Booru(await loadAsset(context, "assets/scripts/Safebooru.js"));
            //         var post = await danbooru.getPosts(limit: 50);
            //         debugString.value = post[0].largeFileUrl.toString();
            //     },
            //     child: const Icon(Icons.check_circle),
            // ),
        );
    }
}