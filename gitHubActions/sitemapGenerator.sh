#!/bin/bash

# Sitemap generator script
# Merges static.xml with dynamically generated article URLs

set -e  # Exit on any error

# Configuration
STATIC_SITEMAP="static.xml"
OUTPUT_SITEMAP="sitemap.xml"
LIST_JSON="generated-data/list.json"
BASE_URL="https://yourdomain.com"  # Replace with your actual domain
ARTICLES_BASE_PATH="generated-data/articles"

echo "🚀 Generating sitemap..."

# Check if static.xml exists
if [[ ! -f "$STATIC_SITEMAP" ]]; then
    echo "❌ Error: $STATIC_SITEMAP not found!"
    exit 1
fi

# Check if list.json exists
if [[ ! -f "$LIST_JSON" ]]; then
    echo "❌ Error: $LIST_JSON not found!"
    exit 1
fi

# Start building the new sitemap
echo "📝 Reading static sitemap..."

# Extract everything from static.xml except the closing </urlset> tag
sed '/<\/urlset>/d' "$STATIC_SITEMAP" > temp_sitemap.xml

echo "📊 Processing articles from list.json..."

# Parse list.json and generate URLs for articles
python3 << 'EOF'
import json
import sys
import os
from datetime import datetime

try:
    # Read and parse list.json
    with open('generated-data/list.json', 'r', encoding='utf-8') as f:
        articles = json.load(f)
    
    base_url = os.environ.get('BASE_URL', 'https://yourdomain.com')
    
    for article in articles:
        article_id = article.get('id', '')
        date = article.get('date', '')
        slug = article.get('slug', '')  # Use slug if available
        status = article.get('status', 'published')
        
        # Skip everything not marked as 'published'
        if status != 'published':
            continue
            
        if not article_id:
            continue
            
        # Build URL - use slug if available, otherwise use the HTML file path
        if slug:
            url = f"{base_url}/{slug}"
        else:
            url = f"{base_url}/generated-data/articles/{article_id}/{article_id}.html"
        
        # Parse date for lastmod
        lastmod = date if date else datetime.now().strftime('%Y-%m-%d')
        
        # Generate sitemap entry
        print(f"""  <url>
    <loc>{url}</loc>
    <lastmod>{lastmod}</lastmod>
    <changefreq>monthly</changefreq>
    <priority>0.7</priority>
  </url>""")

except Exception as e:
    print(f"Error processing articles: {e}", file=sys.stderr)
    sys.exit(1)
EOF

# Check if Python script succeeded
if [[ $? -ne 0 ]]; then
    echo "❌ Error processing articles"
    rm -f temp_sitemap.xml
    exit 1
fi

# Close the sitemap
echo "</urlset>" >> temp_sitemap.xml

# Move temp file to final location
mv temp_sitemap.xml "$OUTPUT_SITEMAP"

# Validate XML (basic check)
if command -v xmllint >/dev/null 2>&1; then
    echo "🔍 Validating XML..."
    if xmllint --noout "$OUTPUT_SITEMAP" 2>/dev/null; then
        echo "✅ XML validation passed"
    else
        echo "⚠️  XML validation failed, but continuing..."
    fi
fi

# Count URLs in final sitemap
URL_COUNT=$(grep -c "<loc>" "$OUTPUT_SITEMAP" || echo "0")
echo "📈 Generated sitemap with $URL_COUNT URLs"

# Display file size
FILESIZE=$(ls -lh "$OUTPUT_SITEMAP" | awk '{print $5}')
echo "📁 Sitemap size: $FILESIZE"

echo "✅ Sitemap generated successfully: $OUTPUT_SITEMAP"

# Optional: Display first few URLs for verification
echo ""
echo "📋 Sample URLs from sitemap:"
grep "<loc>" "$OUTPUT_SITEMAP" | head -5 | sed 's/.*<loc>\(.*\)<\/loc>.*/  - \1/'
if [[ $URL_COUNT -gt 5 ]]; then
    echo "  ... and $((URL_COUNT - 5)) more"
fi