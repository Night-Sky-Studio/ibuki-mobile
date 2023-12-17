const UserAgent = "IbukiMobile/1.0.0 Ibuki/1.0.0 (Night Sky Studio)"
function url(t) {
    let e = ""
    if ((t.base && ((e += t.base), t.base.endsWith("/") || (e += "/")), t.path && (t.path.startsWith("/") ? (e += t.path.substring(1)) : (e += t.path), t.path.endsWith("/") && (e = e.substring(0, e.length - 1))), t.query)) {
        for (let s of ((e += "?"), t.query)) {
            let n = Object.entries(s)[0];
            "" !== n[1] && (e += n[0] + "=" + n[1] + "&");
        }
        e = e.substring(0, e.length - 1);
    }
    return e
}
function fetch(url, options) {
	options = options || {
        method: "GET"
    };
	return new Promise(async (resolve, reject) => {
        let request = await sendMessage("fetch", JSON.stringify({"url": url, "options": options}))

        const response = () => ({
            ok: ((request.status / 100) | 0) == 2, // 200-299
            statusText: request.statusText,
            status: request.status,
            url: request.responseURL,
            text: () => Promise.resolve(request.responseText),
            json: () => Promise.resolve(request.responseText).then(JSON.parse),
            blob: () => Promise.resolve(new Blob([request.response])),
            clone: response,
            headers: request.headers,
        })

        if (request.ok) resolve(response());
        else reject(response());
        
	});
}