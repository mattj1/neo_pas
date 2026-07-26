#ifndef NEO_H
#define NEO_H
#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <stdlib.h>

#ifdef NEO_WEB
#include <emscripten.h>
#endif

#ifdef PLATFORM_DOS
#include <conio.h>
#include <dos.h>
#endif

#ifdef PLATFORM_DESKTOP
#include <math.h>
#include <stdint.h>
#include <stdbool.h>
#endif

#ifndef bool
#ifndef __APPLE__
typedef unsigned char bool;
#else
// typedef unsigned char bool;
#endif
// #define true 1
// #define false 0
#endif

#ifdef PLATFORM_DOS
#ifndef uint8_t
#define uint8_t unsigned char
#endif
#ifndef int8_t
#define int8_t char
#endif
#ifndef int16_t
#define int16_t short
#endif
#ifndef uint16_t
#define uint16_t unsigned short
#endif
typedef unsigned long uint32_t;

#endif

typedef uint8_t u8;
typedef int16_t i16;
typedef uint16_t u16;

#define MAX_EVENTS 64

typedef enum
{
    kNone = 0x00, kEsc = 0x01, k1 = 0x02, k2 = 0x03, k3 = 0x04, k4 = 0x05,
    k5 = 0x06, k6 = 0x07, k7 = 0x08, k8 = 0x09, k9 = 0x0A, k0 = 0x0B,
    kMinus = 0x0C, kEqual = 0x0D, kBack = 0x0E, kTab = 0x0F, kQ = 0x10,
    kW = 0x11, kE = 0x12, kR = 0x13, kT = 0x14, kY = 0x15, kU = 0x16, kI = 0x17,
    kO = 0x18, kP = 0x19, kLBracket = 0x1A, kRBracket = 0x1B, kEnter = 0x1C, kCtrl = 0x1D,
    kA = 0x1E, kS = 0x1F, kD = 0x20, kF = 0x21, kG = 0x22, kH = 0x23,
    kJ = 0x24, kK = 0x25, kL = 0x26, kColon = 0x27, kQuote = 0x28, kTilde = 0x29,
    kLShift = 0x2A, kBackSlash = 0x2B, kZ = 0x2C, kX = 0x2D, kC = 0x2E, kV = 0x2F,
    kB = 0x30, kN = 0x31, kM = 0x32, kComma = 0x33, kPeriod = 0x34, kSlash = 0x35,
    kRShift = 0x36, kPadStar = 0x37, kAlt = 0x38, kSpace = 0x39, kCaps = 0x3A, kF1 = 0x3B, kF2 = 0x3C, kF3 = 0x3D,
    kF4 = 0x3E, kF5 = 0x3F, kF6 = 0x40, kF7 = 0x41, kF8 = 0x42, kF9 = 0x43, kF10 = 0x44, kNum = 0x45,
    kScroll = 0x46, kHome = 0x47, kUp = 0x48, kPgUp = 0x49, kPadMinus = 0x4A, kLf = 0x4B, kPad5 = 0x4C, kRt = 0x4D,
    kPadPlus = 0x4E, kEnd = 0x4F, kDn = 0x50, kPgDn = 0x51, kIns = 0x52, kDel = 0x53, kSysReq = 0x54, kUnknown55 = 0x55,
    kUnknown56 = 0x56, kF11 = 0x57, kF12 = 0x58, kMAX = 0x59
} ScanCode;

enum
{
    SE_NONE,
    SE_KEYDOWN,
    SE_KEYUP,
    SE_KEYCHAR
};

#include "buffer.h"

typedef struct neo_event_s
{
    int eventType;
    int param;
    int param2;
} neo_event_t;

typedef struct
{
    unsigned short* data;
    unsigned short length;
} neo_sfx_t;

typedef void (*NeoUpdateProc)(void);
typedef void (*NeoDrawProc)(void);
typedef void (*NeoEventProc)(neo_event_t *event);
typedef struct neo_config_s
{
    const char* app_name;
    const char* logFilePath;
    NeoUpdateProc updateFunc;
    NeoDrawProc drawFunc;
    NeoEventProc eventFunc;
} neo_config_t;

extern void Neo_Event_GetEvents(void);
extern void Neo_Event_ProcessEvents(void);
extern void Neo_Event_Add(int eventType, int param, int param2);
extern void Neo_Event_ClearKeyCharQueue(void);
extern bool Neo_Event_GetKeyChar(uint8_t *ch);

extern bool Neo_Sound_Init(void);
extern neo_sfx_t Neo_Sound_LoadEffect(neo_buf_reader_t *reader);
extern void Neo_Sound_FreeEffect(neo_sfx_t sfx);
extern void Neo_Sound_PlaySound(neo_sfx_t *sfx);
extern bool Neo_Sound_IsValidEffect(neo_sfx_t sfx);

extern void Neo_Keyboard_Init(void);
extern bool Neo_IsKeyDown(ScanCode sc);
extern bool Neo_WasKeyDown(ScanCode sc);

void Neo_Mouse_GetStatus(unsigned short* x, unsigned short* y, unsigned short* buttons);

uint32_t Neo_Timer_GetTicks(void);
extern void Neo_Timer_Init(void);


extern void Neo_ClearKeyData(void);
extern void Neo_Init(neo_config_t config);
extern void Neo_Run(void);
extern void Neo_Shutdown(void);
bool Neo_ShouldQuit(void);
void Neo_Quit(void);
#ifdef PLATFORM_DOS
void Neo_Panic(const char *format, ...);
#else
void Neo_Panic(const char *format, ...) __attribute__ ((__noreturn__));
#endif
void LogInfo(const char* format, ...);

bool Neo_IsEGAAvailable(void);
bool Neo_IsVGAAvailable(void);

#endif  // NEO_H
