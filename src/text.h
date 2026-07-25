#ifndef TEXT_H
#define TEXT_H

#include <stdio.h>

#include "neo.h"

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
#ifdef NEO_TEXT_IMPLEMENTATION

static struct
{
    unsigned short _did_init;

    int width, height;

    // In DOS, this points directly to video memory
    // (generally, the offscreen page)
    textattr_t *buf;

#ifdef PLATFORM_DESKTOP
    Image mainImage;
    Image fontImage;
    Texture fontTexture;
    RenderTexture2D target;
    Rectangle dest_rect;
    int window_width, window_height;
    Vector2 dpi;
    float maxScale;
    int frameCount;
    double fpsTime;
#else
    // Current offscreen page
    int page;

    bool swapMode;

    // Backbuffer for swap mode 1 - this memory is allocated on init
    textattr_t *backBuffer;
#endif

} state;

#ifdef PLATFORM_DESKTOP
static const Color EGA_PALETTE[16] = {
    {0x00, 0x00, 0x00, 0xFF},  /* 0:  Black         */
    {0x00, 0x00, 0xAA, 0xFF},  /* 1:  Blue          */
    {0x00, 0xAA, 0x00, 0xFF},  /* 2:  Green         */
    {0x00, 0xAA, 0xAA, 0xFF},  /* 3:  Cyan          */
    {0xAA, 0x00, 0x00, 0xFF},  /* 4:  Red           */
    {0xAA, 0x00, 0xAA, 0xFF},  /* 5:  Magenta       */
    {0xAA, 0x55, 0x00, 0xFF},  /* 6:  Brown         */
    {0xAA, 0xAA, 0xAA, 0xFF},  /* 7:  Light Gray    */
    {0x55, 0x55, 0x55, 0xFF},  /* 8:  Dark Gray     */
    {0x55, 0x55, 0xFF, 0xFF},  /* 9:  Light Blue    */
    {0x55, 0xFF, 0x55, 0xFF},  /* 10: Light Green   */
    {0x55, 0xFF, 0xFF, 0xFF},  /* 11: Light Cyan    */
    {0xFF, 0x55, 0x55, 0xFF},  /* 12: Light Red     */
    {0xFF, 0x55, 0xFF, 0xFF},  /* 13: Light Magenta */
    {0xFF, 0xFF, 0x55, 0xFF},  /* 14: Yellow        */
    {0xFF, 0xFF, 0xFF, 0xFF},  /* 15: White         */
};
#endif

void Neo_Text_WriteCharEx(int x, int y, unsigned char ch, unsigned char color, unsigned char mask)
{
    textattr_t *a = Neo_Text_Ptr(x, y);
    a->ch = ch;
    a->attr = (a->attr & ~mask) | (color & mask);
}

textattr_t *Neo_Text_Ptr(int x, int y)
{
#ifdef PLATFORM_DOS
    if (state.swapMode) {
        return &state.backBuffer[y * state.width + x];
    } else {
        return &state.buf[y * state.width + x];
    }
#else
    return &state.buf[y * state.width + x];
#endif
}

void Neo_Text_TextBox(int x, int y, int w, int h)
{
    int right = x + w - 1;
    int bottom = y + h - 1;
    int i, j;
    Neo_Text_WriteCharEx(x, y, 201, 15, 0xff);
    Neo_Text_WriteCharEx(right, y, 187, 15, 0xff);
    Neo_Text_WriteCharEx(x, bottom, 200, 15, 0xff);
    Neo_Text_WriteCharEx(right, bottom, 188, 15, 0xff);

    for (i = x + 1; i < right; i ++)
    {
       Neo_Text_WriteCharEx(i, y, 205, 15, 0xff);
       Neo_Text_WriteCharEx(i, bottom, 205, 15, 0xff);
    }

    for (i = y + 1; i < bottom; i++)
    {
        Neo_Text_WriteCharEx(x, i, 186, 15, 0xff);
        Neo_Text_WriteCharEx(right, i, 186, 15, 0xff);

        for (j = x + 1; j < right; j ++)
        {
            Neo_Text_WriteCharEx(j, i, 0, 15, 0xff);
        }
    }

}

void Neo_Text_DrawStringEx(int x, int y, const char *str, unsigned char color, unsigned char mask)
{
    int i, j = 0;
    int left = x;
    int right = x + strlen(str);
    if (right >= state.width)
    {
        right = state.width;
    }

    for (i = left; i < right; i++)
    {
        Neo_Text_WriteCharEx(i, y, str[j], color, mask);
        j ++;
    }
}

void Neo_Text_DrawString(int x, int y, const char *str)
{
    Neo_Text_DrawStringEx(x, y, str, 7, 0xff);
}

void Neo_Text_DrawColorStringEx(int x, int y, const char *str, unsigned char color, unsigned char mask)
{
    unsigned char ch;
    char *src = (char *) str;
    textattr_t *dst = &state.buf[y * state.width + x];
    int i = 0;
    int l = strlen(str);

    while (x < state.width && i < l)
    {
        ch = *src;
        if (ch == '^')
        {
            src ++;
            i++;

            ch = *src;
            if (ch >= '0' && ch <= '9')
            {
                color = ch - '0';
                src++;
                i++;
                continue;
            }

            if (ch >= 'A' && ch <= 'F')
            {
                color = ch - 55;
                src++;
                i++;
                continue;
            }
        }

        dst->ch = *src++;
        dst->attr = dst->attr & ~mask | (color & mask);
        x ++;
        i ++;
        dst ++;
    }
}

void Neo_Text_FillRectEx(int x, int y, int w, int h, u8 ch, u8 color, u8 mask)
{
    int i, j;
    for (j = y; j < y + h; j++) {
        for (i = x; i < x + w; i++) {
            Neo_Text_WriteCharEx(i, j, ch, color, mask);
        }
    }
}

#ifdef NEO_WEB
void OnCanvasResize(int width, int height, float devicePixelRatio) {
    printf("OnCanvasResize %d %d\n", width, height);
    // printf(" --- %d %d\n", Engine::GetScreenWidth(), Engine::GetScreenHeight());
    //    if(!IsWindowFullscreen()) {
    SetWindowSize(width, height);
    // Engine::canvasWidth = width;
    // Engine::canvasHeight = height;
    //    }
}

#endif
void Neo_Text_SwapBuffers(void) {
#ifdef PLATFORM_DOS
    void *src, *dst;
    unsigned char page = state.page;

    if (state.swapMode) {
        // Copy backbuffer to target
        src = state.backBuffer;
        dst = state.buf;
        // memcpy(dst, src, state.width * state.height * 2);
        memcpy(dst, src, state.width * state.height / 2);
    }

    // Flip page
    asm {
        mov ah, 05h
        mov al, page
        int 10h
    };
    state.page = !state.page;
    // state.buf = MK_FP(0xB800, (state.width * state.height * 2) * state.page);
    state.buf = MK_FP(0xB800, 0x1000 * state.page);
    while ((inportb(0x3da) & 0x08) != 0);
    while ((inportb(0x3da) & 0x08) == 0);

#else

    state.frameCount ++;
    if (GetTime() - state.fpsTime >= 1.0)
    {
        state.fpsTime = GetTime();
        // LogInfo("FPS: %d", state.frameCount);
        state.frameCount = 0;
    }
    Vector2 dpi;
#ifdef NEO_WEB
    dpi = (Vector2) {1.0f, 1.0f};
#else
    dpi = GetWindowScaleDPI();
#endif

    if (dpi.x != state.dpi.x || dpi.y != state.dpi.y)
    {
#ifdef _WIN32
        // Hack for windows
        state.window_width = state.width * 8 * 2 * dpi.x;
        state.window_height = state.height * 16 * 2 * dpi.y;
#else
        // Logical size
        state.window_width = state.width * 8 * 2;
        state.window_height = state.height * 16 * 2;
#endif
#ifndef NEO_WEB
        SetWindowSize(state.window_width, state.window_height);
#endif
    }

    state.dpi = dpi;

    int screenWidth = GetScreenWidth();
    int screenHeight = GetScreenHeight();


#ifdef NEO_WEB
// LogInfo("%d %d, %d %d", screenWidth, screenHeight, GetRenderWidth(), GetRenderHeight());
// SetWindowSize(GetScreenWidth(), GetScreenHeight());
    #endif

    float bbWidth = state.width * 8;
    float bbHeight = state.height * 16;

    int scaleX = (int) floorf((float) screenWidth / bbWidth);
    int scaleY = (int) floorf((float) screenHeight / bbHeight);
    #define MIN(x, y) ((x) < (y) ? (x) : (y))
    int scale = MIN(scaleX, scaleY);

    if (state.maxScale != 0 && scale > state.maxScale * dpi.x)
    {
        scale = state.maxScale * dpi.x;
    }
    int w = bbWidth * scale;
    int h = bbHeight * scale;

    BeginTextureMode(state.target);

    for (int y = 0; y < state.height; y++)
    {
        for (int x = 0; x < state.width; x++)
        {
            textattr_t a = state.buf[y * state.width + x];

            int row = a.ch / 16;
            int col = a.ch % 16;

            Rectangle srcRect = {col * 8, row * 16, 8, 16};
            Rectangle dstRect = {x * 8, y * 16, 8, 16};

            DrawRectangleRec(dstRect, EGA_PALETTE[a.attr >> 4]);
            DrawTexturePro(state.fontTexture, srcRect, dstRect, (Vector2){0, 0}, 0.0f, EGA_PALETTE[a.attr & 0xf]);

            // ImageDrawRectangleRec(&state.mainImage, dstRect, EGA_PALETTE[a.attr >> 4]);
            // ImageDraw(&state.mainImage, state.fontImage, srcRect, dstRect, EGA_PALETTE[a.attr & 0xf]);
        }
    }

    EndTextureMode();
    // ImageDraw(&state.mainImage, state.fontImage, (Rectangle){0, 0, 64, 64}, (Rectangle){0,0,64,64}, WHITE);
    // UpdateTexture(state.mainTexture, state.mainImage.data);

    // Rectangle src = {
        // 0, 0, 80 * 8, 25 * 16
    // };
    Rectangle src = {
        0, 0, 80 * 8, -25 * 16
    };

    state.dest_rect = (Rectangle) {
        screenWidth / 2 - w / 2,
        screenHeight / 2 - h / 2,
        w, h
    };

    // state.dest_rect = (Rectangle) {
        // screenWidth / 2 - w / 2,
        // screenHeight / 2 - h / 2,
        0,
        // w,
        // -h
    // };

    DrawTexturePro(state.target.texture, src, state.dest_rect, (Vector2){0, 0}, 0.0f, WHITE);
#endif
}

void Neo_Text_Init(neo_text_init_params_t params)
{
    unsigned short mode = 3, b;
    unsigned short param = 0;

    // if (state._did_init == 0x11E0)
    // {
    //     return;
    // }
    //
    // state._did_init = 0x11E0;
    state.width = params.width;
    state.height = params.height;

#ifdef PLATFORM_DESKTOP

    state.maxScale = params.maxScale;

    state.buf = (textattr_t *) malloc(sizeof(textattr_t) * params.width * params.height);
    memset(state.buf, 0, sizeof(textattr_t) * params.width * params.height);

    InitWindow(state.width * 8, state.height * 16, "NEO");
    SetWindowPosition(20, 20);
    SetWindowState(FLAG_WINDOW_RESIZABLE);

    SetTargetFPS(60);
    // state.fontImage = LoadImage("dev/Px437_IBM_VGA8x16.png");
    state.fontImage = LoadImage(params.raylibFontPath);
    state.fontTexture = LoadTextureFromImage(state.fontImage);

    ImageColorReplace(&state.fontImage, BLACK, BLANK);
    // HideCursor();

    state.mainImage = GenImageColor(state.width * 8, state.height * 16, BLANK);

    state.target = LoadRenderTexture(state.width * 8, state.height * 16);
    SetTextureFilter(state.target.texture, TEXTURE_FILTER_POINT);
#else

    if (params.width == 80)
    {
        switch (params.height)
        {
            case 25:
                mode = 3;
                break;
            case 60:
                mode = 0x4f02;
                param = 0x108;
                break;
        }
        mode = 3;
    }

    if (params.width == 132)
    {
        if (params.height == 25) {
            mode = 0x4F02; param = 0x109;
        }

        if (params.height == 43) {
            mode = 0x4F02; param = 0x10A;
        }

        if (params.height == 50) {
            mode = 0x4F02; param = 0x10B;
        }

        if (params.height == 60) {
            mode = 0x4F02; param = 0x10C;
        }
    }

    asm {
        mov ax, mode
        mov bx, param
        int 10h
    }

    if (Neo_IsVGAAvailable())
    {
        outportb(0x3c4, 1);
        b = inportb(0x3c5);
        b = (b & 0xfe) | 1;
        outportb(0x3c5, b);

        b = inportb(0x3cc);
        b = b & 0xf3;
        outportb(0x3c2, b);
    }

    state.page = 1;
    // state.buf = MK_FP(0xB800, (state.width * state.height * 2) * state.page);
    state.buf = MK_FP(0xB800, 0x1000 * state.page);

    state.swapMode = params.dosSwapMode;

    if (state.swapMode) {
        state.backBuffer = malloc(params.width * params.height * sizeof(textattr_t));
    }

#endif
}

void Neo_Text_LoadFont(void *data)
{
#ifdef PLATFORM_DOS
    struct REGPACK reg;

    reg.r_ax = (0x11 << 8) | 0;
    reg.r_bx = (16 << 8) | 0;     // Bytes per char, 0
    reg.r_cx = 0xff; // Number of characters
    reg.r_dx = 0;    // Start at char code
    reg.r_es = FP_SEG(data);
    reg.r_bp = FP_OFF(data);

    intr(0x10, &reg);
#endif
}

void Neo_Text_Close(void)
{
#ifdef PLATFORM_DESKTOP
#else
    asm {
        mov ah, 5
        mov al, 0
        int 10h

        mov ax, 3
        mov bx, 0
        int 10h
    }
#endif
}
#endif
#endif
