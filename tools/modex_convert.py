from PIL import Image

im = Image.open('test.bmp')
px = im.load()
raw_pal = im.getpalette()

im2 = Image.new(mode="P", size=im.size)
im2.putpalette(raw_pal)
px2 = im2.load()

o2 = 0

with open("img.raw", "wb") as f:
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

    im2.show()
    f.close()