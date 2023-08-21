import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:ibuki/classes/extension/booru.dart';
import 'package:ibuki/classes/extension/extension.dart';
import 'package:ibuki/classes/helpers.dart';
import 'package:ibuki/classes/settings.dart';
import 'package:ibuki/classes/widgets/material_icon_button.dart';
import 'package:badges/badges.dart' as badges;

class ExtensionsPage extends HookWidget {
    const ExtensionsPage({super.key, required this.settings});
    final Settings settings;

    @override
    Widget build(BuildContext context) {
        final vsync = useSingleTickerProvider();
        final tabController = useTabController(initialLength: 2, vsync: vsync);
        final streamController = useStreamController();
        // final panelOpen = useState<List<bool>>(List.filled(settings.boorus.length, false));
        // final extensions = useState<List<Extension>>([]);
        final extensions = useState<List<Extension>>([]);
        final progresses = useState<List<double?>>([]);
        final isMounted = useIsMounted();
        final updatesCount = useState<int>(0);

        Future<void> fetchExtensions() async {
            if (isMounted()) {
                // updatesCount.value = 0;
                final items = await settings.getExtensionsFromRepo();
            
                progresses.value = List<double?>.filled(items.length, null);
                
                // extensions.value = items.where((element) => !settings.boorus.any((booru) => booru.name == element.name && element.version! > booru.version!)).toList();

                // what the hell am i doing with my life...
                extensions.value = items.where((item) => !settings.boorus.any((booru) => booru.name == item.name && booru.version == item.version)).toList();
                updatesCount.value = items.where((element) => settings.boorus.any((booru) => element.name == booru.name && element.version! > booru.version!)).length;

                streamController.sink.add(extensions.value);
            }
        }

        fetchExtensions();

        return Scaffold(
            appBar: AppBar(
                title: const Text("Extensions"), 
                bottom: TabBar(controller: tabController, indicatorColor: Theme.of(context).textTheme.bodyMedium!.color!, tabs: [
                    const Tab(child: Text("Installed")),
                    Tab(child: badges.Badge(
                        showBadge: updatesCount.value != 0,
                        badgeContent: Text(updatesCount.value.toString()),
                        position: badges.BadgePosition.topEnd(end: -20),
                        badgeStyle: badges.BadgeStyle(
                            badgeColor: Theme.of(context).colorScheme.background,
                        ),
                        child: const Text("Available"),
                    )),
                ]),
                actions: [
                    MaterialIconButton(icon: const Icon(Icons.add), onPressed: () async {
                        FilePickerResult? result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['js'],
                        );

                        if (result != null) {
                            File file = File(result.files.single.path!);
                            // if file is not in settings directory - copy it there
                            if (!file.path.startsWith(await settings.settingsDirectory)) {
                                file = await file.copy("${await settings.settingsDirectory}/${file.path.split(Platform.pathSeparator).last}");
                            }
                            await settings.installBooru(file.path);
                        }
                    }),
                    MaterialIconButton(icon: const Icon(Icons.refresh), onPressed: () async {
                        extensions.value.clear();
                        await fetchExtensions();
                    })
                ],
            ),
            body: TabBarView(controller: tabController, children: [
                /// Installed
                ListView.builder(
                    itemCount: settings.boorus.length,
                    itemBuilder: (context, index) => Card(margin: const EdgeInsets.only(top: 8, left: 8, right: 8), child: Padding(
                        padding: const EdgeInsets.all(8), 
                        child: ListTile(
                            contentPadding: const EdgeInsets.all(0),
                            leading: processIcon(settings.boorus[index].icon, size: 48),
                            title: Text("${settings.boorus[index].name}"),
                            subtitle: Text("Version: ${settings.boorus[index].version}"),
                            trailing: MaterialIconButton(icon: const Icon(Icons.delete), onPressed: () async {
                                await settings.removeBooru(index);
                            })
                        )
                    ))
                ),
                /// Available
                StreamBuilder(
                    stream: streamController.stream,
                    builder: (context, snapshot) {
                        return RefreshIndicator(
                            onRefresh: () => fetchExtensions(), 
                            child: snapshot.hasData 
                                ? GroupedListView<Extension, String>(
                                    elements: extensions.value, 
                                    groupBy: (element) => settings.boorus.any((booru) => element.name == booru.name && element.version! > booru.version!) ? "Has updates" : "Available",
                                    // groupHeaderBuilder: (element) => const Text("Separator"),
                                    groupSeparatorBuilder: (value) => Padding(padding: const EdgeInsets.only(top: 8, left: 8, right: 8), child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold),)),
                                    itemBuilder: (context, element) => Card(margin: const EdgeInsets.only(top: 8, left: 8, right: 8), child: Padding(
                                        padding: const EdgeInsets.all(8), 
                                        child: Column(children: [
                                            ListTile(
                                                contentPadding: const EdgeInsets.all(0),
                                                leading: processIcon(element.icon, size: 48),
                                                title: Text("${element.name}"),
                                                subtitle: Text("Version: ${element.version}"),
                                                trailing: MaterialIconButton(icon: const Icon(Icons.download), onPressed: () async {
                                                    if (snapshot.data != null) {
                                                        final idx = snapshot.data!.indexOf(element);
                                                        progresses.value[idx] = -1;
                                                    
                                                        final savePath = "${await settings.settingsDirectory}/${element.name}.js";
                                                        final saveFile = File(savePath);
                                                        if (await saveFile.exists()) {
                                                            await saveFile.delete();
                                                        }

                                                        // TODO: Minified extensions in "release" branch
                                                        await Dio(BaseOptions(headers: {"User-Agent": "IbukiMobile/1.0.0 Ibuki/1.0.0 (Night Sky Studio)"})).download(
                                                            "https://raw.githubusercontent.com/Night-Sky-Studio/ibuki-extensions/master/extensions/${element.name}.js", 
                                                            savePath,
                                                            onReceiveProgress: (received, total) {
                                                                if (total != -1) {
                                                                    // debugPrint("${(received / total * 100).toStringAsFixed(0)}%");
                                                                    progresses.value[idx] = received / total;
                                                                }
                                                            }
                                                        );

                                                        debugPrint("Downloaded ${element.name} to $savePath");

                                                        // If booru already exists - update it's script
                                                        int existingIdx = settings.boorus.indexWhere((booru) => booru.name == element.name);
                                                        if (existingIdx != -1) {
                                                            final booruScript = await File(savePath).readAsString();
                                                            settings.boorus[existingIdx] = Booru(booruScript);
                                                        } else {
                                                            await settings.installBooru(savePath);
                                                        }

                                                    }
                                                }),
                                            ),
                                            Visibility(
                                                visible: progresses.value[snapshot.data!.indexOf(element)] != null, 
                                                child: LinearProgressIndicator(value: (progresses.value[snapshot.data!.indexOf(element)] ?? -1) == -1 ? null : progresses.value[snapshot.data!.indexOf(element)])
                                            )
                                        ])
                                    ))
                                )
                            : const Center(child: CircularProgressIndicator(value: null))
                        );
                    }
                )
                // StreamBuilder(
                //     stream: streamController.stream,
                //     builder: (context, snapshot) {
                //         return RefreshIndicator(
                //             onRefresh: () async {
                                
                //             },
                //             child: ListView.builder(
                //                 itemCount: snapshot.data,
                //                 itemBuilder: (context, index) {
                                    
                //                 },
                //             ),
                //         );
                //     },
                // ),
            ])
        );
    }
}