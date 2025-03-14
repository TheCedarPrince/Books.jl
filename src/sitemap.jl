"""
    ids_texts2links(id_texts)

Return a vector of links for a vector of `id_texts`.
"""
ids_texts2links(id_texts) = getproperty.(id_texts, :id)

function html_loc(online_url, online_url_prefix, link; suffix=html_suffix())
    loc = "$(online_url)/$(online_url_prefix)/$(link)$suffix"
    loc = replace(loc, "///" => "/")
    loc = replace(loc, "//" => "/")
    loc = replace(loc, "https:/" => "https://")
    return loc
end

function html_loc(project, link; suffix=html_suffix())
    online_url = string(config(project, "online_url"))::String
    online_url_prefix = string(config(project, "online_url_prefix"))::String
    return html_loc(online_url, online_url_prefix, link; suffix)
end

function sitemap_entry(loc)
    day = string(today())::String
    return """
        <url>
            <loc>$loc</loc>
            <lastmod>$day</lastmod>
            <changefreq>monthly</changefreq>
        </url>
        """
end

"""
    sitemap(project, h)

Write a sitemap to "sitemap.xml" for html `h`.
"""
function sitemap(project, h)
    head, bodies, foot = split_html(h)
    ids_texts = html_page_name.(bodies)

    links = ids_texts2links(ids_texts)
    locs = html_loc.(project, links)
    entries = sitemap_entry.(locs)
    text = join(entries, '\n')
    text = """
        <?xml version="1.0" encoding="UTF-8"?>
        <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
        $text
        </urlset>
        """
    path = joinpath(BUILD_DIR, "sitemap.xml")
    write(path, text)
    return text
end

