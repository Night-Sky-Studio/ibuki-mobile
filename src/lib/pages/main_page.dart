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
import 'package:ibuki/classes/widgets/search_appbar.dart';
import 'package:ibuki/classes/widgets/tag_widgets.dart';
import 'package:ibuki/pages/dashboard_page.dart';
import 'package:ibuki/pages/settings_page.dart';

class MainPage extends HookWidget {
    const MainPage({super.key, required this.settings, this.searchRequest});
    final Tag? searchRequest;
    final Settings settings;

    Widget _processIcon(String? icon) {
        if (icon == null || icon == "") return const Icon(Icons.broken_image);
        if (icon.startsWith("http")) return Image(image: NetworkImage(icon));
        return Image.memory(const Base64Decoder().convert(icon));
    }

    @override
    Widget build(BuildContext context) {
        final selectedIndex = useState(0);
        // find index of active booru using id from settings and list of loaded boorus
        final activeBooru = useState(settings.boorus.indexWhere((element) => element.id == settings.activeBooruId));

        final title = useState(settings.activeBooru.name ?? "Ibuki");
        final search = useState("");
        final searchOverride = useState<Tag?>(null);

        final requestFulfilled = useState(false);

        final debugString = useState("");

        if (searchRequest != null && !requestFulfilled.value) {
            search.value = searchRequest!.tagName;
            title.value = searchRequest!.tagName;
            searchOverride.value = searchRequest!;
            requestFulfilled.value = true;
        }
 
        final List<Widget> pages = <Widget>[
            DashboardPage(settings: settings, search: search.value, 
                // onSearchChanged: (tags) {
                //     searchOverride.value = tags;
                //     search.value = Tag.tagListToString(tags);
                //     title.value = Tag.tagListToString(tags);
                // }
            ),
            // TODO: Following page
            // TODO: Add ability to follow certain tags
            // TODO: OR every followed tag's result images

            //? Question tho, should it be bound to a single booru,
            //? or should it be able to track what tags were followed and
            //? then just combine everything?
            DashboardPage(settings: settings, search: "rating:g"),
            SettingsPage(settings: settings)
        ];

        // const knownBoorus 

        return Scaffold(
            appBar: SearchAppBar(
                leading: //Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: [
                    //if (searchRequest != null) 
                       searchRequest != null ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()) : null,
                    // IconButton(
                    //     icon: const Icon(Icons.menu),
                    //     onPressed: () => Scaffold.of(context).openDrawer(),
                    // )
                //],),
                title: title.value, 
                initialValue: searchOverride.value,
                settings: settings, 
                onSearch: (context, tags) {
                    search.value = Tag.tagListToString(tags);
                    title.value = Tag.tagListToString(tags);
                },
                onSearchClear: (context) {
                    search.value = "";
                    title.value = settings.activeBooru.name ?? "Ibuki";
                    searchOverride.value = null;
                }
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
                        title.value = settings.activeBooru.name ?? "Ibuki";
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