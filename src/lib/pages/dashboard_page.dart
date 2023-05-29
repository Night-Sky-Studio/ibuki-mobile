import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ibuki/classes/extension/booru.dart';
import 'package:ibuki/classes/extension/booru_post.dart';
import 'package:ibuki/classes/extension/types.dart';
import 'package:ibuki/classes/settings.dart';
import 'package:ibuki/pages/image_viewer_page.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:window_manager/window_manager.dart';

class DashboardPage extends HookWidget with WindowListener {
    DashboardPage({super.key, required this.settings, this.search = "", this.onSearchChanged});
    final Settings settings;
    final String search;
    final Function(List<Tag>)? onSearchChanged;

    int _calcColumnsCount(double width, {double colWidth = 160}) {
        return width ~/ colWidth;
    }

    final columnCount = useState(3);

    @override
    void onWindowResize() async {
        final width = (await WindowManager.instance.getBounds()).width;

        columnCount.value = _calcColumnsCount(width);
    }

    @override
    Widget build(BuildContext context) {        
        List<BooruPost> posts = [];
        final streamController = useStreamController();
        final isMounted = useIsMounted();

        windowManager.addListener(this);

        Future<void> fetchPage(int page) async {
            final items = await settings.activeBooru.getPosts(page: page, search: search);
            posts.addAll(items);
            streamController.sink.add(posts);
        }

        int page = 1;

        final gridScrollController = useScrollController();
        // gridScrollController.addListener(() {
        //     if (gridScrollController.position.pixels == gridScrollController.position.maxScrollExtent) {
        //         fetchPage(++page);
        //         debugPrint("Current Page: $page");
        //     }
        // });

        fetchPage(page++);
        fetchPage(page);

        //columnCount.value = _calcColumnsCount(MediaQuery.of(context).size.width);
        
        if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
            onWindowResize();
        } else {
            //columnCount.value = _calcColumnsCount(MediaQuery.of(context).size.width);
        }

        return StreamBuilder(
            stream: streamController.stream,
            builder: (context, snapshot) {
                return RefreshIndicator(
                    onRefresh: () async {
                        page = 1;
                        posts.clear();
                        await fetchPage(page++);
                        await fetchPage(page);
                    }, 
                    child: CustomScrollView(
                        slivers: [
                            SliverGrid(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3/*columnCount.value*/),
                                delegate: SliverChildBuilderDelegate((context, index) {
                                    try {
                                        return Card(
                                            elevation: 2,
                                            child: InkWell(
                                                borderRadius: BorderRadius.circular(4),
                                                onTap: () async {
                                                    debugPrint("Tapped image $index");
                                                    
                                                    final Tag? result = await Navigator.push(context, 
                                                        MaterialPageRoute(
                                                            builder: (context) => ImageViewerPage(settings: settings, image: posts[index], placeholder: NetworkImage(posts[index].previewFileUrl))
                                                        )
                                                    );

                                                    if (!isMounted()) return;

                                                    if (result != null) {
                                                        onSearchChanged?.call([result]);
                                                    }
                                                },
                                                child: Container(
                                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
                                                    clipBehavior: Clip.antiAlias,
                                                    child: CachedNetworkImage(
                                                        imageUrl: posts[index].previewFileUrl,
                                                        imageBuilder: (context, provider) => Ink.image(image: provider, fit: BoxFit.cover),
                                                        errorWidget: (context, url, error) => Icon(Icons.error_rounded, color: Colors.red[400])
                                                    ),
                                                ),
                                            )
                                        );
                                    } catch (_) {
                                        return const Card(child: Icon(Icons.error_rounded, color: Colors.amber));
                                    }
                                }, childCount: posts.length),
                            ),
                            SliverToBoxAdapter(
                                child: Center(child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: VisibilityDetector(
                                        key: const  Key("page_end"),
                                        child: const CircularProgressIndicator(value: null),
                                        onVisibilityChanged: (info) {
                                            if (info.visibleFraction > 0) {
                                                fetchPage(++page);
                                                debugPrint("Current Page: $page");
                                            }
                                        },
                                    ),
                                ))
                            )
                        ],
                        controller: gridScrollController,
                    ),
                );
            },
        );
    }
}