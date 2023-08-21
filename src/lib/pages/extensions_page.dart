import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:ibuki/classes/extension/extension.dart';
import 'package:ibuki/classes/helpers.dart';
import 'package:ibuki/classes/settings.dart';
import 'package:ibuki/classes/widgets/material_icon_button.dart';

class ExtensionsPage extends HookWidget {
    const ExtensionsPage({super.key, required this.settings});
    final Settings settings;

    @override
    Widget build(BuildContext context) {
        final vsync = useSingleTickerProvider();
        final tabController = useTabController(initialLength: 2, vsync: vsync);
        final streamController = useStreamController();
        final panelOpen = useState<List<bool>>(List.filled(settings.boorus.length, false));
        final progresses = useState<List<double?>>([]);

        List<Extension> extensions = [];

        Future<List<Extension>> fetchExtensions() async {
            final items = await settings.getExtensionsFromRepo();
            try {
                progresses.value = List<double?>.filled(items.length, null);
            } catch (e) {
                // yeet
            }
            return items;
        }

        return Scaffold(
            appBar: AppBar(
                title: const Text("Extensions"), 
                bottom: TabBar(controller: tabController, indicatorColor: Theme.of(context).textTheme.bodyMedium!.color!, tabs: const [
                    Tab(text: "Installed"),
                    Tab(text: "Available"),
                ]),
                actions: [
                    MaterialIconButton(icon: const Icon(Icons.refresh), onPressed: () {
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
                FutureBuilder(
                    future: fetchExtensions(),
                    builder: (context, snapshot) {
                        if (snapshot.hasData) {

                            // filter elements in snapshot.data: all elements not in (settings.boorus) && elements in (settings.boorus) with version > (settings.boorus).version 
                            final elements = (snapshot.data ?? []).where((element) => !settings.boorus.any((booru) => booru.name == element.name) || settings.boorus.any((booru) => element.version! > booru.version!)).toList();

                            return GroupedListView<Extension, String>(
                                elements: elements, 
                                groupBy: (element) => settings.boorus.any((booru) => element.version! > booru.version!) ? "Has updates" : "Available",
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
                                                    // TODO: Minified extensions in "release" branch
                                                    await Dio(BaseOptions(headers: {"User-Agent": "IbukiMobile/1.0.0 Ibuki/1.0.0 (Night Sky Studio)"})).download(
                                                        "https://raw.githubusercontent.com/Night-Sky-Studio/ibuki-extensions/master/extensions/${element.name}.js", 
                                                        savePath,
                                                        onReceiveProgress: (received, total) {
                                                            if (total != -1) {
                                                                debugPrint("${(received / total * 100).toStringAsFixed(0)}%");
                                                                progresses.value[idx] = received / total;
                                                            }
                                                        }
                                                    );

                                                    debugPrint("Downloaded ${element.name} to $savePath");

                                                    await settings.installBooru(savePath);

                                                }
                                            }),
                                        ),
                                        Visibility(
                                            visible: progresses.value[snapshot.data!.indexOf(element)] != null, 
                                            child: LinearProgressIndicator(value: (progresses.value[snapshot.data!.indexOf(element)] ?? -1) == -1 ? null : progresses.value[snapshot.data!.indexOf(element)])
                                        )
                                    ])
                                ))
                            );
                        } else {
                            return const Center(child: CircularProgressIndicator(value: null));
                        }
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