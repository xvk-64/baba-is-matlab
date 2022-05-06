import sys
import os
import math
import re
from PIL import Image

tiles_per_row = 48
tile_size = 32

# Each unit's tile sprite
tiles = []

# These tiles are to be excluded
exclude = ["button_restart", "button_undo"]

try:
    data_path = sys.argv[1]
    f = open(os.path.join(data_path, "blocks.lua"))
    f.close()
except (IndexError, FileNotFoundError):
    print("You must pass the path to the Baba Is You 'Data' directory.")
    exit()

print("Using data path: {}".format(data_path))

index = 0


def atoi(text):
    return int(text) if text.isdigit() else text


def natural_keys(text):
    '''
    alist.sort(key=natural_keys) sorts in human order
    http://nedbatchelder.com/blog/200712/human_sorting.html
    (See Toothy's implementation in the comments)
    '''
    return [atoi(c) for c in re.split(r'(\d+)', "".join(text.split("_")))]


# Go over each file in the Sprites folder
for file in sorted(os.listdir(os.path.join(data_path, "Sprites")), key=natural_keys):
    print(file)
    # Match regex to find the unit name without numbers, eg baba, not baba_x_x.png
    match = re.findall(r"([a-z0-9_]+)((_[0-9]+){2}).png", file)
    try:
        tile_name = match[0][0]
    except IndexError:
        # Filename not formatted correctly, didn't match regex
        continue

    if (tile_name in exclude):
        # We don't want to include this sprite
        continue

    tile_path = os.path.join(data_path, "Sprites", file)
    try:
        with Image.open(tile_path) as im:
            tiles.append(tile_path)
    except:
        # Not an image file
        continue

    index += 1

required_rows = math.ceil(len(tiles) / tiles_per_row)
required_columns = min(tiles_per_row, len(tiles))

atlas_height = required_rows * tile_size
atlas_width = required_columns * tile_size

atlas = Image.new("RGB", (int(atlas_width), int(atlas_height)))

# Put all the sprites together in the atlas
for i, tile_path in enumerate(tiles):
    with Image.open(tile_path) as tile:
        left_offset = (tile_size - tile.width) / 2
        top_offset = (tile_size - tile.height) / 2

        left = int((i % tiles_per_row) * tile_size + left_offset)
        top = int(math.floor(i / tiles_per_row) * tile_size + top_offset)

        box = (left, top, left + tile.width, top + tile.height)

        cut_tile = tile.crop((0, 0, tile.width, tile.height))
        atlas.paste(cut_tile, box)

# Save the sprite atlas as an image file
atlas.save("atlas.png", "PNG")
print("Saved sprite atlas.")
