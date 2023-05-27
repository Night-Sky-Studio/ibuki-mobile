/// <reference path="./API.d.ts" />

const Extension = {
    name: "Safebooru",
    kind: "sfw",
    api_type: "json",
    base_url: "https://safebooru.donmai.us",
    tags_separator: " ",
    rate_limit: 10,
    network_access: true,
    icon: "https://danbooru.donmai.us/packs/static/images/danbooru-logo-128x128-ea111b6658173e847734.png"
}

/// Helpers

function MakeTagsFromTagsString(string, separator) {
    return string.split(separator)
}

function ParsePostJSON(json) {
    try {
        if (typeof(json) !== typeof(JSON)) json = JSON.parse(json)
        
        // When the required by Ibuki fields are empty - don't add this post to the returnable array
        if (json.id == undefined || json.preview_file_url == undefined || json.large_file_url == undefined || json.is_deleted == true || json.is_banned == true) 
            return null
        
        return {
            ID: json.id,
            PreviewFileURL: json.preview_file_url,
            LargeFileURL: json.large_file_url,
            OriginalFileURL: json.file_url,
            DirectURL: url({base: Extension.base_url, path: `posts/${json.id}`}),
            Tags: {
                CopyrightTags: MakeTagsFromTagsString(json.tag_string_copyright, Extension.tags_separator),
                CharacterTags: MakeTagsFromTagsString(json.tag_string_character, Extension.tags_separator),
                SpeciesTags: null,
                ArtistTags: MakeTagsFromTagsString(json.tag_string_artist, Extension.tags_separator),
                LoreTags: null,
                GeneralTags: MakeTagsFromTagsString(json.tag_string_general, Extension.tags_separator),
                MetaTags: MakeTagsFromTagsString(json.tag_string_meta, Extension.tags_separator)
            },
            Information: {
                UploaderID: json.uploader_id,
                Score: {
                    UpVotes: json.up_score,
                    DownVotes: json.down_score,
                    FavoritesCount: json.fav_count,
                },
                Source: json.source,
                ParentID: json.parent_id,
                HasChildren: json.has_children,
                CreatedAt: json.created_at,
                UploadedAt: json.updated_at,
                FileExtension: json.file_ext,
                FileSize: json.file_size,
                ImageWidth: json.image_width,
                ImageHeight: json.image_height,
            }
        }
    } catch (_) {
        return null
    }
}
 
function ParsePostsJSON(json) {
    let result = []
    let array = JSON.parse(json_string)
    
    for (let i = 0; i < array.length; i++) {
        let post = ParsePostJSON(array[i])
        if (post != null)
            result.push(post)
    }   
    
    return result
}

function ParseTagJSON(json) {
    try {
        if (typeof(json) !== typeof(JSON)) json = JSON.parse(json) 

        return {
            Tag: json.name,
            Category: json.category,
        }

    } catch (_) {
        return null
    }
}

/// Main implementation 

async function GetPosts({page = 1, limit = 20, search = "", auth = ""}) {
    let posts = await (await fetch(url({
        base: Extension.base_url,
        path: "posts.json",
        query: [
            { "page": page },
            { "limit": limit },
            { "tags": search },
            { "auth": auth }
        ]
    }), {
        method: "GET",
        headers: {
            "Content-Type": "application/json",
            "User-Agent": UserAgent
        }
    })).json()

    let result = []
    for (let i = 0; i < posts.length; i++) {
        let post = ParsePostJSON(posts[i])
        if (post != null)
            result.push(post)
    }
    return JSON.stringify(result)
}

async function GetUserFavorites({page = 1, limit = 20, username = "", auth = ""}) {
    return await GetPosts({page: page, limit: limit, search: `ordfav:${username}`, auth: auth})
}

async function GetPostChildren({id = 0, auth = ""}) {
    return await GetPosts({page: 1, limit: 200, search: `parent:${id} -id:${id}`, auth: auth})
}

// Page is not included, since having page switching for a 
// tag search bar is too cumbersome...
async function GetTagSuggestion({search = "", limit = 20}) {
    let tags = await (await fetch(url({
        base: Extension.base_url,
        path: "tags.json",
        query: [
            { "search[name_matches]": `${search}*` },
            { "limit": limit },
            { "search[order]": "count" }
        ]
    }), {
        method: "GET",
        headers: {
            "Content-Type": "application/json",
            "User-Agent": UserAgent
        }
    })).json()

    let result = []
    for (let i = 0; i < tags.length; i++) {
        let tag = ParseTagJSON(tags[i])
        if (tag != null)
            result.push(tag)
    }
    return JSON.stringify(result)
}