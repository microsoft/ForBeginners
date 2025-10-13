#!/usr/bin/env python3
"""
Generate product catalog markdown files from CSV data.
Based on the prompt in products.prompt.md
"""

import csv
import os
import re
from urllib.parse import quote

def sanitize_filename(name):
    """Convert product name to a safe filename"""
    # Remove special characters and spaces, replace with underscores
    filename = re.sub(r'[^\w\s-]', '', name)
    filename = re.sub(r'[-\s]+', '_', filename)
    return filename.lower()

def convert_image_path_to_url(image_path):
    """Convert image path to GitHub raw URL"""
    if not image_path:
        return ""
    
    # URL encode the filename to handle special characters like &
    encoded_filename = quote(image_path, safe='')
    base_url = "https://raw.githubusercontent.com/microsoft/ai-tour-26-zava-diy-dataset-plus-mcp/refs/heads/main/images/"
    return base_url + encoded_filename

def format_price(price):
    """Format price as currency"""
    try:
        return f"${float(price):.2f}"
    except:
        return f"${price}"

def create_product_markdown(product_data):
    """Create markdown content for a product"""
    
    name = product_data['name']
    sku = product_data['sku']
    price = format_price(product_data['price'])
    description = product_data['description']
    stock_level = product_data['stock_level']
    image_url = convert_image_path_to_url(product_data['image_path'])
    main_category = product_data['main_category']
    subcategory = product_data['subcategory']
    
    # Create more descriptive content based on the product info
    markdown_content = f"""# {name}

## Product Overview

**SKU:** {sku}  
**Price:** {price}  
**Category:** {main_category} > {subcategory}  
**Stock Level:** {stock_level} units available  

## Product Image

![{name}]({image_url})

## Description

{description}

## Product Details

This {name.lower()} is part of our {main_category.title()} collection, specifically designed for {subcategory.lower()} applications. 

### Key Features

- **Professional Quality:** Built to meet the demands of both DIY enthusiasts and professional contractors
- **Reliable Performance:** Engineered for consistent results and long-lasting durability
- **Versatile Application:** Suitable for a wide range of {subcategory.lower()} tasks
- **Value Pricing:** Competitive pricing at {price} for exceptional quality

### Availability

- **Current Stock:** {stock_level} units in inventory
- **Product Code:** {sku}
- **Category:** {main_category} / {subcategory}

### Perfect For

This {name.lower()} is ideal for:
- Professional contractors and tradespeople
- DIY home improvement projects  
- Workshop and garage applications
- {main_category.lower()} tasks requiring quality tools

---

*Part of the Zava DIY product catalog - your trusted source for quality {main_category.lower()} supplies.*
"""

    return markdown_content

def main():
    """Main function to process CSV and generate markdown files"""
    
    csv_file = "products.csv"
    output_dir = "products"
    
    # Create output directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)
    
    # Read CSV file and process each product
    with open(csv_file, 'r', newline='', encoding='utf-8') as file:
        reader = csv.DictReader(file)
        
        for row in reader:
            # Create safe filename from product name
            product_name = row['name']
            filename = sanitize_filename(product_name) + '.md'
            filepath = os.path.join(output_dir, filename)
            
            # Generate markdown content
            markdown_content = create_product_markdown(row)
            
            # Write to file
            with open(filepath, 'w', encoding='utf-8') as output_file:
                output_file.write(markdown_content)
            
            print(f"Created: {filepath}")
    
    print(f"\nCompleted! Generated markdown files for all products in the '{output_dir}' directory.")

if __name__ == "__main__":
    main()