#!/bin/bash

set -e

# conf
TEMPLATE_DIR="templates"
LANGUAGES=("en" "ja")

pip show markdown > /dev/null || {
    echo "Installing markdown library..."
    pip install markdown
}

# Function to process a language directory
process_lang() {
    local lang=$1
    local html_dir="$lang/html"
    local article_links=""

    echo "Processing language: $lang"

    # Create html directory if it doesn't exist
    mkdir -p "$html_dir"

    # Convert all .md files to .html
    for file in "$lang"/*.md; do
        filename=$(basename "$file" .md)
        python md_to_html.py "$file" "$html_dir/$filename.html"
    done

    # Copy style.css
    cp "$TEMPLATE_DIR/style.css" "$html_dir/"

    # Generate article links for the language index
    for file in "$html_dir"/*.html; do
        if [ "$(basename "$file")" != "index.html" ]; then
            filename=$(basename "$file")
            title=$(echo "$filename" | sed 's/\.html//; s/-/ /g; s/\b\(.\)/\u\1/g')
            article_links+="        <li><a href=\"$filename\">$title</a></li>\n"
        fi
    done

    # Generate index.html for the language from template
    sed -e "s/__LANG__/$lang/g" \
        -e "/__ARTICLE_LINKS__/c\\$article_links" \
        "$TEMPLATE_DIR/lang_index.html" > "$html_dir/index.html"

    echo "Generated $html_dir/index.html"
}

generate_root_index() {
    echo "Generating root index.html..."
    local lang_links=""

    # Generate language links
    lang_links+="        <li><a href=\"en/html/index.html\">English</a></li>\n"
    lang_links+="        <li><a href=\"ja/html/index.html\">日本語</a></li>\n"

    # Copy style.css for the root
    cp "$TEMPLATE_DIR/style.css" "./"

    # Generate root index.html from template
    sed -e "/__LANG_LINKS__/c\\$lang_links" \
        "$TEMPLATE_DIR/index.html" > "index.html"

    echo "Generated root index.html"
}

for lang in "${LANGUAGES[@]}"; do
    process_lang "$lang"
done

generate_root_index

echo "Build finished."
