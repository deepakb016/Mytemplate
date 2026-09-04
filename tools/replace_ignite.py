#!/usr/bin/env python3
"""
Replace occurrences of 'MyTemplate' (case-insensitive) with 'MyTemplate' in text files.

Usage: python tools/replace_MyTemplate.py
"""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
PAT = re.compile(r'MyTemplate', re.IGNORECASE)

TEXT_EXTS = {
    '.py', '.md', '.txt', '.html', '.htm', '.svg', '.json', '.yml', '.yaml',
    '.cfg', '.ini', '.js', '.css', '.scss', '.lock', '.toml', '.rst'
}

def is_text_file(p: Path):
    if p.suffix.lower() in TEXT_EXTS:
        return True
    try:
        raw = p.read_bytes()
        raw.decode('utf-8')
        return True
    except Exception:
        return False

def replace_in_file(p: Path):
    try:
        s = p.read_text(encoding='utf-8')
    except Exception:
        return False
    if not PAT.search(s):
        return False
    new = PAT.sub('MyTemplate', s)
    if new != s:
        p.write_text(new, encoding='utf-8')
        print(f'Updated: {p}')
        return True
    return False

def main():
    changed = 0
    for p in ROOT.rglob('*'):
        if p.is_file():
            # Skip virtual envs, git, node_modules, .venv, and binary files
            if any(part in ('node_modules', '.git', '.venv', 'env', 'venv') for part in p.parts):
                continue
            if is_text_file(p):
                if replace_in_file(p):
                    changed += 1
    print(f'Done. Files changed: {changed}')

if __name__ == '__main__':
    main()
