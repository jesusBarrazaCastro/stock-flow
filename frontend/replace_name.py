import os
import sys

def replace_in_file(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
    except UnicodeDecodeError:
        return # Skip binary files

    new_content = content.replace("deteccion_placas", "stock_flow")
    new_content = new_content.replace("DeteccionPlacas", "StockFlow")
    new_content = new_content.replace("Deteccion Placas", "Stock Flow")
    new_content = new_content.replace("deteccion-placas", "stock-flow")

    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated {filepath}")

def process_directory(directory):
    for root, dirs, files in os.walk(directory):
        if '.git' in dirs:
            dirs.remove('.git')
        if 'build' in dirs:
            dirs.remove('build')
        if '.dart_tool' in dirs:
            dirs.remove('.dart_tool')
        
        for file in files:
            filepath = os.path.join(root, file)
            replace_in_file(filepath)

if __name__ == "__main__":
    process_directory("/Users/jesusbarraza/GitHub/stock-flow/frontend/deteccion_placas")
