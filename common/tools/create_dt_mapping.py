#!/usr/bin/env python3
"""
Create Device Tree mapping binary with FDT header
Combines FDT header structure with ID-Name mapping data

Final Binary Structure:
┌─────────────────────────────────────┐ ← 0x00
│           FDT Header                │  40 bytes
│         (40 bytes / 0x28)           │  - magic: 0xD00DFEED (big-endian)
│                                     │  - totalsize: complete file size
│                                     │  - structure_offset: 0x28 (40)
│                                     │  - strings_offset: 0x28 (40)
│                                     │  - reserve_map_offset: 0x28 (40)
│                                     │  - version: 17
│                                     │  - last_compatible_version: 16
│                                     │  - boot_cpuid_phys: 0
│                                     │  - strings_size: 1
│                                     │  - structure_size: mapping data size
├─────────────────────────────────────┤ ← 0x28 (40)
│        Mapping Header               │  8 bytes
│      magic[4] + number_of_map[4]    │  - 4-byte magic: 0xD00DFEED (big-endian)
│                                     │  - number_of_map: count of entries (little-endian)
├─────────────────────────────────────┤ ← 0x30 (48)
│         Map Entry 1                 │  72 bytes
│    magic[4] + id[4] + name[64]      │  - magic: 0xD00DFEED (big-endian)
│                                     │  - id: 1 (little-endian uint32)
│                                     │  - name: null-terminated string (64 bytes)
├─────────────────────────────────────┤
│         Map Entry 2                 │  72 bytes
│    magic[4] + id[4] + name[64]      │  - id: 2, second name
├─────────────────────────────────────┤
│            ...                      │
│         Map Entry N                 │  72 bytes
│    magic[4] + id[4] + name[64]      │  - id: N, last name
└─────────────────────────────────────┘

Usage: create_dt_mapping.py board1 board2 board3 [options]
"""

import struct
import sys
import os
import argparse

# Constants
FDT_MAGIC = 0xD00DFEED
FDT_HEADER_SIZE = 40
MAPPING_MAGIC = 0xD00DFEED
MAGIC_SIZE = 4
NAME_SIZE = 64
MAP_STRUCT_SIZE = MAGIC_SIZE + 4 + NAME_SIZE  # magic(4) + id(4) + name(64) = 72
MAPPING_HEADER_SIZE = MAGIC_SIZE + 4          # magic(4) + number_of_map(4) = 8
MAX_NAME_LENGTH = NAME_SIZE - 1               # Reserve 1 byte for null terminator

def validate_board_names(names):
    """
    Validate board names length

    Args:
        names: List of board names

    Returns:
        tuple: (success, error_message)
    """
    for i, name in enumerate(names):
        if not name or not name.strip():
            return False, f"Board name {i+1} is empty"

        name_bytes = name.encode('utf-8')
        if len(name_bytes) > MAX_NAME_LENGTH:
            return False, f"Board name '{name}' is too long ({len(name_bytes)} bytes > {MAX_NAME_LENGTH} bytes limit)"

    return True, ""

def create_magic_bytes(magic_value):
    """Create 4-byte magic in big-endian format"""
    return struct.pack('>I', magic_value)

def create_fdt_header(mapping_data_size):
    """
    Create FDT header structure (40 bytes)

    Args:
        mapping_data_size: Size of mapping data that follows header

    Returns:
        bytes: FDT header data
    """
    total_size = FDT_HEADER_SIZE + mapping_data_size
    structure_offset = FDT_HEADER_SIZE      # Points to mapping data
    strings_offset = FDT_HEADER_SIZE        # Points to mapping data
    reserve_map_offset = FDT_HEADER_SIZE    # Points to mapping data
    version = 17
    last_compatible_version = 16
    boot_cpuid_phys = 0
    strings_size = 1                        # Minimal strings block size
    structure_size = mapping_data_size      # Size of mapping data

    return struct.pack('>10I',              # Big-endian format for FDT
        FDT_MAGIC,
        total_size,
        structure_offset,
        strings_offset,
        reserve_map_offset,
        version,
        last_compatible_version,
        boot_cpuid_phys,
        strings_size,
        structure_size
    )

def create_mapping_header(number_of_maps):
    """
    Create mapping header structure

    Args:
        number_of_maps: Number of map entries

    Returns:
        bytes: Mapping header data (magic in big-endian, count in little-endian)
    """
    magic_bytes = create_magic_bytes(MAPPING_MAGIC)  # Big-endian magic
    return magic_bytes + struct.pack('<I', number_of_maps)  # Little-endian count

def create_map_entry(map_id, name):
    """
    Create single map entry

    Args:
        map_id: Map ID (starts from 1)
        name: Map name string (must be validated before calling this function)

    Returns:
        bytes: Map entry data
    """
    magic_bytes = create_magic_bytes(MAPPING_MAGIC)

    # Process name: encode to UTF-8 and pad to 64 bytes
    # Name length should already be validated before calling this function
    name_bytes = name.encode('utf-8')

    # Pad with null bytes to reach 64 bytes
    name_bytes = name_bytes + b'\0' * (NAME_SIZE - len(name_bytes))

    return magic_bytes + struct.pack('<I', map_id) + name_bytes

def create_mapping_data(names):
    """
    Create complete mapping data structure

    Args:
        names: List of name strings

    Returns:
        bytes: Complete mapping data (header + entries)
    """
    # Create mapping header
    mapping_header = create_mapping_header(len(names))

    # Create all map entries
    map_entries = b''
    for i, name in enumerate(names, 1):  # IDs start from 1
        map_entry = create_map_entry(i, name)
        map_entries += map_entry

    return mapping_header + map_entries

def create_complete_binary(names, output_file):
    """
    Create complete DT mapping binary file

    Args:
        names: List of board/device names
        output_file: Output file path

    Returns:
        bool: Success status
    """
    try:
        # Validate board names first
        valid, error_msg = validate_board_names(names)
        if not valid:
            print(f"Error: {error_msg}")
            return False

        # Create mapping data
        mapping_data = create_mapping_data(names)

        # Create FDT header
        fdt_header = create_fdt_header(len(mapping_data))

        # Write complete binary: FDT header + mapping data
        with open(output_file, 'wb') as f:
            f.write(fdt_header)
            f.write(mapping_data)

        return True

    except Exception as e:
        print(f"Error creating binary: {e}")
        return False

def dump_binary(file_path):
    """
    Dump binary file content showing ID-Name mappings

    Args:
        file_path: Path to binary file

    Returns:
        bool: Success status
    """
    try:
        with open(file_path, 'rb') as f:
            data = f.read()

        if len(data) < FDT_HEADER_SIZE:
            print("Error: File too small for FDT header")
            return False

        # Parse FDT header
        fdt_header = struct.unpack('>10I', data[:FDT_HEADER_SIZE])
        fdt_magic, total_size, structure_offset = fdt_header[:3]

        if fdt_magic != FDT_MAGIC:
            print(f"Error: Invalid FDT magic: 0x{fdt_magic:08X} (expected 0x{FDT_MAGIC:08X})")
            return False

        # Check if we have mapping data
        if len(data) <= structure_offset + MAPPING_HEADER_SIZE:
            print("No mapping data found")
            return True

        # Parse mapping header
        mapping_start = structure_offset
        mapping_header_data = data[mapping_start:mapping_start + MAPPING_HEADER_SIZE]

        if len(mapping_header_data) < MAPPING_HEADER_SIZE:
            print("Error: Incomplete mapping header")
            return False

        # Check mapping magic (4 bytes, big-endian)
        mapping_magic = struct.unpack('>I', mapping_header_data[:MAGIC_SIZE])[0]
        if mapping_magic != MAPPING_MAGIC:
            print(f"Error: Invalid mapping magic: 0x{mapping_magic:08X} (expected 0x{MAPPING_MAGIC:08X})")
            return False

        # Get number of maps
        number_of_maps = struct.unpack('<I', mapping_header_data[MAGIC_SIZE:])[0]

        if number_of_maps == 0:
            print("No mappings found")
            return True

        print("ID   Name")
        print("---- " + "-" * 60)

        # Parse each map entry
        map_start = mapping_start + MAPPING_HEADER_SIZE
        for i in range(number_of_maps):
            entry_offset = map_start + i * MAP_STRUCT_SIZE

            if entry_offset + MAP_STRUCT_SIZE > len(data):
                print(f"Error: Map entry {i+1} extends beyond file")
                break

            entry_data = data[entry_offset:entry_offset + MAP_STRUCT_SIZE]

            # Parse map entry (4-byte magic in big-endian)
            map_magic = struct.unpack('>I', entry_data[:MAGIC_SIZE])[0]
            map_id = struct.unpack('<I', entry_data[MAGIC_SIZE:MAGIC_SIZE+4])[0]
            map_name_bytes = entry_data[MAGIC_SIZE+4:MAGIC_SIZE+4+NAME_SIZE]

            # Verify map magic
            if map_magic != MAPPING_MAGIC:
                print(f"Warning: Invalid magic for map entry {i+1}: 0x{map_magic:08X}")

            # Extract name (remove null padding)
            name_end = map_name_bytes.find(b'\0')
            if name_end == -1:
                name_end = NAME_SIZE
            map_name = map_name_bytes[:name_end].decode('utf-8', errors='replace')

            # Display mapping
            print(f"{map_id:<4} {map_name}")

        return True

    except Exception as e:
        print(f"Dump failed: {e}")
        import traceback
        traceback.print_exc()
        return False

def main():
    parser = argparse.ArgumentParser(
        description="Create Device Tree mapping binary with FDT header",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s board1 board2 board3
  %(prog)s imx95 imx95-ox03c10 imx95-ap1302 -o dt_mapping.bin
  %(prog)s --dump dt_mapping.bin

Note:
  Board names must not exceed 63 bytes when UTF-8 encoded.
        """)

    parser.add_argument('names', nargs='*',
                       help='Board/device names (space separated, max 63 bytes each)')
    parser.add_argument('-o', '--output', default='dt_mapping.bin',
                       help='Output file name (default: dt_mapping.bin)')
    parser.add_argument('--dump', metavar='FILE',
                       help='Dump existing binary file content')

    args = parser.parse_args()

    # Dump mode
    if args.dump:
        if not os.path.exists(args.dump):
            print(f"Error: File not found: {args.dump}", file=sys.stderr)
            return 1

        success = dump_binary(args.dump)
        return 0 if success else 1

    # Check if names provided
    if not args.names:
        print("Error: No board names provided")
        print("Usage: create_dt_mapping.py board1 board2 board3")
        print(f"Note: Board names must not exceed {MAX_NAME_LENGTH} bytes when UTF-8 encoded")
        return 1

    # Filter out empty names
    names = [name.strip() for name in args.names if name.strip()]
    if not names:
        print("Error: No valid board names after filtering")
        return 1

    # Create binary file
    success = create_complete_binary(names, args.output)
    if not success:
        return 1

    print(f"Created {args.output} with {len(names)} board mappings")

    return 0

if __name__ == '__main__':
    sys.exit(main())
