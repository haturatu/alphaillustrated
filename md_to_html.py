import markdown
import sys
import os

if len(sys.argv) < 3:
    print("Usage: python md_to_html.py <input_file> <output_file>")
    sys.exit(1)

input_file = sys.argv[1]
output_file = sys.argv[2]

# Derive title from filename
title = os.path.splitext(os.path.basename(input_file))[0].replace('-', ' ').title()

# Determine language from path
lang = os.path.basename(os.path.dirname(input_file))

with open(input_file, 'r', encoding='utf-8') as f:
    text = f.read()
    body_html = markdown.markdown(text)

with open('templates/article.html', 'r', encoding='utf-8') as f:
    template = f.read()

html_content = template.replace('__TITLE__', title)
html_content = html_content.replace('__BODY__', body_html)
html_content = html_content.replace('__LANG__', lang)


with open(output_file, 'w', encoding='utf-8') as f:
    f.write(html_content)
