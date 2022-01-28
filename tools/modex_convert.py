import sys
import os
import struct
from PIL import Image


def run(_filename):

    try:
        im = Image.open(_filename)
    except FileNotFoundError:
        print("Error: File not found")
        return

    if im.mode != 'P':
        print("Error: Image must be indexed color. Mode is ", im.mode)
        return

    filename, file_extension = os.path.splitext(_filename)

    if (im.size[0] & 3) != 0:
        print("Error: Image width must be a multiple of 4.")
        return

    # print(filename, file_extension)

    out_filename = "{}.raw".format(filename)

    print("Output: {}, {}x{}".format(out_filename, im.size[0], im.size[1]))

    px = im.load()
    raw_pal = im.getpalette()

    im2 = Image.new(mode="P", size=im.size)
    im2.putpalette(raw_pal)
    px2 = im2.load()

    o2 = 0

    with open(out_filename, "wb") as f:
        f.write(struct.pack("<h", im.size[0]))
        f.write(struct.pack("<h", im.size[1]))

        for plane in range(0, 4):
            for j in range(0, im.size[1]):
                for i in range(0, im.size[0] >> 2):
                    src_x = i * 4 + plane
                    src_y = j

                    dst_x = o2 % im2.size[0]
                    dst_y = divmod(o2, im2.size[0])[0]

                    px2[dst_x, dst_y] = px[src_x, src_y]
                    f.write(bytes([px[src_x, src_y]]))

                    o2 += 1

        # im2.show()
        f.close()


if __name__ == '__main__':
    # run()
    if len(sys.argv) != 2:
        print("./modex_convert.py foo.bmp")
        exit(1)

    run(sys.argv[1])

    exit(0)