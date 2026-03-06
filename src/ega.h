#ifndef EGA_H
#define EGA_H

#include <stdio.h>

#ifdef PLATFORM_DOS
#include <dos.h>
#else
#include <raylib.h>
#include <math.h>
#include <stdint.h>
#endif

typedef unsigned short u16;

typedef struct ega_sprite_s {
    u16 column_count;
    u16 width;
    u16 height;
    u16 num_channels;
    u16 num_color_channels;
    u16 planes_and;
    u16 planes_or;
#ifdef PLATFORM_DOS
    void *data;
#else
    Image data;
#endif
} ega_sprite_t;

// 16x16, 4bpp = 128 bytes
typedef struct ega_tile_s {
    unsigned char data[128];
} ega_tile_t;

extern void EGA_Init(void);
extern void EGA_Close(void);
extern void EGA_SetPlanes(unsigned char planes_mask);
extern void EGA_DrawSpriteFast(int x, int y, ega_sprite_t *sprite);
extern void EGA_DrawSpriteSlow(int x, int y, ega_sprite_t *sprite);
extern ega_sprite_t EGA_LoadSprite(const char *path);
extern void EGA_WaitVerticalRetrace(void);
extern void EGA_ClearScreen(void);
extern void EGA_SetDrawPage(u16 page);
extern void EGA_ShowPage(u16 page);

#ifdef PLATFORM_DOS
extern void EGA_BeginLatchedCopy(void);
extern void EGA_EndLatchedCopy(void);
extern void EGA_DrawTileFast(u16 x, u16 y, u16 vmem_offs);
extern void EGA_DrawTileFast2(u16 x, u16 y, u16 src_seg, u16 src_offs, u16 dest_seg);
extern void EGA_DrawSpriteMaskFast2(u16 src_srg, u16 src_offs, u16 src_skip,
                                    u16 dest_seg, u16 dest_offs, u16 dest_rewind,
                                    u16 num_cols, u16 num_rows);
#else
extern Image EGA_Raylib_GetBackBuffer(void);
extern void EGA_Raylib_GetMouseCoords(u16 *x, u16 *y);
#endif

#ifdef EGA_IMPLEMENTATION

static struct {
    u16 draw_page;
    u16 visible_page;
#ifdef PLATFORM_DESKTOP
    Image pages[2];
    Texture mainTexture;
    int window_width, window_height;
    Rectangle dest_rect;
#else
    u16 draw_segment;
#endif
} ega_state;

void EGA_SetDrawPage(u16 page) {
    ega_state.draw_page = page;
#ifdef PLATFORM_DOS
    ega_state.draw_segment = 0xA000 + (0x1F4 * page);
#endif
}

void EGA_ShowPage(u16 page) {
#ifdef PLATFORM_DOS
    unsigned char low, high;
    if(page == 0) {
        low = 0;
        high = 0;
    } else {
        high = 0x1f;
        low = 0x40;
    }

    asm {
      // start address high
      mov dx, 3d4h
      mov al, 0Ch
      mov ah, high
      out dx, ax

      // start address low
      mov dx, 3d4h
      mov al, 0Dh
      mov ah, low
      out dx, ax
    }
#endif

    ega_state.visible_page = page;
}
void EGA_Init(void) {
#ifdef PLATFORM_DOS
    extern void EGA_Init_DOS(void);
    EGA_Init_DOS();

    asm {
        mov dx, 3ceh

    //  { Register 0: Set/Reset - set to 0 (we'll use CPU data) }
      mov ax, 0000h
      out dx, ax

//      { Register 1: Enable Set/Reset - set to 0 (disable, use CPU data) }
      mov ax, 0001h
      out dx, ax

//      { Register 3: Data Rotate/Function Select - set to 0 (replace mode, no rotation) }
      mov ax, 0003h
      out dx, ax

//      { Register 8: Bit Mask - set to $FF (all bits enabled initially) }
      mov ax, 0xff08
      out dx, ax
    }
#else
    InitWindow(320 * 2, 200 * 2, "NEO");
    Vector2 dpi = GetWindowScaleDPI();

    ega_state.window_width = 320 * 2 * dpi.x;
    ega_state.window_height = 200 * 2 * dpi.y;

    SetWindowState(FLAG_WINDOW_RESIZABLE);

    SetWindowSize(ega_state.window_width, ega_state.window_height);
    SetTargetFPS(30);
    HideCursor();

    for(int i = 0; i < 2; i++) {
        ega_state.pages[i] = GenImageColor(320, 200, BLANK);
    }

    ega_state.mainTexture = LoadTextureFromImage(ega_state.pages[0]);
    SetTextureFilter(ega_state.mainTexture, TEXTURE_FILTER_POINT);

    //SetTraceLogLevel(LOG_WARNING);
#endif
    EGA_SetDrawPage(0);
    EGA_ShowPage(0);
}

void EGA_Close(void) {
#ifdef PLATFORM_DOS
    extern void EGA_Close_DOS(void);
    EGA_Close_DOS();
#endif
}

#ifdef PLATFORM_DOS
void EGA_BeginLatchedCopy(void) {
    asm {
        // Enable all planes
        mov dx, 3c4h
        mov ax, 0f02h
        out dx, ax

        // Set up latched copy
        mov dx, 3ceh
        mov ax, 0105h
        out dx, ax
    }
}

void EGA_EndLatchedCopy(void) {
    asm {
        mov dx, 3ceh
        mov ax, 0005h
        out dx, ax
    }
}

void EGA_DrawTileFast(u16 x, u16 y, u16 vmem_offs) {
    EGA_DrawTileFast2(x, y, 0xA400, vmem_offs, ega_state.draw_segment);
}
#endif

#ifdef PLATFORM_DESKTOP
#endif

ega_sprite_t EGA_LoadSprite(const char *path) {
    char final_path[256];
    ega_sprite_t out;
#ifdef PLATFORM_DOS
    FILE *f;
#endif

    out.width = out.height = 0;

#ifdef PLATFORM_DOS
    sprintf(final_path, "data/%s.ega", path);
    f = fopen(final_path, "rb");

    if(!f) {
        printf("Couldn't open %s\n", final_path);
        return out;
    }

    fread(&out.column_count, 2, 1, f);
    fread(&out.height, 2, 1, f);
    out.width = out.column_count * 8;
    out.num_color_channels = 4;
    out.num_channels = 5;
    out.planes_and = 0xff;
    out.planes_or = 0;
    out.data = (void *) malloc(out.column_count * out.height * 5);
    if(out.data == NULL) {
        printf("didn't allocate!\n");
    }
    fread(out.data, out.column_count * out.height * 5, 1, f);
//    printf("Loaded %s, %d x %d, num columns: %d", final_path, out.width, out.height, out.column_count);

#else
    sprintf(final_path, "dev/%s.png", path);
    out.data = LoadImage(final_path);
    out.width = out.data.width;
    out.height = out.data.height;
#endif
    return out;
}

#ifdef PLATFORM_DESKTOP
#endif

#ifdef PLATFORM_DOS
void EGA_SetRotate(unsigned char op, unsigned char rotate) {
    unsigned char val = (op << 3) | rotate;
    asm {
        mov dx, 3ceh
        mov al, 3
        mov ah, val
        out dx, ax
    }
}

void EGA_SetMask(unsigned char bit_mask) {
    asm {
        mov dx, 3ceh
        mov al, 8
        mov ah, bit_mask
        out dx, ax
    }
}

#endif
void EGA_DrawSpriteFast(int x, int y, ega_sprite_t *sprite) {
#ifdef PLATFORM_DOS
    int src_column0, src_column1, dst_column0, dst_column1;
    int start_y, end_y, start_row, end_row, num_rows, num_cols;

    u16 src_seg, src_offs, src_skip;
    u16 dest_offs, dest_rewind;

    u16 plane;

    src_column0 = 0;
    src_column1 = sprite->column_count - 1;
    dst_column0 = x / 8;
    dst_column1 = dst_column0 + src_column1;

    if (dst_column0 > 39 || dst_column1 < 0) {
        return;
    }

    if (dst_column0 < 0) {
        src_column0 += -dst_column0;
        dst_column0 = 0;
    }

    if (dst_column1 > 39) {
        src_column1 -= (dst_column1 - 39);
        dst_column1 = 39;
    }

    start_y = y;
    end_y = start_y + (sprite->height - 1);

    if (end_y < 0 || end_y > 199) return;

    if (start_y < 0) start_y = 0;
    if(end_y > 199) end_y = 199;

    if (end_y < start_y) return;

    start_row = start_y - y;
    end_row = end_y - y;

    num_rows = end_row - start_row;
    num_cols = src_column1 - src_column0 + 1;

    src_seg = FP_SEG(sprite->data);
    src_offs = FP_OFF(sprite->data)
            + sprite->height * (src_column0 * sprite->num_channels + sprite->num_color_channels)
            + start_row;
    src_skip = sprite->height * sprite->num_color_channels
            + (sprite->height - num_rows - 1);

    dest_offs = dst_column0 + start_y * 40;
    dest_rewind = (num_rows + 1) * 40 - 1;
    num_rows ++;

    // Set AND operation
    EGA_SetRotate(1, 0);
    EGA_SetMask(0xff);
    EGA_SetPlanes(15);
    EGA_DrawSpriteMaskFast2(src_seg, src_offs, src_skip, ega_state.draw_segment, dest_offs, dest_rewind, num_cols, num_rows);

    // Set OR operation
    EGA_SetRotate(2, 0);
    for (plane = 0; plane < sprite->num_color_channels; plane++) {
       EGA_SetPlanes(((1 << plane) & sprite->planes_and) | sprite->planes_or);
       src_offs = FP_OFF(sprite->data)
               + sprite->height * (src_column0 * sprite->num_channels + plane)
               + start_row;

       EGA_DrawSpriteMaskFast2(src_seg, src_offs, src_skip, ega_state.draw_segment, dest_offs, dest_rewind, num_cols, num_rows);
   }

#else

    int src_x0 = 0;
    int src_x1 = sprite->width - 1;
    int src_y0 = 0;
    int src_y1 = sprite->height - 1;

    int dst_x0 = x;
    int dst_x1 = dst_x0 + src_x1;
    int dst_y0 = y;
    int dst_y1 = dst_y0 + src_y1;

    if(dst_x0 < 0) {
        src_x0 -= dst_x0;
        dst_x0 = 0;
    }

    if(dst_y0 < 0) {
        src_y0 -= dst_y0;
        dst_y0 = 0;
    }

    if(dst_x1 > 319) {
        src_x1 -= (dst_x1 - 319);
        dst_x1 = 319;
    }

    if(dst_y1 > 199) {
        src_y1 -= (dst_y1 - 199);
        dst_y1 = 199;
    }

    // Hack
    unsigned char plane_or[4] = {0,0,0,0};

    if (sprite->planes_and & 0x07 && sprite->planes_or == 8) {
        // mouse highlight
        plane_or[0] = 64;
        plane_or[1] = 64;
        plane_or[2] = 64;
    }

    if (sprite->planes_and == 0 && sprite->planes_or == 12) {
        plane_or[0] = 127;
    }

    Image *img = &ega_state.pages[ega_state.draw_page];

    Color *src = (Color *) sprite->data.data;
    Color *dst = (Color *) img->data;

    int numCols = src_x1 - src_x0 + 1;
    int numRows = src_y1 - src_y0 + 1;

    for(int y = 0; y < numRows; y++) {
        for(int x = 0; x < numCols; x++) {

            int sx = src_x0 + x;
            int sy = src_y0 + y;
            int dx = dst_x0 + x;
            int dy = dst_y0 + y;
            Color s = src[sy * sprite->data.width + sx];
            if(s.a == 255) {
                Color t = {
                    s.r | plane_or[0],
                    s.g | plane_or[1],
                    s.b | plane_or[2],
                    255
                };
//                if(sprite->planes_or == 0x0f) {
//                    s = RED;
//                }
                dst[dy * 320 + dx] = t;
            }
        }
    }
//    ImageDraw(img, sprite->data, srcRect, dstRect, color);
#endif
}

void EGA_DrawSpriteSlow(int x, int y, ega_sprite_t *sprite) {
#ifdef PLATFORM_DOS

    int src_x0, src_x1, src_y0, src_y1;
    int dest_x0, dest_x1, dest_y0, dest_y1;
    u16 clipped;
    int src_column0, src_column1, dst_column0, dst_column1;
    u16 dest_offs_offs1;
    u16 src_seg, src_offs, src_skip;
    u16 dest_seg, dest_offs, dest_rewind;
    int num_rows, num_cols, num_cols2, shift_amount;
    u16 plane;

    if (x % 8 == 0) {
        EGA_DrawSpriteFast(x, y, sprite);
        return;
    }

    src_x0 = 0;
    src_x1 = sprite->width - 1;
    src_y0 = 0;
    src_y1 = sprite->height - 1;

    dest_x0 = x;
    dest_x1 = x + src_x1;
    dest_y0 = y;
    dest_y1 = y + src_y1;

    if (dest_x0 > 319 || dest_x1 < 0 || dest_y0 > 199 || dest_y1 < 0) {
        return;
    }

    // Clipping

    clipped = 0;

    if(dest_x0 < 0) {
        clipped = 2;
        src_x0 += -dest_x0;
        dest_x0 = 0;
    }

    if(dest_x1 > 319) {
        clipped = 1;
        src_x1 -= dest_x1 - 319;
        dest_x1 = 319;
    }

    if(dest_y0 < 0) {
        src_y0 += -dest_y0;
        dest_y0 = 0;
    }

    if(dest_y1 > 199) {
        src_y1 -= dest_y1 - 199;
        dest_y1 = 199;
    }

    src_column0 = src_x0 >> 3;
    src_column1 = src_x1 >> 3;
    dst_column0 = dest_x0 >> 3;
    dst_column1 = dest_x1 >> 3;

    num_rows = dest_y1 - dest_y0;
    num_cols = src_column1 - src_column0;
    num_cols2 = num_cols;

    dest_offs_offs1 = 1;

    src_seg = FP_SEG(sprite->data);
    dest_rewind = (num_rows + 1) * 40 - 1;
    src_skip = sprite->height * 4 + ((sprite->height - num_rows - 1));
    dest_offs = dst_column0 + dest_y0 * 40;

    shift_amount = x & 7;

    switch(clipped) {
        case 0:
            src_offs = FP_OFF(sprite->data) + sprite->height * (src_column0 * 5 + 4) + src_y0;
            break;
        case 1:
            // If we're being clipped on the right, for the 2nd iteration, draw less columns
            num_cols2 --;

            src_offs = FP_OFF(sprite->data) + sprite->height * (src_column0 * 5 + 4) + src_y0;
            break;
        case 2:
            // Number of columns for the first iteration decreases
            num_cols --;

            // Increase source column
            src_offs = FP_OFF(sprite->data) + sprite->height * ((src_column0 + 1) * 5 + 4) + src_y0;

            // Destination offset doesn't have 1 added to it
            dest_offs_offs1 = 0;
            break;
    }

    // Draw mask using AND operation
    EGA_SetPlanes(0x0f);
    EGA_SetRotate(1, shift_amount);

    if(num_cols >= 0) {
    EGA_SetMask(0xff >> shift_amount);
      EGA_DrawSpriteMaskFast2(src_seg, src_offs, src_skip,
         ega_state.draw_segment, dest_offs, dest_rewind,
         num_cols + 1, num_rows + 1);
    }

   if (num_cols2 >= 0) {
       src_offs = FP_OFF(sprite->data) + sprite->height * (src_column0 * 5 + 4) + src_y0;

        EGA_SetMask(0xff << (8-shift_amount));
      EGA_DrawSpriteMaskFast2(
            src_seg, src_offs, src_skip,
            ega_state.draw_segment, dest_offs + dest_offs_offs1, dest_rewind,
            num_cols2 + 1, num_rows + 1);
   }

   // Draw sprite using OR operation
    EGA_SetRotate(2, shift_amount);

   for(plane = 0; plane < 4; plane++) {
       EGA_SetPlanes(((1 << plane) & sprite->planes_and) | sprite->planes_or);

       if(num_cols >= 0) {
           EGA_SetMask(0xff >> shift_amount);
           if(clipped == 2) {
             // Increase source column - could just add here
               src_offs = FP_OFF(sprite->data) + sprite->height * ((src_column0 + 1) * 5 + plane) + src_y0;
           } else  {
               src_offs = FP_OFF(sprite->data) + sprite->height * (src_column0 * 5 + plane) + src_y0;
           }
           EGA_DrawSpriteMaskFast2(src_seg, src_offs, src_skip,
                ega_state.draw_segment, dest_offs, dest_rewind,
                num_cols + 1, num_rows + 1);
       }

       if(num_cols2 >= 0) {
            src_offs = FP_OFF(sprite->data) + sprite->height * (src_column0 * 5 + plane) + src_y0;

            EGA_SetMask(0xff << (8-shift_amount));

         EGA_DrawSpriteMaskFast2(
               src_seg, src_offs, src_skip,
               ega_state.draw_segment, dest_offs + dest_offs_offs1, dest_rewind,
               num_cols2 + 1, num_rows + 1);
       }
   }
#else
    EGA_DrawSpriteFast(x, y, sprite);
#endif
}

#define MIN(x, y) ((x) < (y) ? (x) : (y))

void EGA_WaitVerticalRetrace(void) {
#ifdef PLATFORM_DOS
    while ((inportb(0x3da) & 0x08) != 0);
    while ((inportb(0x3da) & 0x08) == 0);

#else
    int screenWidth = GetScreenWidth();
    int screenHeight = GetScreenHeight();
    int scaleX = (int) floorf((float) GetScreenWidth() / 320.0f);
    int scaleY = (int) floorf((float) GetScreenHeight() / 200.0f);
    int scale = MIN(scaleX, scaleY);

    int w = 320 * scale;
    int h = 200 * scale;


    Vector2 p;
    p.x = 0;
    p.y = 0;
    UpdateTexture(ega_state.mainTexture, ega_state.pages[ega_state.visible_page].data);

    Rectangle src = {
        0, 0, 320, 200
    };

    ega_state.dest_rect = (Rectangle) {
        screenWidth / 2 - w / 2,
        screenHeight / 2 - h / 2,
        w, h
    };
    DrawTexturePro(ega_state.mainTexture, src, ega_state.dest_rect, (Vector2){0, 0}, 0.0f, WHITE);
#endif
}

#ifdef PLATFORM_DESKTOP
void EGA_Raylib_GetMouseCoords(u16 *x, u16 *y) {
    Vector2 mousePos = GetMousePosition();
    mousePos.x = (mousePos.x - ega_state.dest_rect.x) / (ega_state.dest_rect.width / 320);
    mousePos.y = (mousePos.y - ega_state.dest_rect.y) / (ega_state.dest_rect.height / 200);

    bool shouldHide = true;

    if (mousePos.x < 0) {
        mousePos.x = 0;
        shouldHide = false;
    }

    if (mousePos.x > 319) {
        mousePos.x = 319;
        shouldHide = false;
    }

    if (mousePos.y < 0) {
        mousePos.y = 0;
        shouldHide = false;
    }

    if (mousePos.y > 199) {
        mousePos.y = 199;
        shouldHide = false;
    }

    if (shouldHide) {
        HideCursor();
    } else {
        if (IsCursorHidden()) {
            ShowCursor();
        }
    }

    *x = (int) mousePos.x;
    *y = (int) mousePos.y;
}

#endif

void EGA_ClearScreen(void) {
#ifdef PLATFORM_DOS
    EGA_SetPlanes(15);
    EGA_SetMask(15);
    EGA_SetRotate(0, 0);
#else
    ImageClearBackground(&ega_state.pages[ega_state.draw_page], BLACK);
#endif
}

#ifdef PLATFORM_DESKTOP
Image EGA_Raylib_GetBackBuffer(void) {
    return ega_state.pages[ega_state.draw_page];
}
#endif


#endif
#endif
