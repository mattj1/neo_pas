#ifndef TEXT_H
#define TEXT_H

#include <stdio.h>

#include "../neo.h"

#ifdef PLATFORM_DOS
#include <dos.h>
#else
#include <raylib.h>
#include <math.h>
#include <stdint.h>
#endif

typedef struct neo_text_init_params_t neo_text_init_params_t;

struct neo_text_init_params_t
{
    int width, height;
    float maxScale;
    /**
     * 0 = Write directly to offscreen VRAM page and swap
     * 1 = Write to RAM buffer, which is then copied to an offscreen VRAM page and swapped
     */
    bool dosSwapMode;
    const char *raylibFontPath;
};

typedef struct
{
    unsigned char ch;
    unsigned char attr;
} textattr_t;

extern void Neo_Text_WriteCharEx(int x, int y, unsigned char ch, unsigned char color, unsigned char mask);
extern void Neo_Text_TextBox(int x, int y, int w, int h);
extern void Neo_Text_DrawStringEx(int x, int y, const char *str, unsigned char color, unsigned char mask);
extern void Neo_Text_DrawString(int x, int y, const char *str);
extern void Neo_Text_DrawColorStringEx(int x, int y, const char *string, unsigned char color, unsigned char mask);
extern void Neo_Text_FillRectEx(int x, int y, int w, int h, u8 ch, u8 color, u8 mask);

extern void Neo_Text_Init(neo_text_init_params_t params);
extern void Neo_Text_Close(void);
extern void Neo_Text_LoadFont(void *data);

extern void Neo_Text_SwapBuffers(void);

extern textattr_t *Neo_Text_Ptr(int x, int y);
#endif
