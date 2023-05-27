import 'package:flutter_js/flutter_js.dart';
import 'package:ibuki/classes/extension/types.dart';
import 'package:ibuki/classes/datetime_extensions.dart';

class BooruPost extends Comparable {   
    late int id;
    late String previewFileUrl;
    late String largeFileUrl;
    late String originalFileURL;
    late String directUrl;
    late Tags postTags;
    late Information postInformation;

    BooruPost({
        required this.id,
        required this.previewFileUrl,
        required this.largeFileUrl,
        required this.originalFileURL,
        required this.directUrl,
        required this.postTags,
        required this.postInformation
    });

    BooruPost.id(this.id) {
        previewFileUrl = "";
        largeFileUrl = "";
        originalFileURL = "";
        directUrl = "";
        postTags = Tags();
        postInformation = Information();
    }

    List<Tag>? processTags(List<dynamic>? source, TagType type) {
        if (source == null) return null;
        try {
            List<Tag> tags = [];
            for (var tag in source) {
                if (tag is String) {
                    tags.add(Tag(tagName: tag, type: type));
                } else if (tag is Map) {
                    tags.add(Tag(tagName: tag["Name"], tagDisplayOverride: tag["DisplayName"], type: type));
                }
            }
            return tags;
        } catch (_) {
            return null;
        }
    }

    BooruPost.js(JsEvalResult object) {
        BooruPost.map(object.rawResult);
    }

    BooruPost.map(Map map) {
        id = map["ID"];
        previewFileUrl = map["PreviewFileURL"];
        largeFileUrl = map["LargeFileURL"];
        originalFileURL = map["OriginalFileURL"];
        directUrl = map["DirectURL"];
        postTags = Tags(
            copyrightTags: processTags(map["Tags"]["CopyrightTags"], TagType.copyright),
            characterTags: processTags(map["Tags"]["CharacterTags"], TagType.character),
            speciesTags: processTags(map["Tags"]["SpeciesTags"], TagType.species),
            artistTags: processTags(map["Tags"]["ArtistTags"], TagType.artist),
            loreTags: processTags(map["Tags"]["LoreTags"], TagType.lore),
            generalTags: processTags(map["Tags"]["GeneralTags"], TagType.general),
            metaTags: processTags(map["Tags"]["MetaTags"], TagType.meta),
            invalidTags: processTags(map["Tags"]["InvalidTags"], TagType.unknown),
        );
        postInformation = Information(
            uploaderId: map["Information"]["UploaderID"],
            postScore: Score(
                upVotes: map["Information"]["Score"]["UpVotes"],
                downVotes: map["Information"]["Score"]["DownVotes"],
                favoritesCount: map["Information"]["Score"]["FavoritesCount"]
            ),
            source: map["Information"]["Source"],
            parentId: map["Information"]["ParentID"],
            hasChildren: map["Information"]["HasChildren"],
            createdAt: DateTimeExtensions.tryParseSafe(map["Information"]["CreatedAt"]),
            updatedAt: DateTimeExtensions.tryParseSafe(map["Information"]["UpdatedAt"]),
            rating: map["Information"]["Rating"],
            fileExtension: map["Information"]["FileExtension"],
            fileSize: map["Information"]["FileSize"],
            imageWidth: map["Information"]["ImageWidth"],
            imageHeight: map["Information"]["ImageHeight"]
        );
    }   

    @override
    String toString() => "BooruPost(id: $id, previewFileUrl: $previewFileUrl, largeFileUrl: $largeFileUrl, directUrl: $directUrl, postTags: $postTags, postInformation: $postInformation)";

    @override
    int compareTo(other) {
        // TODO: implement compareTo
        throw UnimplementedError();
    }
}