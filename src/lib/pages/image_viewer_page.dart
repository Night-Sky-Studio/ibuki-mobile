import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ibuki/classes/extension/booru_post.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ibuki/classes/widgets/tag_widgets.dart';

class MaterialIconButton extends StatelessWidget {
    final Icon icon;
    final VoidCallback onPressed;
    final Color? color;
    
    const MaterialIconButton({super.key, required this.icon, required this.onPressed, this.color});

    @override
    Widget build(BuildContext context) {
        return Material(color: Colors.transparent, shape: const CircleBorder(),
            child: InkWell(customBorder: const CircleBorder(),
                onTap: onPressed,
                child: Padding(padding: const EdgeInsets.all(16), child: icon),
            ),
        );
    }
}

class ImageViewerPage extends HookWidget {
    final String currentBooru;
    final BooruPost image;
    final ImageProvider placeholder;

    const ImageViewerPage({super.key, required this.currentBooru, required this.image, required this.placeholder});

    @override
    Widget build(BuildContext context) {
        final vsync = useSingleTickerProvider();
        final tabController = useTabController(initialLength: 3, vsync: vsync);

        return Scaffold(
            appBar: AppBar(title: Text("ID: ${image.id}"), backgroundColor: Theme.of(context).colorScheme.primary,),
            body: SlidingUpPanel(
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
                                MaterialIconButton(icon: const Icon(Icons.download), onPressed: () async { 
                                    Directory? dir;
                                    if (Platform.isAndroid) {
                                        dir = await getTemporaryDirectory();//Directory("/storage/emulated/0/Download");//await getExternalStorageDirectory();
                                    } else {
                                        dir = await getDownloadsDirectory();
                                    }

                                    if(dir != null) {
                                        String savePath = "${dir.path}/Ibuki/$currentBooru/${image.id}.${image.postInformation.fileExtension}";

                                        try {
                                            await Dio(BaseOptions(headers: {"User-Agent": "Aster/1.0.0 Ibuki/1.0.0"})).download(
                                                image.originalFileURL, 
                                                savePath,
                                                onReceiveProgress: (received, total) {
                                                    if (total != -1) {
                                                        debugPrint("${(received / total * 100).toStringAsFixed(0)}%");
                                                        //you can build progressbar feature too
                                                    }
                                                }
                                            );

                                            if (Platform.isAndroid) {
                                                MediaStore.appFolder = "Ibuki/$currentBooru/";
                                                var store = MediaStore();
                                                bool result = await store.saveFile(tempFilePath: savePath, dirType: DirType.download, dirName: DirName.download, relativePath: "Ibuki/$currentBooru/");
                                                debugPrint("$result");
                                            }

                                            debugPrint("File is saved to download folder.");  
                                        } on DioError catch (e) {
                                            debugPrint(e.message);
                                        }
                                    }
                                    
                                    
                                }),
                                MaterialIconButton(icon: const Icon(Icons.share), onPressed: () { }),
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
                                if (image.postTags.artistTags != null && image.postTags.artistTags!.isNotEmpty) TagsList(title: "Artist", tags: image.postTags.artistTags!.map((e) => e.tagDisplay()).toList(), color: Colors.red[400],),
                                if (image.postTags.characterTags != null && image.postTags.characterTags!.isNotEmpty) TagsList(title: "Character", tags: image.postTags.characterTags!.map((e) => e.tagDisplay()).toList(), color: Colors.green,),
                                if (image.postTags.copyrightTags != null && image.postTags.copyrightTags!.isNotEmpty) TagsList(title: "Copyright", tags: image.postTags.copyrightTags!.map((e) => e.tagDisplay()).toList(), color: Colors.purple[400],),
                                if (image.postTags.generalTags != null && image.postTags.generalTags!.isNotEmpty) TagsList(title: "General", tags: image.postTags.generalTags!.map((e) => e.tagDisplay()).toList(), color: Colors.blue,),
                                if (image.postTags.metaTags != null && image.postTags.metaTags!.isNotEmpty) TagsList(title: "Meta", tags: image.postTags.metaTags!.map((e) => e.tagDisplay()).toList(), color: Colors.orange[400],),
                                if (image.postTags.speciesTags != null && image.postTags.speciesTags!.isNotEmpty) TagsList(title: "Species", tags: image.postTags.speciesTags!.map((e) => e.tagDisplay()).toList(), color: Colors.indigo[400],),
                                if (image.postTags.invalidTags != null && image.postTags.invalidTags!.isNotEmpty) TagsList(title: "Invalid", tags: image.postTags.invalidTags!.map((e) => e.tagDisplay()).toList(), color: Colors.grey[400],),
                            ],)),
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
                body: InteractiveViewer(
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
                                            Image(image: placeholder, fit: BoxFit.contain),
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