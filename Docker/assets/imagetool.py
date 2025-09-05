#! /usr/bin/python3

import argparse
import itertools
import math
import re
import PIL
import PIL.Image

def lzwCompress(data):
    """Compress bytes using LZW

    @param lzw: a list of bytes
    @return: a list of LZW tokens
    """
    dict_size = 256
    dictionary = {}
    result = []
    wc = []
    # Initialise dictionary with bytes.
    for i in range(0, dict_size):
        dictionary[(i,)] = (i,)
    # Compress:
    w = [data.pop(0)]
    for c in data:
        wc = list(w)
        wc.append(c)
        if tuple(wc) in dictionary:
            w = wc
        else:
            result.extend(dictionary[tuple(w)])
            dictionary[tuple(wc)] = (dict_size,)
            dict_size = dict_size + 1
            w = (c,)
    # Add last sequence
    if len(w) != 0:
        result.extend(dictionary[tuple(w)])
    return result


def print_palette(img, name):
    """Output palette

    @param img: image object
    @param name: variable name
    @return: palette data as list of tuples
"""
    # Get palette from image.
    pal = img.getpalette()
    print("%s_palette = {" % name, end='')
    for idx in range(0, len(pal), 3):
        if idx >= 16 * 3:
            break
        print(" { %d, %d, %d }," % (pal[idx], pal[idx + 1], pal[idx + 2]), end='')
    print(" }")
    #for y in range(img.height):
    #    imgdat.extend(pal[img.getpixel((x, y))] for x in range(img.width))
    return pal


def print_hexpalette(img, name):
    """Output palette

    @param img: image object
    @param name: variable name
    @return: palette data as string
"""
    # Get palette from image.
    pal = img.getpalette()
    pstr = ""
    for idx in range(0, len(pal), 3):
        if idx >= 16 * 3:
            break
        pstr += "%02x%02x%02x" % (pal[idx], pal[idx + 1], pal[idx + 2])
    print("%s_hexpalette = \"%s\"" % (name, pstr))
    return pal


def get_image_data(img):
    """Get image data as list of nibbles

    @param img: image object
    @return: list of integers aka colour index
    """
    data = []
    for y in range(img.height):
        data.extend(img.getpixel((x, y)) for x in range(img.width))
    return data


def print_image_array(img, asstr, name):
    """Print image data as array

    @param img: image object
    @param asstr: as string if true
    @param name: variable name
    @return: image data or string
"""
    
    # Image array.
    data = get_image_data(img)
    if asstr:
        print("%s_image = \"%s\"" % (name, ''.join("%X" % i for i in data)))
    else:
        print("%s_image = { %s }" % (name, ','.join("%d" % i for i in data)))
    #RLE? print([[i,len(list(j))] for i,j in itertools.groupby(data)])
    return data



# Serialise a table (list) of values in an encoding similar to
# ascii85.
def ser85enc(data):
    assert(len(data) % 4 == 0)
    SER85CHARS="!~#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[|]^_`abcdefghijklmnopqrstu"
    result=""
    
    for i in range(0, len(data), 4):
        val = (data[i]<<24) + (data[i+1]<<16) + (data[i+2]<<8) + data[i+3]
        for j in range(4, -1, -1):
            v85 = math.floor(val / 85 ** j) % 85
            result += SER85CHARS[v85]
    return result


class BitStream:
    def __init__(self):
        self.bits = []
    def write(self, b):
        if b != 0:
            self.bits.append(1)
        else:
            self.bits.append(0)
    def writebyte(self, val):
        assert(val >= 0 and val < 256)
        for i in range(7,-1,-1):
            self.write(val & (1<<i))
    def write_eg(self, val):
        """Write a value in Elias-Gamma code"""
        prefixbits = int(math.log(val) / math.log(2))
        for i in range(0, prefixbits):
            self.write(0)
        for i in range(prefixbits, -1, -1):
            self.write(val & (1<<i))
    def flush(self):
        while(len(self.bits) % 8 != 0):
            self.write(0)
        return self.bits
    def get_bytes(self, fillmodulo=4):
        self.flush()
        # Convert each 8-bit group to byte value
        bytes_values = []
        for i in range(0, len(self.bits), 8):
            byte_value = sum(bit * (2 ** index) for index, bit in enumerate(reversed(self.bits[i:i+8])))
            bytes_values.append(byte_value)
        while len(bytes_values) % 4 != 0:
            bytes_values.append(0)
        return bytes_values
    def get_string(self):
        return ''.join(chr(i) for i in self.get_bytes())


def lz77Uncompress(compressed):
    data = []
    for offset, length, char in compressed:
        if offset > 0:
            now = len(data) - offset
            for i in range(length):
                data.append(data[now + i])
        data.append(char)
    return data

def lz77Compress(data):
    window_size = 32767
    compressed = []
    ngrams = {}
    pos = 0 # At which position are we currently?
    data = tuple(data)
    #Original series: ngramsizes = [987, 610, 377, 233, 144, 89, 55, 34, 21, 13, 8, 5, 3]
    #Strangely with a (limited) set of test data [987, 610, 377, 233,
    #144, 89, 55, 34, 21, 13, 8, 5, 3] and [233, 144, 89, 55, 34, 21,
    #13, 8, 5, 3] get the same compression results, but [144, 89, 55,
    #34, 21, 13, 8, 5, 3] tends to have more tokens. 🤷
    ngramsizes = [233, 144, 89, 55, 34, 21, 13, 8, 5, 3]
    def add_ngrams(pos):
        """Add the ngrams add position pos"""
        for ngramsize in ngramsizes:
            ngrams[data[pos:pos + ngramsize]] = pos
    while pos < len(data):
        # Find nearest/latest previous position. This may throw away
        # older matches which are longer but should not impact
        # compression ratio by much.
        for ngramsize in ngramsizes:
            prevpos = ngrams.get(data[pos:pos + ngramsize])
            if prevpos is not None:
                # When leaving the loop then prevpos is set to the
                # last position the ngram of size ngramsize was seen.
                break
        # Update the dictionary with current positions.
        add_ngrams(pos)
        if prevpos is None:
            # ngrams was not found.
            # Output a literal character with no back reference.
            compressed.append((0, 0, data[pos]))
        else:
            # Now check, how long the match actually is.
            for i in range(ngramsize, window_size):
                if pos + i >= len(data):
                    break
                if data[pos + i] != data[prevpos + i]:
                    break
            length = i
            offset = pos - prevpos
            if pos + length < len(data):
                compressed.append((offset, length, data[pos + length]))
            else:
                compressed.append((offset, length - 1, data[pos + length - 1]))
                compressed.append((0, 0, data[pos + length - 1]))
            while length > 0:
                length -= 1
                pos += 1
                # Add new n-gram to dictionary
                add_ngrams(pos)
        pos += 1
    #uncompressed = lz77Uncompress(compressed)
    #for i, char in enumerate(data):
    #    if char != uncompressed[i]:
    #        print("First mismatch", i)
    #        break
    return compressed

def print_image_lz77(img, name):
    """Print Image data with LZ77 compression

    @param img: image object
    @param name: variable name
    @return: list of lz77 tuples
    """
    data = get_image_data(img)
    compressed = lz77Compress(data)
    #print("-- Tokens:\n%s_imagelz77={%s} -- %d tokens." % (name, ','.join("{%d,%d,%d}" % i for i in compressed), len(compressed)))
    print('-- Stringified:\n%s_imagelz77="%s" -- %d tokens.' % (name, ';'.join("%x,%x,%x" % i for i in compressed), len(compressed)))


def print_hex_as_lua_comment(data, width, start):
    """Print as hex for usage in tic Lua

    @param data: bytes
    @param width: bytes per line
    @param start: offset line to start with (value before colon)
    """
    for idx in range(0, len(data), width):
        lineidx = idx // width
        line = "".join("%02x" % i for i in data[idx:idx + width])
        print("-- %03d:%s" % (lineidx, line))


def print_image_lz77eg(img, name):
    """Print Image data with LZ77 and EG compression

    @param img: image object
    @param name: variable name
    @return: list of lz77 tuples
    """
    data = get_image_data(img)
    compressed = lz77Compress(data)
    bits = BitStream()
    for token in compressed:
        bits.write_eg(1 + token[0])
        bits.write_eg(1 + token[1])
        bits.writebyte(token[2])
    bytelist = bits.get_bytes()
    #print(''.join("%d" % i for i in bits.bits))
    #print(len(''.join("%02x" % i for i in bytelist)), ''.join("%02x" % i for i in bytelist))
    print('-- Hex:')
    print_hex_as_lua_comment(bytelist, 240, 1)
    #Still problems with coding/decoding...
    encoded_string = ser85enc(bytelist)
    print('-- Stringified&Elias-Gamma:\n%s_lz77eg="%s" -- %d chars, %d tokens.' % (name, encoded_string, len(encoded_string), len(compressed)))



def get_tiles_data(img):
    """Get tiles data from a 128*128 image

    @param img: image object
    @return: list of bytes
    """
    data = get_image_data(img)
    tdata = [] # Tile data to be filled.
    if img.width != 128 or img.height != 128:
        raise RuntimeError("Wrong dimension for tiles, 128*128 is needed!")
    for tile in range(256):
        #SPRITES: Each sprite/tile is laid out sequentially in
        #memory. Each sprite/tile is 32 bytes long, so sprite #i
        #starts at 0x4000+(32*i). Each byte in the sprite represents a
        #pair of pixels (since each pixel is 4 bits). The low 4 bits
        #are the left pixel, and the high 4 bits are the right
        #pixel. Pixels are laid out from left to right, top to bottom
        #row.
        #
        # Pixelrow is 128 pixel. (* 128 128)16384
        # 16 sprites times 8 rows: (* 8 128)1024
        tcolumn = tile & 15
        trow = tile // 16
        for y in range(8):
            for x in range(0,8,2):
                # (* 15 1024)15360
                pixelidx = tcolumn * 8 + trow * 1024 + y * 128 + x
                #print(tile,tcolumn,trow,x,y,pixelidx)
                left = data[pixelidx]
                right = data[pixelidx + 1]
                tdata.append(right << 4 | left)
    return tdata


def print_tiles_lzw(img, name):
    """Print tiles data with LZW compression

    @param img: image object
    @param name: variable name
    @return: list of lz77 tuples
    """
    tdata = get_tiles_data(img)
    compressed = lzwCompress(tdata)
    #print("tiles_lzw = {%s} -- %d tokens." % (','.join("0x%X" % i for i in compressed), len(compressed) ))
    #print("%s_tiles = {%s} -- %d tokens." % (name, ','.join("%d" % i for i in tdata), len(tdata) ))
    print("%s_tileslzw = {%s} -- %d tokens." % (name, ','.join("%d" % i for i in compressed), len(compressed) ))


def print_tiles_lz77(img, name):
    """Print tiles data with LZ77 compression

    @param img: image object
    @param name: variable name
    @return: list of lz77 tuples
    """
    tdata = get_tiles_data(img)
    compressed = lz77Compress(tdata)
    print('%s_tileslz77="%s" -- %d tokens.' % (name, ';'.join("%x,%x,%x" % i for i in compressed), len(compressed)))


def print_font(data, name):
    """Compress raw font data

    The font is assumed to start at a space and to have 768 bytes.

    @param data: raw input bytes as byte()
    @param name: variable name
    """
    def reverse_bits(byte):
        rbyte = 0
        for bit in range(8):
            if byte & (1<<bit) != 0:
                rbyte |= 1<<(7 - bit)
        return rbyte
    data = [reverse_bits(i) for i in data]
    compressed = lzwCompress(data)
    print("%s_fontlzw = {%s} -- %d tokens." % (name, ','.join("%d" % i for i in compressed), len(compressed) ))
    #compressed = lz77Compress(data)
    #print('-- %s_fontz77="%s" -- %d tokens.' % (name, ';'.join("%x,%x,%x" % i for i in compressed), len(compressed)))


def mainng(curr, safename, args):
    img = PIL.Image.open(curr)
    if args.extract == "palette":
        # TODO: handle palette separately
        assert(len("not implemented") == 0)
    elif args.extract == "image":
        data = get_image_data()
    elif args.extract == "tiles":
        assert(len("not implemented") == 0)


def main():
    """Main function

    Parses the command line and starts the conversion.
"""
    parser = argparse.ArgumentParser()
    parser.add_argument("files", nargs='+', help="list of images to convert")
    parser.add_argument("--palette", "-p", help="extract palette", action="store_true")
    parser.add_argument("--font", "-f", help="convert raw binary font (768 bytes)", action="store_true")
    parser.add_argument("--hexpalette", "-P", help="extract palette", action="store_true")
    parser.add_argument("--imagearray", "-i", help="extract image data as array", action="store_true")
    parser.add_argument("--imagestring", "-s", help="extract image data as string", action="store_true")
    parser.add_argument("--imagelz77", "-7", help="extract image data and compress using LZ77", action="store_true")
    parser.add_argument("--imagelz77eg", help="extract image data and compress using LZ77 and Elias-Gamma", action="store_true")
    parser.add_argument("--tileslzw", "-t", help="extract tiles from an image, compress lzw", action="store_true")
    parser.add_argument("--tileslz77", help="extract tiles from an image, compress lz77", action="store_true")
    parser.add_argument("--name", "-n", help="(prefix) name of the variable", default="data", type=str)
    # How to make this more flexible?
    parser.add_argument("--extract", help="extract data from image", choices=("palette", "image", "tiles"))
    parser.add_argument("--compress", help="set compression algorithm for data", choices=("lz77", "lzw", "none"), default="none")
    args = parser.parse_args()
    for curr in args.files:
        print(f"-- Processing '{curr}'")
        safename = re.sub(r'\W+', '_', args.name)
        if args.extract:
            mainng(safename, args)
        elif args.font:
            print_font(open(curr, "rb").read(), safename)
        else:
            img = PIL.Image.open(curr)
            if args.palette:
                print_palette(img, safename)
            if args.hexpalette:
                print_hexpalette(img, safename)
            if args.imagearray:
                print_image_array(img, False, safename)
            if args.imagestring:
                print_image_array(img, True, safename)
            if args.imagelz77:
                print_image_lz77(img, safename)
            if args.imagelz77eg:
                print_image_lz77eg(img, safename)
            if args.tileslzw:
                print_tiles_lzw(img, safename)
            if args.tileslz77:
                print_tiles_lz77(img, safename)

if __name__ == "__main__":
    main()
