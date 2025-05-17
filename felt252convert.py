### With Converter you can simply feed felt256 hex value into function.
import argparse

def str_to_felt_hex(s: str) -> str:
    """Convert UTF-8 string to felt252 hex string."""
    encoded = s.encode("utf-8")
    if len(encoded) > 31:
        raise ValueError("String too long for felt252 (max 31 bytes).")
    return "0x" + encoded.hex()



def felt_to_str(felt: int) -> str:
    """Convert felt252 integer (decimal) to string."""
    byte_length = (felt.bit_length() + 7) // 8
    return felt.to_bytes(byte_length, "big").decode("utf-8")


def hex_felt_to_str(hex_str: str) -> str:
    """Convert hexadecimal felt252 string to UTF-8 string."""
    felt = int(hex_str, 16)
    return felt_to_str(felt)


def main():
    parser = argparse.ArgumentParser(description="Convert between strings and felt252 representations.")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--to-felt", type=str, help="Convert string to decimal felt252")
    group.add_argument("--to-str", type=int, help="Convert decimal felt252 to string")
    group.add_argument("--to-str-hex", type=str, help="Convert hex felt252 (e.g. 0x...) to string")

    args = parser.parse_args()

    try:
        if args.to_felt:
            result = str_to_felt_hex(args.to_felt)
            print(result)
        elif args.to_str is not None:
            result = felt_to_str(args.to_str)
            print(result)
        elif args.to_str_hex:
            result = hex_felt_to_str(args.to_str_hex)
            print(result)
    except Exception as e:
        print(f"Error: {e}")


if __name__ == "__main__":
    main()
