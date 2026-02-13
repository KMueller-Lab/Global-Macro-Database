import re
import pandas as pd
import os

def parse_bib_entry(entry_text):
    """
    Parses a single BibTeX entry text into a dictionary.
    """
    # Extract type and key
    # @type{KEY,
    match_start = re.match(r'@\w+\s*{\s*([^,]+),', entry_text)
    if not match_start:
        return None
    
    key = match_start.group(1).strip()
    
    # Extract fields
    # Simple regex for field = {value} or field = "value" or field = value
    fields = {}
    
    # Remove the first line (@type{KEY,) and the last line (})
    lines = entry_text.split('\n')
    if len(lines) > 2:
        # body without first and last line (roughly)
        pass 
    
    # Better approach for this specific clean file:
    # Iterate lines
    for line in lines[1:]:
        line = line.strip()
        if not line or line == '}':
            continue
            
        # Check if line starts with a field key
        # pattern: key = ...
        key_match = re.match(r'^(\w+)\s*=\s*(.*)', line)
        if key_match:
            k = key_match.group(1).lower()
            v = key_match.group(2)
            
            # Clean value
            # Remove trailing comma
            if v.endswith(','):
                v = v[:-1]
            
            # Remove enclosing braces or quotes
            v = v.strip()
            # Handle {Value} or "Value"
            if (v.startswith('{') and v.endswith('}')) or (v.startswith('"') and v.endswith('"')):
                v = v[1:-1]
                
            # Further clean double braces {{ ... }} -> ...
            if v.startswith('{') and v.endswith('}'):
                v = v[1:-1]
                
            fields[k] = v
            
    return key, fields

def format_citation(fields):
    """
    Formats a citation string from fields.
    Format: Author (Year). Title.
    """
    author = fields.get('author', '')
    year = fields.get('year', '')
    title = fields.get('title', '')
    institution = fields.get('institution', '')
    
    # Clean author
    # Remove braces
    author = author.replace('{', '').replace('}', '')
    
    if not author and institution:
        author = institution.replace('{', '').replace('}', '')
        
    citation_parts = []
    if author:
        citation_parts.append(f"{author}")
    if year:
        citation_parts.append(f"({year})")
    if title:
        # Remove braces from title
        title = title.replace('{', '').replace('}', '')
        citation_parts.append(f"{title}")
        
    citation = ". ".join(citation_parts)
    if citation and not citation.endswith('.'):
        citation += "."
        
    return citation

def main():
    bib_file = 'paper.bib'
    
    if not os.path.exists(bib_file):
        print(f"Error: File not found at {bib_file}")
        return

    with open(bib_file, 'r') as f:
        content = f.read()
        
    # Split entries by @
    # This is a heuristic: assumes entries start with @ at the beginning of a line (or after newline)
    raw_entries = re.split(r'\n@', '\n' + content)
    
    data = []
    
    for entry in raw_entries:
        if not entry.strip():
            continue
            
        # Re-add the @ that was split (regex split consumes delimiter mostly, but here capturing group isn't used)
        # re.split consumes the separator. The newline is common, but strictness varies.
        # If the file starts with @, the first split might be empty.
        
        entry_text = '@' + entry.strip() if not entry.strip().startswith('@') else entry.strip()
        
        result = parse_bib_entry(entry_text)
        if result:
            key, fields = result
            # formatted_cit = format_citation(fields) # Old format
            
            # Use raw bibtex entry as citation, flattened for Stata compatibility
            # Replace all whitespace (including newlines) with single spaces
            flattened_citation = re.sub(r'\s+', ' ', entry_text).strip()
            data.append({'source': key, 'citation': flattened_citation})
            
    df = pd.DataFrame(data)
    print("DataFrame Created. First 5 rows:")
    print(df.head().to_string())
    print(f"\nTotal entries: {len(df)}")
    
    # Save to CSV for user to inspect if they want
    output_path = 'bib_dataframe.csv'
    df.to_csv(output_path, index=False, encoding='utf-8-sig')
    print(f"Saved DataFrame to {output_path}")

if __name__ == "__main__":
    main()
