import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ibuki/classes/extension/booru_post.dart';
import 'package:ibuki/classes/extension/types.dart';
import 'package:ibuki/classes/hooks/use_webview_hook.dart';
// import 'package:ibuki/classes/hooks/panel_controller_hook.dart';
import 'package:ibuki/classes/settings.dart';
import 'package:ibuki/classes/widgets/material_icon_button.dart';
import 'package:ibuki/pages/main_page.dart';
// import 'package:media_kit/media_kit.dart';
// import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:pasteboard/pasteboard.dart';
// import 'package:preload_page_view/preload_page_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ibuki/classes/widgets/tag_widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

/*
class _PlayerHook extends Hook<Player> {
    const _PlayerHook();

    @override
    _PlayerHookState createState() => _PlayerHookState();
}

class _PlayerHookState extends HookState<Player, _PlayerHook> {
    late final Player player;

    @override
    void initHook() {
        super.initHook();
        player = Player();
    }

    @override
    void dispose() async {
        await player.dispose();
        super.dispose();
    }

    @override
    Player build(BuildContext context) {
        return player;
    }
}

Player usePlayer() {
    return use(const _PlayerHook());
}
*/

class Viewer extends HookWidget {
    const Viewer({super.key, required this.settings, required this.image});

    final Settings settings;
    final BooruPost image;

    @override
    Widget build(BuildContext context) {
        final vsync = useSingleTickerProvider();
        final tabController = useTabController(initialLength: 3, vsync: vsync);
        final panelScrollController = useScrollController();
        panelScrollController.addListener(() {
            debugPrint("Panel scroll: ${panelScrollController.offset}");

            // When user will try to scroll back to the top, we will start closing panel
            // This should be fired only when our panel's scroll view can be scrolled (maxScrollExtent > panelHeight)
            // 

            // if (panelController.isAttached && 
            //     panelScrollController.offset <= 0 && 
            //     panelScrollController.position.maxScrollExtent > MediaQuery.of(context).size.height * 0.8) {
                
            //     panelController.close();
            // }
        });
        final downloadProgress = useState<double?>(null);
        final isMounted = useIsMounted();
        final webViewController = useWebViewController(image.originalFileURL);
        final panelController = PanelController();

        SnackBar makeSnackbar(String text) {
            return SnackBar(content: Text(text), behavior: SnackBarBehavior.floating, margin: const EdgeInsets.all(72));
        }

        Future<String?> downloadToTemp(BooruPost image, {BuildContext? context}) async {
            Directory dir = await getTemporaryDirectory();

            String savePath = "${dir.path}/Ibuki/Share/${image.id}.${image.postInformation.fileExtension}";

            try {
                await Dio(BaseOptions(headers: {"User-Agent": "IbukiMobile/1.0.0 Ibuki/1.0.0 (Night Sky Studio)"})).download(
                    image.largeFileUrl, 
                    savePath,
                    onReceiveProgress: (received, total) {
                        if (total != -1) {
                            debugPrint("${(received / total * 100).toStringAsFixed(0)}%");
                        }
                    }
                );

                return savePath;
            } on DioException catch (_) {
                return null;
            }
        }

        /// This sadly does not work and it's not even my fault
        /// Looks like flutter can't update widgets of this kind of construction,
        /// since it does not seem like Dart supports references at all.
        
        // final downloadIcons = <Widget>[
        //     const Icon(Icons.download),
        //     CircularProgressIndicator(value: (downloadProgress.value ?? -1) == -1 ? null : downloadProgress.value, valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).textTheme.bodyMedium!.color!)),
        //     const Icon(Icons.check)
        // ];
        // final downloadIcon = useState<Widget>(downloadIcons[0]);
        //BooruPost image() => images[pageController.page!.truncate()];

        void onTagPressed(Tag tag) {
            debugPrint("Tag: ${tag.tagName}");
            
            if (panelController.isAttached) panelController.close();

            Navigator.push(context,  
                MaterialPageRoute(
                    builder: (context) => MainPage(settings: settings, searchRequest: tag)
                )
            );
        }

        return Scaffold(
            appBar: AppBar(title: Text("ID: ${image.id}"), backgroundColor: Theme.of(context).colorScheme.primary),
            body: SlidingUpPanel(
                controller: panelController,
                minHeight: 64,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
                panel: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                        Container(height: 64,
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                                MaterialIconButton(
                                    icon: downloadProgress.value == null 
                                        ? const Icon(Icons.download) 
                                        : downloadProgress.value == 1
                                            ? const Icon(Icons.check)
                                            : CircularProgressIndicator(value: (downloadProgress.value ?? -1) == -1 ? null : downloadProgress.value, valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).textTheme.bodyMedium!.color!)), 
                                    onPressed: () async { 
                                        downloadProgress.value = -1;
                                        Directory? dir;
                                        if (Platform.isAndroid) {
                                            dir = await getTemporaryDirectory();
                                        } else {
                                            dir = await getDownloadsDirectory();
                                        }

                                        if(dir != null) {
                                            String savePath = "${dir.path}/Ibuki/${settings.activeBooru?.name!}/${image.id}.${image.postInformation.fileExtension}";

                                            try {
                                                await Dio(BaseOptions(headers: {"User-Agent": "IbukiMobile/1.0.0 Ibuki/1.0.0 (Night Sky Studio)"})).download(
                                                    image.originalFileURL, 
                                                    savePath,
                                                    onReceiveProgress: (received, total) {
                                                        if (total != -1) {
                                                            if(isMounted()) {
                                                                downloadProgress.value = received / total;
                                                            } else {
                                                                debugPrint("Unmounted. Progress: ${(received / total) * 100}%");
                                                            }
                                                        }
                                                    }
                                                );

                                                if (Platform.isAndroid) {
                                                    MediaStore.appFolder = "Ibuki/${settings.activeBooru?.name!}/";
                                                    var store = MediaStore();
                                                    bool result = await store.saveFile(tempFilePath: savePath, dirType: DirType.download, dirName: DirName.download, relativePath: "Ibuki/${settings.activeBooru?.name!}/");
                                                    debugPrint("$result");
                                                }

                                                debugPrint("File is saved to download folder.");  
                                            } on DioException catch (e) {
                                                debugPrint(e.message);
                                            }
                                        }
                                    }
                                ),
                                MaterialIconButton(icon: const Icon(Icons.share), onPressed: () async {
                                    if (Platform.isWindows || Platform.isMacOS) {
                                        final result = await showDialog<int>(context: context, builder: (context) {
                                            return AlertDialog(
                                                title: const Text("Share"),
                                                actions: [
                                                    ElevatedButton(onPressed: () => Navigator.pop(context, 1), child: const Text("Copy Image")),
                                                    ElevatedButton(onPressed: () => Navigator.pop(context, 2), child: const Text("Copy Direct URL")),
                                                    ElevatedButton(onPressed: () => Navigator.pop(context, 3), child: const Text("More")),
                                                    TextButton(onPressed: () { Navigator.pop(context, 0); }, child: const Text("Cancel")),
                                                ],
                                                alignment: Alignment.center,   
                                            );
                                        });

                                        switch(result) {
                                            case 0:
                                                break;
                                            case 1:
                                                final path = await downloadToTemp(image);
                                                if (path != null) {
                                                    await Pasteboard.writeFiles([path]);
                                                }

                                                break;
                                            case 2:
                                                Clipboard.setData(ClipboardData(text: image.directUrl));
                                                break;
                                            case 3:
                                                final path = await downloadToTemp(image);
                                                if (path != null) {
                                                    await Share.shareXFiles([XFile(path)]);

                                                    // TODO: Delete temp files on app close, not after share
                                                    await File(path).delete();
                                                    debugPrint("File removed.");  
                                                }
                                                break;
                                        }
                                    } else {
                                        final path = await downloadToTemp(image);   
                                        if (path != null) {
                                            await Share.shareXFiles([XFile(path)]);

                                            // TODO: Delete temp files on app close, not after share
                                            await File(path).delete();
                                            debugPrint("File removed.");  
                                        }
                                    }
                                
                                }),
                                MaterialIconButton(icon: const Icon(Icons.favorite_border_outlined), onPressed: () { debugPrint("favorite"); }),
                            ]),
                        ),
                        Container(color: Theme.of(context).colorScheme.primary, height: 48, 
                            child: TabBar(controller: tabController, indicatorColor: Theme.of(context).textTheme.bodyMedium!.color!, tabs: const [
                                Tooltip(message: "Tags", child: Tab(icon: Icon(Icons.sell))),
                                Tooltip(message: "Information", child: Tab(icon: Icon(Icons.description))),
                                Tooltip(message: "Comments", child: Tab(icon: Icon(Icons.message))),
                            ])
                        ),
                        Expanded(child: Container(color: Theme.of(context).colorScheme.background, child: TabBarView(controller: tabController, children: [
                            SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                TagsList(title: "Artists", tags: image.postTags.artistTags, onTagPressed: onTagPressed),
                                TagsList(title: "Copyrights", tags: image.postTags.copyrightTags, onTagPressed: onTagPressed),
                                TagsList(title: "Species", tags: image.postTags.speciesTags, onTagPressed: onTagPressed),
                                TagsList(title: "Characters", tags: image.postTags.characterTags, onTagPressed: onTagPressed),
                                TagsList(title: "General", tags: image.postTags.generalTags, onTagPressed: onTagPressed),
                                TagsList(title: "Meta", tags: image.postTags.metaTags, onTagPressed: onTagPressed),
                                TagsList(title: "Invalid", tags: image.postTags.invalidTags, onTagPressed: onTagPressed)
                            ])),
                            SingleChildScrollView(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text("ID", style: Theme.of(context).textTheme.headlineSmall),
                                Text("${image.id}"),
                                const SizedBox(height: 16),

                                Text("Uploader", style: Theme.of(context).textTheme.headlineSmall),
                                Text("${image.postInformation.uploaderId}"),    // TODO: Query user info
                                const SizedBox(height: 16),

                                Text("Date", style: Theme.of(context).textTheme.headlineSmall),
                                Text("${image.postInformation.createdAt}"),
                                const SizedBox(height: 16),

                                Text("Size", style: Theme.of(context).textTheme.headlineSmall),
                                Text("${image.postInformation.fileSize} B .${image.postInformation.fileExtension} (${image.postInformation.imageWidth}x${image.postInformation.imageHeight})"),
                                const SizedBox(height: 16),

                                Text("Rating", style: Theme.of(context).textTheme.headlineSmall),
                                Text("${image.postInformation.rating}"),
                                const SizedBox(height: 16),

                                Text("Score", style: Theme.of(context).textTheme.headlineSmall),
                                Row(children: [
                                    Text("Upvotes: ${image.postInformation.postScore?.upVotes}"), 
                                    const SizedBox(width: 16),
                                    Text("Downvotes: ${image.postInformation.postScore?.downVotes}"), 
                                    const SizedBox(width: 16),
                                    Text("Favorites: ${image.postInformation.postScore?.favoritesCount}"),
                                ]),
                                const SizedBox(height: 16),

                                Text("Source", style: Theme.of(context).textTheme.headlineSmall),
                                Text("${image.postInformation.source}"),
                                const SizedBox(height: 16),

                                Text("Parent post", style: Theme.of(context).textTheme.headlineSmall),
                                Text("${image.postInformation.parentId}"),
                                const SizedBox(height: 16),
                            ]))),
                            const Center(child: Text("Comments")),
                        ]))),
                    ],
                ),
                body: image.isVideo() 
                ? Container(
                    margin: EdgeInsets.only(bottom: /*Theme.of(context).platform == TargetPlatform.iOS ? 168 :*/ Platform.isAndroid ? 168 : 120),//144), 
                    child: WebViewWidget(controller: webViewController)
                )
                : InteractiveViewer(
                    boundaryMargin: const EdgeInsets.all(0),
                    minScale: 1,
                    maxScale: 4, child: Container(
                        margin: EdgeInsets.only(bottom: /*Theme.of(context).platform == TargetPlatform.iOS ? 168 :*/ Platform.isAndroid ? 168 : 120),//144), 
                        child: Center(
                            child: CachedNetworkImage(imageUrl: image.largeFileUrl,
                                fadeInCurve: Curves.linear,
                                fadeOutCurve: Curves.linear,
                                fadeInDuration: const Duration(milliseconds: 250), fadeOutDuration: const Duration(milliseconds: 250), placeholderFadeInDuration: const Duration(milliseconds: 250),
                                progressIndicatorBuilder: (context, url, downloadProgress) {                            
                                    return Stack(
                                        fit: StackFit.expand,
                                        alignment: Alignment.center,
                                        children: [
                                            CachedNetworkImage(imageUrl: image.previewFileUrl, fit: BoxFit.contain),
                                            BackdropFilter(filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                                                child: Center(child: CircularProgressIndicator(value: downloadProgress.progress))
                                            ),
                                        ]
                                    );
                                }
                            ),
                        )
                    )
                ),
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                
                parallaxEnabled: true,
            )
        );
    }
}

class ImageViewerPage extends HookWidget {
    final Settings settings;
    // final BooruPost image;
    final List<BooruPost> images;
    final int currentIndex;
    // final ImageProvider placeholder;

    /// Called to ask for more images from Dashboard page
    final VoidCallback? onEndReached;

    ImageViewerPage({super.key, required this.settings, required this.images, required this.currentIndex, this.onEndReached});

    @override
    Widget build(BuildContext context) {
        final pageController = usePageController(initialPage: currentIndex);

        return RawKeyboardListener(
            focusNode: FocusNode(),
            onKey: (value) {
                if (value.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
                    if (pageController.page! > 0) {
                        pageController.previousPage(duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
                    }
                } else if (value.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
                    if (pageController.page! < images.length) {
                        pageController.nextPage(duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
                    }
                }
            },
            child: PageView.builder(
                controller: pageController,
                allowImplicitScrolling: false,
                itemCount: images.length,
                scrollDirection: Axis.horizontal,
                // preloadPagesCount: 2,
                onPageChanged: (value) {
                    if (value == images.length) onEndReached?.call();
                    // downloadProgress.value = null;
                },
                itemBuilder: (context, index) {
                    return Viewer(settings: settings, image: images[index]);
                },
            ),
        );
    }
}