---
description: Convert GeekNews article to MediaWiki format
argument-hint: 'URL'
---

# GeekNews to MediaWiki Converter

Convert a GeekNews article to MediaWiki format and save it to the Downloads folder.

**GeekNews URL:**
$ARGUMENTS

## Conversion Instructions

1. **Fetch the GeekNews article** from the provided URL using WebFetch
2. **Extract the following information:**
   - Article title
   - Main content/description
   - Original source URL (if available)
   - Comments (if any)
   - Points/votes

3. **Convert to MediaWiki format** with the following structure:

### Page Title

The article title format is `project_name - project_description`:
- `project_name`: Used as the filename (e.g., `project_name.mediawiki`)
- `project_description`: Used as the MediaWiki page title (e.g., `= project_description =`)

Example: If the article title is "metacode - 액션 코멘트 표준화를 위한 선언적 주석 언어와 파서"
- Filename: `metacode.mediawiki`
- Page Title: `= 액션 코멘트 표준화를 위한 선언적 주석 언어와 파서 =`

### Sections (use `==` for level 2 headers)

**== About ==**
- Include the main article content
- Add author, date, and points information
- Use HTML tags for styling (e.g., `<b>`, `<i>`, `<code>`)
- Include the original article summary/description

**== See also ==**
- Extract technical keywords and concepts mentioned in the article
- Add each keyword as a WikiLink using `[[Keyword]]` format
- Include technologies, programming languages, frameworks, tools, companies, etc.
- Group related keywords if needed

**== Favorite site ==**
- Add the original source URL as an external link: `[URL Link Text]`
- Add the GeekNews discussion URL
- Add any related links mentioned in the article

### Formatting Guidelines
- Headers start from `==` (level 2), never use `=` (level 1) except for the page title
- Use `'''bold'''` for bold text
- Use `''italic''` for italic text
- Use `<code>text</code>` or `<pre>code block</pre>` for code
- Use HTML tags for styling: `<b>`, `<i>`, `<u>`, `<s>`, `<span style="...">`, etc.
- External links: `[http://example.com Link Text]`
- Lists: use `*` for bullets, `#` for numbered lists

4. **Determine the filename:**
   - Extract the article title from the GeekNews page (format: `project_name - project_description`)
   - Use `project_name` as the filename (sanitize if needed, but prefer keeping it simple)
   - Add `.mediawiki` extension
   - Example: "metacode - 액션 코멘트 표준화..." → filename: `metacode.mediawiki`

5. **Save the file:**
   - Detect the OS Downloads folder:
     - Linux: `~/Downloads/` or `$HOME/Downloads/`
     - macOS: `~/Downloads/`
     - Windows: `%USERPROFILE%\Downloads\`
   - Save as `[project_name].mediawiki`
   - Use the Write tool to create the file

6. **Output:**
   - Confirm the file has been saved
   - Show the full path to the saved file
   - Display a preview of the MediaWiki content

## Example MediaWiki Output Structure

For an article titled "metacode - Standardize action annotations":
- Filename: `metacode.mediawiki`
- Content:

```
Standardize action annotations

== About ==

Main article content goes here. Use <b>HTML tags</b> for styling.

The article discusses...

== See also ==
* [[Python]]
* [[Machine Learning]]
* [[Docker]]
* [[Kubernetes]]
* [[PostgreSQL]]

== Favorite site ==
* [https://example.com/original Original Article]
* [https://news.hada.io/topic?id=12345 GeekNews Discussion]
```

## Notes
- Preserve the article's original meaning and structure
- Convert all formatting to valid MediaWiki syntax
- Ensure all URLs are properly formatted as external links
- Handle Korean text properly (no conversion needed)
