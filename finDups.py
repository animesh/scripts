#!/usr/bin/env python3
"""
Fast duplicate file finder.
Scans a start directory (default $HOME), groups files by size, hashes files with same size
using xxhash if available (falls back to sha1), and writes a CSV of duplicate files
(sorted by size descending).

Output CSV columns: group_id,hash,size,duplicate_count,path
Only files that belong to a duplicate group (count>1) are written.
"""
import os
import argparse
import csv
import hashlib
from collections import defaultdict

try:
    import xxhash
    def new_hasher():
        return xxhash.xxh64()
    HASH_NAME = 'xxh64'
except Exception:
    def new_hasher():
        return hashlib.sha1()
    HASH_NAME = 'sha1'

CHUNK = 4 * 1024 * 1024


def hash_file(path):
    h = new_hasher()
    try:
        with open(path, 'rb') as f:
            while True:
                chunk = f.read(CHUNK)
                if not chunk:
                    break
                h.update(chunk)
        # xxhash and hashlib objects have different interfaces for hexdigest
        if HASH_NAME == 'xxh64':
            return h.hexdigest()
        else:
            return h.hexdigest()
    except Exception as e:
        return None


def scan(start_path):
    # Map size -> list of paths
    sizes = defaultdict(list)
    for root, dirs, files in os.walk(start_path, followlinks=False):
        for name in files:
            path = os.path.join(root, name)
            try:
                if not os.path.islink(path) and os.path.isfile(path):
                    size = os.path.getsize(path)
                    sizes[size].append(path)
            except Exception:
                continue
    return sizes


def main():
    p = argparse.ArgumentParser(description='Find duplicate files under a directory')
    p.add_argument('--start', '-s', default=os.path.expanduser('~'), help='Start directory (default $HOME)')
    p.add_argument('--output', '-o', default=os.path.expanduser('~/duplicate_files.csv'), help='Output CSV path')
    p.add_argument('--min-size', type=int, default=1, help='Minimum file size in bytes to consider')
    args = p.parse_args()

    start = os.path.abspath(os.path.expanduser(args.start))
    out = os.path.abspath(os.path.expanduser(args.output))

    print(f"Scanning {start} by size (this may take a while)...")
    sizes = scan(start)
    print(f"Found {sum(len(v) for v in sizes.values())} files across {len(sizes)} distinct sizes")

    # For sizes with more than 1 file, compute hashes
    groups = defaultdict(list)  # (size,hash) -> list of paths
    total_candidates = 0
    for size, paths in sizes.items():
        if size < args.min_size:
            continue
        if len(paths) < 2:
            continue
        total_candidates += len(paths)
        for path in paths:
            h = hash_file(path)
            if h is None:
                continue
            groups[(size, h)].append(path)

    # Build rows for duplicate groups only
    rows = []
    group_id = 0
    for (size, h), paths in groups.items():
        if len(paths) < 2:
            continue
        group_id += 1
        dup_count = len(paths)
        for pth in paths:
            rows.append({'group_id': group_id, 'hash': h, 'size': size, 'duplicate_count': dup_count, 'path': pth})

    # Sort rows by size desc
    rows.sort(key=lambda r: r['size'], reverse=True)

    # Write CSV
    os.makedirs(os.path.dirname(out), exist_ok=True)
    with open(out, 'w', newline='') as cf:
        writer = csv.DictWriter(cf, fieldnames=['group_id', 'hash', 'size', 'duplicate_count', 'path'])
        writer.writeheader()
        for r in rows:
            writer.writerow(r)

    print(f"Wrote {len(rows)} duplicate-file rows to {out}")
    print(f"Hash algorithm used: {HASH_NAME}")

if __name__ == '__main__':
    main()
