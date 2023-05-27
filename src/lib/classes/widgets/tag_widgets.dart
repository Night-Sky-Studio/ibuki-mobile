import 'package:flutter/material.dart';
import 'package:ibuki/classes/extension/types.dart';


class TagTheme {
    final Color generalTagColor;
    final Color artistTagColor;
    final Color copyrightTagColor;
    final Color characterTagColor;
    final Color speciesTagColor;
    final Color metaTagColor;
    final Color loreTagColor;
    final Color poolTagColor;
    final Color unknownTagColor;

    const TagTheme({
        required this.generalTagColor, 
        required this.artistTagColor, 
        required this.copyrightTagColor,
        required this.characterTagColor, 
        required this.speciesTagColor, 
        required this.metaTagColor, 
        required this.loreTagColor, 
        required this.poolTagColor,
        required this.unknownTagColor
    });

    /// [dart-lang/language#1296](https://github.com/dart-lang/language/issues/1296)
    factory TagTheme.standard() {
        return const TagTheme(
            generalTagColor: Colors.blue,
            artistTagColor: Colors.red,
            copyrightTagColor: Colors.purple,
            characterTagColor: Colors.green,
            speciesTagColor: Colors.deepOrange,
            metaTagColor: Colors.orange,
            loreTagColor: Colors.lightGreen,

            // Colors.pink[200]!
            // This is stupid. Colors are constant values,
            // but here I can't use `Colors.pink[200]`, because for some reason it
            // is not constant. 
            poolTagColor: Color(0xFFF48FB1), 
            unknownTagColor: Colors.grey
        );
    }

    factory TagTheme.danbooru() {
        return const TagTheme(
            generalTagColor:  Color(0xff009be6),
            artistTagColor: Color(0xffff8a8b),
            copyrightTagColor: Colors.purple,
            characterTagColor: Colors.green,
            speciesTagColor: Colors.grey,
            metaTagColor: Colors.orange,
            loreTagColor: Colors.grey,
            poolTagColor: Colors.grey,
            unknownTagColor: Colors.grey
        );
    }

    factory TagTheme.e621() {
        return const TagTheme(
            generalTagColor: Color(0xffb4c7d9),
            artistTagColor: Color(0xfff2ac08),
            copyrightTagColor: Color(0xffdd00dd),
            characterTagColor: Color(0xff00aa00),
            speciesTagColor: Color(0xffed5d1f),
            metaTagColor: Color(0xffffffff),
            loreTagColor: Color(0xff228822),
            poolTagColor: Color(0xfff5deb3),
            unknownTagColor: Color(0xffff3d3d),
        );
    }
}

// class Tag {
//     final String tag;
//     final TagType type;

//     String displayName() => tag.replaceAll('_', ' ') ;

//     const Tag(this.tag, this.type);
// }

class TagChip extends StatelessWidget {
    final Tag tag;
    final TagTheme? theme;

    const TagChip({
        Key? key,
        required this.tag,
        this.theme,
    }) : super(key: key);
    
    _makeChip(Color color) {
        return Chip(
            label: Text(tag.tagDisplay()),
            backgroundColor: color,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
    }

    @override
    Widget build(BuildContext context) {
        final TagTheme theme = this.theme ?? TagTheme.standard();

        switch(tag.type) {
            case TagType.copyright:
                return _makeChip(theme.copyrightTagColor);
            case TagType.general:
                return _makeChip(theme.generalTagColor);
            case TagType.artist:
                return _makeChip(theme.artistTagColor);
            case TagType.character:
                return _makeChip(theme.characterTagColor);
            case TagType.species:
                return _makeChip(theme.speciesTagColor);
            case TagType.meta:
                return _makeChip(theme.metaTagColor);
            case TagType.lore:
                return _makeChip(theme.loreTagColor);
            case TagType.pool:
                return _makeChip(theme.poolTagColor);
            case TagType.unknown:
                return _makeChip(theme.unknownTagColor);
            default:
                return _makeChip(theme.unknownTagColor);
        }
    }
}

class TagsList extends StatelessWidget {
    final String title;
    final List<String> tags;
    final Color? color;

    const TagsList({super.key, required this.title, required this.tags, this.color});

    @override
    Widget build(BuildContext context) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(padding: const EdgeInsets.only(left: 16, right: 16, top: 16), child: Text(style: Theme.of(context).textTheme.headlineSmall, title)),
            Padding(padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8), child: Wrap(alignment: WrapAlignment.start, spacing: 8, runSpacing: 8, children: tags.map((e) => Chip(label: Text(e), backgroundColor: color, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)).toList()))
        ]);
    }
}