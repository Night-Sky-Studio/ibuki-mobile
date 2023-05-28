import 'package:chips_input/chips_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ibuki/classes/extension/types.dart';
import 'package:ibuki/classes/settings.dart';
import 'package:ibuki/classes/widgets/tag_widgets.dart';

class _PreferredAppBarSize extends Size {
  _PreferredAppBarSize(this.toolbarHeight, this.bottomHeight)
    : super.fromHeight((toolbarHeight ?? kToolbarHeight) + (bottomHeight ?? 0));

  final double? toolbarHeight;
  final double? bottomHeight;
}


class SearchAppBar extends HookWidget implements PreferredSizeWidget {
    SearchAppBar({
        super.key, 
        required this.settings, 
        required this.onSearch, 
        required this.onSearchClear,
        this.title, 
        this.toolbarHeight, 
        this.bottom, 
    });
    
    final String? title;
    final Settings settings;
    final double? toolbarHeight;
    final PreferredSizeWidget? bottom;
    final Function(BuildContext, List<Tag>)? onSearch;
    final Function(BuildContext context)? onSearchClear;

    @override
    Widget build(BuildContext context) {
        // final title = useState(this.title ?? "Ibuki");
        final searchActive = useState(false);
        final search = useState("");
        final searchQuery = useState<List<Tag>>([]);


        Future<List<Tag>?> searchTag(String query) async {
            final booru = settings.activeBooru;
            final tags = await booru.getTagSuggestion(search: query, limit: 10);
            return tags;
        }

        void searchFinished(BuildContext context) {
            if (searchActive.value) {
                search.value = Tag.tagListToString(searchQuery.value);
                onSearch?.call(context, searchQuery.value);
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
                    final results = await searchTag(query.toLowerCase()) ?? [];
                    return results;
                }
                return [];
            },
            initialValue: searchQuery.value,
            onChanged: (value) => searchQuery.value = value,
            onEditingComplete: () => searchFinished(context),
        );

        return AppBar(
            title: searchActive.value ? chipInput : Text(search.value.isNotEmpty ? search.value : title ??  ""),
            actions: [
                IconButton(
                    onPressed: () => searchFinished(context),
                    icon: const Icon(Icons.search)
                ),
                Visibility(
                    visible: search.value.isNotEmpty || searchActive.value,
                    child: IconButton(
                        onPressed: () {
                            searchActive.value = false;
                            if (searchQuery.value.isNotEmpty || search.value.isNotEmpty) {
                                searchQuery.value = [];
                                search.value = "";
                            }
                            onSearchClear?.call(context);
                            //title = settings.activeBooru.name ?? "Ibuki";
                        }, 
                        icon: const Icon(Icons.close)
                    )
                )
            ],
            backgroundColor: searchActive.value ? const Color(0xFF303030) : null,
        );
    }
    
    @override
    Size get preferredSize => _PreferredAppBarSize(toolbarHeight, bottom?.preferredSize.height);

}