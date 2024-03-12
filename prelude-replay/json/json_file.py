import argparse
import sys
import json


# iterate through the list of tuples, read the file from the path of tuple[1],
# and build a dict mapping from key to the contents of the file.
def read_files(args):
    contents = dict()
    for arg in args:
        key, value = arg
        try:
            with open(value, "r") as file:
                # make sure to trim whitespace from the file contents
                contents[key] = file.read().strip()
        except IOError as e:
            print(f"Failed to read file {value}: {e}", file=sys.stderr)
            raise e
    return contents


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Create a json file from specified args"
    )
    parser.add_argument(
        "--arg",
        nargs=2,
        required=True,
        action="append",
        help="--arg key value_file --arg key value_file ...",
    )
    parser.add_argument("--filename", required=True, help="Name of the json file")
    args = parser.parse_args()

    # To show the results of the given option to screen.
    contents = read_files(parser.parse_args().arg)

    # write contents encoded as json to filename
    with open(parser.parse_args().filename, "w") as fp:
        json.dump(contents, fp)
