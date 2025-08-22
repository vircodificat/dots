#!/usr/bin/env python3

import sys
import os
import subprocess
from pathlib import Path
import glob
import shutil

grammars = {
    'zig':  'https://github.com/tree-sitter-grammars/tree-sitter-zig',
    'rust':  'https://github.com/tree-sitter/tree-sitter-rust',
    'python':  'https://github.com/tree-sitter/tree-sitter-python',
    'javascript':  'https://github.com/tree-sitter/tree-sitter-python',
}

outputs = []

PROJECTS = os.environ['PROJECTS']

treesitter_dir = Path(f'{PROJECTS}/treesitter')
subprocess.run(['mkdir', '-p', str(treesitter_dir)])
os.chdir(treesitter_dir)

for language, repo_url in grammars.items():
    print("Building", language)

    language_dir = Path(f'{PROJECTS}/treesitter/{language}')
    if not language_dir.exists():
        subprocess.run(['git', 'clone', repo_url, language])
    os.chdir(language_dir)

    try:
        subprocess.run(['git', 'clean', '-xdf'])
        subprocess.run(['tree-sitter', 'generate'])
        subprocess.run(['tree-sitter', 'build', '-o', f'{language}.so'])
        subprocess.run(['tree-sitter', 'build', '-w', '-o', f'{language}.wasm'])

    except:
        print("Failed", file=sys.stderr)

    for output in glob.glob('*.so'):
        outputs.append(Path(output).absolute())

    for output in glob.glob('*.wasm'):
        outputs.append(Path(output).absolute())

    os.chdir(treesitter_dir)

subprocess.run(['mkdir', '-p', 'build'])

for output in outputs:
    shutil.copy(output, 'build/')
