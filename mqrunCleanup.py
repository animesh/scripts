#python mqrunCleanup.py --yes mqpar.xml.17951199??.results
#rsync -Parv mqpar.xml.17951199*  /nird/datapeak/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/Animesh/Miriam/.

import argparse
from concurrent.futures import ThreadPoolExecutor, as_completed
import glob
import os
import shutil
import stat
import sys
from typing import Dict, List, Set, Tuple


def expand_targets(raw_targets: List[str]) -> List[str]:
    """Expand any literal glob patterns and deduplicate target directories."""
    seen: Set[str] = set()
    roots: List[str] = []

    for raw in raw_targets:
        matches = sorted(glob.glob(raw)) if glob.has_magic(raw) else [raw]
        if not matches:
            print(f"Warning: target matched nothing: {raw}", file=sys.stderr)
            continue
        for match in matches:
            abs_path = os.path.abspath(match)
            if not os.path.isdir(abs_path) or os.path.islink(abs_path):
                print(
                    f"Warning: skipping non-directory target: {match}",
                    file=sys.stderr,
                )
                continue
            if abs_path in ("/", os.path.abspath(os.path.expanduser("~"))):
                raise ValueError(f"Refusing to operate on unsafe root: {abs_path}")
            if abs_path not in seen:
                seen.add(abs_path)
                roots.append(abs_path)

    return roots


def scan_plan(
    roots: List[str], keep_names: Set[str]
) -> Tuple[Set[str], Set[str], Dict[str, int], List[str], List[str]]:
    """Scan target roots and build the exact preservation and deletion plan."""
    keep_leaf_dirs: Set[str] = set()
    keep_ancestor_dirs: Set[str] = set()
    kept_file_counts: Dict[str, int] = {}

    for root in roots:
        keep_ancestor_dirs.add(root)
        for dirpath, dirnames, _ in os.walk(root, topdown=True, followlinks=False):
            matched = []
            for d in dirnames:
                if d in keep_names:
                    full = os.path.join(dirpath, d)
                    if not os.path.islink(full):
                        keep_leaf_dirs.add(full)
                        matched.append(d)
                        cur = full
                        while True:
                            keep_ancestor_dirs.add(cur)
                            if cur == root:
                                break
                            cur = os.path.dirname(cur)
                        count = 0
                        for _, _, tfiles in os.walk(full, followlinks=False):
                            count += len(tfiles)
                        kept_file_counts[full] = count
            for d in matched:
                dirnames.remove(d)

    files_to_delete: List[str] = []
    dirs_to_delete: List[str] = []

    for root in roots:
        for dirpath, dirnames, filenames in os.walk(
            root, topdown=True, followlinks=False
        ):
            if dirpath in keep_leaf_dirs:
                dirnames[:] = []
                continue

            for f in sorted(filenames):
                files_to_delete.append(os.path.join(dirpath, f))

            next_dirnames = []
            for d in sorted(dirnames):
                dp = os.path.join(dirpath, d)
                if dp in keep_leaf_dirs:
                    continue
                elif dp in keep_ancestor_dirs:
                    next_dirnames.append(d)
                else:
                    dirs_to_delete.append(dp)
            dirnames[:] = next_dirnames

    return (
        keep_leaf_dirs,
        keep_ancestor_dirs,
        kept_file_counts,
        files_to_delete,
        dirs_to_delete,
    )


def is_protected(
    path: str,
    keep_leaf_dirs: Set[str],
    keep_ancestor_dirs: Set[str],
    keep_names: Set[str],
) -> bool:
    """Defensive guard ensuring no kept folder, its contents, or ancestors can be deleted."""
    if path in keep_ancestor_dirs or path in keep_leaf_dirs:
        return True
    if (
        os.path.basename(path) in keep_names
        and os.path.isdir(path)
        and not os.path.islink(path)
    ):
        return True
    cur = os.path.dirname(path)
    while cur and cur != os.path.dirname(cur):
        if cur in keep_leaf_dirs:
            return True
        cur = os.path.dirname(cur)
    return False


def display_path(path: str, cwd: str) -> str:
    """Format path relative to cwd when inside cwd, otherwise absolute."""
    try:
        rel = os.path.relpath(path, cwd)
        if not rel.startswith(".."):
            return rel
    except ValueError:
        pass
    return path


def handle_remove_readonly(func, path, exc_info):
    os.chmod(path, stat.S_IRWXU)
    func(path)


def execute_deletions(
    files_to_delete: List[str],
    dirs_to_delete: List[str],
    keep_leaf_dirs: Set[str],
    keep_ancestor_dirs: Set[str],
    keep_names: Set[str],
    workers: int,
) -> List[str]:
    """Delete scheduled files and directory subtrees with safety assertions."""
    for fp in files_to_delete:
        assert not is_protected(
            fp, keep_leaf_dirs, keep_ancestor_dirs, keep_names
        ), f"Refusing to delete protected file: {fp}"
    for dp in dirs_to_delete:
        assert not is_protected(
            dp, keep_leaf_dirs, keep_ancestor_dirs, keep_names
        ), f"Refusing to delete protected directory: {dp}"

    def delete_file(fp: str) -> None:
        os.unlink(fp)

    def delete_dir(dp: str) -> None:
        if os.path.islink(dp):
            os.unlink(dp)
        else:
            shutil.rmtree(dp, onerror=handle_remove_readonly)

    errors: List[str] = []
    total = len(files_to_delete) + len(dirs_to_delete)
    if total == 0:
        return errors

    with ThreadPoolExecutor(max_workers=max(1, workers)) as executor:
        futures = [executor.submit(delete_file, fp) for fp in files_to_delete]
        futures += [executor.submit(delete_dir, dp) for dp in dirs_to_delete]
        done = 0
        for fut in as_completed(futures):
            done += 1
            try:
                fut.result()
            except Exception as exc:
                errors.append(str(exc))
            if done % 500 == 0 or done == total:
                print(
                    f"Progress: {done}/{total} items deleted (errors: {len(errors)})",
                    flush=True,
                )

    return errors


def verify_post_state(
    roots: List[str],
    keep_leaf_dirs: Set[str],
    keep_ancestor_dirs: Set[str],
    kept_file_counts: Dict[str, int],
) -> bool:
    """Verify every kept folder and its file count is intact, with zero stray items."""
    found_leaf_dirs: Set[str] = set()
    mismatched_counts: List[str] = []
    stray_files: List[str] = []
    stray_dirs: List[str] = []

    for root in roots:
        for dirpath, dirnames, filenames in os.walk(
            root, topdown=True, followlinks=False
        ):
            if dirpath in keep_leaf_dirs:
                found_leaf_dirs.add(dirpath)
                actual_count = len(filenames)
                for sub_dp, _, sub_files in os.walk(dirpath, followlinks=False):
                    if sub_dp != dirpath:
                        actual_count += len(sub_files)
                expected_count = kept_file_counts[dirpath]
                if actual_count != expected_count:
                    mismatched_counts.append(
                        f"{dirpath}: expected {expected_count} files, found {actual_count}"
                    )
                dirnames[:] = []
                continue

            for f in filenames:
                stray_files.append(os.path.join(dirpath, f))
            for d in dirnames:
                dp = os.path.join(dirpath, d)
                if dp not in keep_ancestor_dirs:
                    stray_dirs.append(dp)

    missing_leaf_dirs = sorted(keep_leaf_dirs - found_leaf_dirs)
    ok = (
        not missing_leaf_dirs
        and not mismatched_counts
        and not stray_files
        and not stray_dirs
    )

    total_expected_files = sum(kept_file_counts.values())
    print("\n=== VERIFICATION ===")
    print(f"Kept folders intact : {len(found_leaf_dirs)}/{len(keep_leaf_dirs)}")
    print(f"Kept files expected : {total_expected_files}")
    print(f"Stray files outside : {len(stray_files)}")
    print(f"Stray dirs outside  : {len(stray_dirs)}")

    if missing_leaf_dirs:
        print("ERROR - Missing kept folders:", file=sys.stderr)
        for p in missing_leaf_dirs[:20]:
            print(f"  {p}", file=sys.stderr)
    if mismatched_counts:
        print("ERROR - File count mismatches in kept folders:", file=sys.stderr)
        for msg in mismatched_counts[:20]:
            print(f"  {msg}", file=sys.stderr)
    if stray_files:
        print("ERROR - Stray files remaining:", file=sys.stderr)
        for p in stray_files[:20]:
            print(f"  {p}", file=sys.stderr)
    if stray_dirs:
        print("ERROR - Stray directories remaining:", file=sys.stderr)
        for p in stray_dirs[:20]:
            print(f"  {p}", file=sys.stderr)

    return ok


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Print everything to be preserved and deleted inside target directories, "
            "keeping only folders with the specified name (default: 'txt') and their "
            "contents, then execute the cleanup."
        )
    )
    parser.add_argument(
        "targets",
        nargs="+",
        help="Target directories or glob patterns (e.g. mqpar.xml.17951199??.results).",
    )
    parser.add_argument(
        "--keep-dir",
        action="append",
        dest="keep_dirs",
        help="Directory name to preserve (can be repeated; default: txt).",
    )
    parser.add_argument(
        "-n",
        "--dry-run",
        action="store_true",
        help="Print what would be preserved and deleted, then exit without deleting.",
    )
    parser.add_argument(
        "-y",
        "--yes",
        action="store_true",
        help="Skip interactive confirmation prompt and execute immediately after printing.",
    )
    parser.add_argument(
        "--workers",
        type=int,
        default=8,
        help="Number of parallel threads for deletion (default: 8).",
    )
    parser.add_argument(
        "--no-verify",
        action="store_true",
        help="Skip post-deletion verification check.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    keep_names = set(args.keep_dirs) if args.keep_dirs else {"txt"}
    cwd = os.getcwd()

    try:
        roots = expand_targets(args.targets)
    except ValueError as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 1

    if not roots:
        print("Error: no valid target directories found.", file=sys.stderr)
        return 1

    (
        keep_leaf_dirs,
        keep_ancestor_dirs,
        kept_file_counts,
        files_to_delete,
        dirs_to_delete,
    ) = scan_plan(roots, keep_names)

    print("=== TARGET ROOTS ===")
    for r in roots:
        print(f"  {display_path(r, cwd)}")

    print(
        f"\n=== TO BE PRESERVED ({len(keep_leaf_dirs)} folders, "
        f"{sum(kept_file_counts.values())} files inside) ==="
    )
    if keep_leaf_dirs:
        for kp in sorted(keep_leaf_dirs):
            print(f"  [KEEP] {display_path(kp, cwd)}/ ({kept_file_counts[kp]} files)")
    else:
        print("  (none)")

    total_delete = len(files_to_delete) + len(dirs_to_delete)
    print(
        f"\n=== TO BE DELETED ({len(dirs_to_delete)} directories, "
        f"{len(files_to_delete)} files) ==="
    )
    if total_delete:
        for dp in sorted(dirs_to_delete):
            suffix = " (symlink)" if os.path.islink(dp) else "/"
            print(f"  [DEL DIR]  {display_path(dp, cwd)}{suffix}")
        for fp in sorted(files_to_delete):
            print(f"  [DEL FILE] {display_path(fp, cwd)}")
    else:
        print("  (none)")

    print("\n=== SUMMARY ===")
    print(f"  Keep folders ({', '.join(sorted(keep_names))}) : {len(keep_leaf_dirs)}")
    print(f"  Keep files inside    : {sum(kept_file_counts.values())}")
    print(f"  Delete directories   : {len(dirs_to_delete)}")
    print(f"  Delete files         : {len(files_to_delete)}")

    if total_delete == 0:
        print("\nNothing to delete.")
        return 0

    if args.dry_run:
        print("\nDry run complete; nothing was deleted.")
        return 0

    if not args.yes:
        if not sys.stdin.isatty():
            print(
                "\nRefusing to delete in non-interactive mode without --yes.",
                file=sys.stderr,
            )
            return 2
        try:
            answer = input("\nProceed with permanent deletion? [y/N]: ").strip().lower()
        except (EOFError, KeyboardInterrupt):
            print("\nAborted.")
            return 130
        if answer not in ("y", "yes"):
            print("Aborted; nothing was deleted.")
            return 0

    print("\n=== EXECUTING DELETION ===", flush=True)
    errors = execute_deletions(
        files_to_delete=files_to_delete,
        dirs_to_delete=dirs_to_delete,
        keep_leaf_dirs=keep_leaf_dirs,
        keep_ancestor_dirs=keep_ancestor_dirs,
        keep_names=keep_names,
        workers=args.workers,
    )

    if errors:
        print(f"\nCompleted with {len(errors)} error(s):", file=sys.stderr)
        for err in errors[:20]:
            print(f"  {err}", file=sys.stderr)
        return 1

    if not args.no_verify:
        ok = verify_post_state(
            roots, keep_leaf_dirs, keep_ancestor_dirs, kept_file_counts
        )
        if not ok:
            print("\nVERIFICATION FAILED.", file=sys.stderr)
            return 1
        print("CLEANUP VERIFIED SUCCESSFULLY.")

    return 0


if __name__ == "__main__":
    sys.exit(main())
