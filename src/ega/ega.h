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
    void *data;
#ifndef PLATFORM_DOS
    Image raylib_image;
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

#endif
