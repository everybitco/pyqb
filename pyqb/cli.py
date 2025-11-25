import argparse
import sys
import os
from pyqb.core import Archiver

def main():
    parser = argparse.ArgumentParser(description="Python CLI for qb compression utility")
    subparsers = parser.add_subparsers(dest="command", help="Command to execute")

    # Pack command
    pack_parser = subparsers.add_parser("pack", help="Pack files into an archive")
    pack_parser.add_argument("-i", "--input", required=True, action="append", help="Input file or directory (can be used multiple times)")
    pack_parser.add_argument("-o", "--output", required=True, help="Output .qb file")

    # Unpack command
    unpack_parser = subparsers.add_parser("unpack", help="Unpack an archive")
    unpack_parser.add_argument("-i", "--input", required=True, help="Input .qb file")
    unpack_parser.add_argument("-o", "--output", help="Output directory (default: current directory)")

    # List command
    list_parser = subparsers.add_parser("list", help="List archive contents")
    list_parser.add_argument("-i", "--input", required=True, help="Input .qb file")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        sys.exit(1)

    archiver = Archiver()

    try:
        if args.command == "pack":
            print(f"Packing {args.input} into {args.output}...")
            archiver.pack(args.input, args.output)
            print("Done.")

        elif args.command == "unpack":
            out_dir = args.output if args.output else os.getcwd()
            print(f"Unpacking {args.input} into {out_dir}...")
            archiver.unpack(args.input, out_dir)
            print("Done.")

        elif args.command == "list":
            print(f"Listing contents of {args.input}:")
            files = archiver.list(args.input)
            for f in files:
                print(f)

    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
