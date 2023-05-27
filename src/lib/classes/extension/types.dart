import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_js/flutter_js.dart';

abstract class ExtensionObject {
    ExtensionObject();

    factory ExtensionObject.fromEvalObject(JsEvalResult object) {
        if (object.rawResult is Map) {
            return ExtensionObject.fromMap(object.rawResult);
        } else {
            throw UnimplementedError();
        }
    }

    factory ExtensionObject.fromMap(Map object) {
        throw UnimplementedError();
    }

    @nonVirtual
    void init(JsEvalResult object) {
        if (object.rawResult is Map) {
            initFromMap(object.rawResult);
        } else {
            initFromJson(object.stringResult);
        }
    }

    @nonVirtual
    void initFromJson(String json) {
        initFromMap(jsonDecode(json));
    }

    void initFromMap(Map map) {
        throw UnimplementedError();
    }
}

enum TagType {
    general, artist, copyright, character, meta, lore, species, pool, unknown,
}

class Tag extends ExtensionObject {
    String tagName;
    String? tagDisplayOverride;
    TagType type;

    String tagDisplay({String separator = "_"}) => tagDisplayOverride ?? tagName.replaceAll(separator, " ");  

    Tag({required this.tagName, this.tagDisplayOverride, required this.type});

    static String tagListToString(List<Tag> tags) {
        return tags.map((e) => e.tagName).join(" ");
    }

    @override
    void initFromMap(Map map) {
        tagName = map["Name"];
        tagDisplayOverride = map["DisplayName"];
        type = TagType.values.firstWhere((e) => describeEnum(e) == map["Category"]);
    }

    @override
    factory Tag.fromMap(Map object) {
        return Tag(
            tagName: object["Name"],
            tagDisplayOverride: object["DisplayName"],
            type: TagType.values.firstWhere((e) => describeEnum(e) == object["Category"]),
        );
    }

    @override
    String toString() => tagName;
}

class Tags {
    List<Tag>? copyrightTags;
    List<Tag>? characterTags;
    List<Tag>? speciesTags;
    List<Tag>? artistTags;
    List<Tag>? loreTags;
    List<Tag>? generalTags;
    List<Tag>? metaTags;
    List<Tag>? invalidTags;

    Tags({
        this.copyrightTags,
        this.characterTags,
        this.speciesTags,
        this.artistTags,
        this.loreTags,
        this.generalTags,
        this.metaTags,
        this.invalidTags
    });

    @override
    String toString() => "Tags(copyrightTags: $copyrightTags, characterTags: $characterTags, speciesTags: $speciesTags, artistTags: $artistTags, loreTags: $loreTags, generalTags: $generalTags, metaTags: $metaTags, invalidTags: $invalidTags)";
}

class Score {
    int upVotes;
    int downVotes;
    int favoritesCount;

    int overallScore() => upVotes - downVotes;

    Score({
        required this.upVotes,
        required this.downVotes,
        required this.favoritesCount
    });

    @override
    String toString() => "Score(upVotes: $upVotes, downVotes: $downVotes, favoritesCount: $favoritesCount)";
}

class Information {
    int? uploaderId;
    Score? postScore;
    String? source;
    int? parentId;
    bool? hasChildren;
    DateTime? createdAt;
    DateTime? updatedAt;
    String? rating;
    String? fileExtension;
    int? fileSize;
    int? imageWidth;
    int? imageHeight;

    Information({
        this.uploaderId,
        this.postScore,
        this.source,
        this.parentId,
        this.hasChildren,
        this.createdAt,
        this.updatedAt,
        this.rating,
        this.fileExtension,
        this.fileSize,
        this.imageWidth,
        this.imageHeight
    });

    @override
    String toString() => "Information(uploaderId: $uploaderId, postScore: $postScore, source: $source, parentId: $parentId, hasChildren: $hasChildren, createdAt: $createdAt, updatedAt: $updatedAt, fileExtension: $fileExtension, fileSize: $fileSize, imageWidth: $imageWidth, imageHeight: $imageHeight)";
}