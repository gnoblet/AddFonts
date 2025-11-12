"""
Simple script to create a database of all fonts from fonts.bunny.net
Fetches the font list from Bunny's list and saves to a JSON database.

Usage:
    uv run scripts/create_font_db_bunny.py
"""

import argparse
import json
from datetime import datetime
from pathlib import Path
import requests


def fetch_bunny_fonts():
    """Fetch all fonts from Bunny Fonts API"""
    print("Fetching fonts from Bunny Fonts API...")

    # Bunny Fonts public API endpoint (returns fonts as an object keyed by font ID)
    api_url = "https://fonts.bunny.net/list"

    try:
        response = requests.get(api_url, timeout=30)
        response.raise_for_status()
        return response.json()
    except requests.RequestException as e:
        print(f"Error fetching fonts: {e}")
        return None


def create_font_database(output_file="data-raw/fonts_db_bunny.json"):
    """Create a JSON database of all Bunny Fonts"""

    # Fetch fonts from API
    fonts_data = fetch_bunny_fonts()

    if not fonts_data:
        print("Failed to fetch fonts data")
        return

    # The API returns fonts as an object with font IDs as keys
    # Convert to a list format for easier querying
    fonts = []

    for font_id, family_info in fonts_data.items():
        # Get variant count (sum of all subset variants)
        variant_counts = family_info.get("variants", {})
        total_variants = (
            sum(variant_counts.values()) if isinstance(variant_counts, dict) else 0
        )

        font_entry = {
            "family": font_id,  # URL-safe ID (e.g., "open-sans")
            "familyName": family_info.get("familyName", font_id),  # Display name
            "category": family_info.get("category", ""),
            "variants": variant_counts,  # Dict of subset: count
            "weights": family_info.get("weights", []),
            "styles": family_info.get("styles", []),
            "defSubset": family_info.get("defSubset", "latin"),
            "isVariable": family_info.get("isVariable", False),
            "url": f"https://fonts.bunny.net/family/{font_id}",
        }
        fonts.append(font_entry)

    # Sort by display name for easier browsing
    fonts.sort(key=lambda x: x["familyName"].lower())

    # Create database structure
    database = {
        "generated": datetime.utcnow().isoformat() + "Z",
        "source": "https://fonts.bunny.net/",
        "api_endpoint": "https://fonts.bunny.net/list",
        "count": len(fonts),
        "fonts": fonts,
    }

    # Save to file
    output_path = Path(output_file)
    output_path.parent.mkdir(parents=True, exist_ok=True)

    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(database, f, indent=2, ensure_ascii=False)

    print(f"✓ Created database with {len(fonts)} fonts")
    print(f"✓ Saved to: {output_path.absolute()}")

    # Print some stats
    categories = {}
    total_variants = 0
    variable_fonts = 0

    for font in fonts:
        cat = font.get("category", "unknown")
        categories[cat] = categories.get(cat, 0) + 1

        # Sum up variant counts
        variants = font.get("variants", {})
        if isinstance(variants, dict):
            total_variants += sum(variants.values())

        if font.get("isVariable", False):
            variable_fonts += 1

    print(f"\nTotal font variants: {total_variants}")
    print(f"Variable fonts: {variable_fonts}")
    print("\nFont categories:")
    for cat, count in sorted(categories.items(), key=lambda x: x[1], reverse=True):
        print(f"  {cat}: {count}")


def main():
    parser = argparse.ArgumentParser(
        description="Create a database of all fonts from Bunny Fonts"
    )
    parser.add_argument(
        "--output",
        "-o",
        default="data-raw/fonts_db_bunny.json",
        help="Output JSON file path (default: data-raw/fonts_db_bunny.json)",
    )

    args = parser.parse_args()
    create_font_database(args.output)


if __name__ == "__main__":
    main()
