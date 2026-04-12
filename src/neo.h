#ifndef NEO_H
#define NEO_H
#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <stdlib.h>

#ifdef PLATFORM_DOS
#include <conio.h>
#include <dos.h>
#endif

#ifdef PLATFORM_DESKTOP
#include <raylib.h>
#include <math.h>
#include <stdint.h>
#endif

#ifndef bool
typedef unsigned char bool;
#define true 1
#define false 0
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

typedef struct neo_buffer_reader_s neo_buffer_reader_t;

typedef void (*neo_buffer_close_proc)(struct neo_buffer_reader_s* reader);
typedef long (*neo_buffer_get_pos_proc)(struct neo_buffer_reader_s* reader);
typedef void (*neo_buffer_seek_proc)(struct neo_buffer_reader_s* reader, long pos);
typedef bool (*neo_buffer_read_data_proc)(struct neo_buffer_reader_s* reader, void* data, size_t length);

struct neo_buffer_reader_s
{
    FILE* file;
    void* data;
    void* userdata;
    long pos;

    neo_buffer_read_data_proc readData;
    neo_buffer_get_pos_proc getPos;
    neo_buffer_close_proc close;
    neo_buffer_seek_proc seek;
};

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

extern bool Neo_Buf_ReadByte(neo_buffer_reader_t* reader, unsigned char* out);
extern bool Neo_Buf_ReadData(neo_buffer_reader_t* reader, void* dst, size_t length);
extern bool Neo_Buf_ReadUShort(neo_buffer_reader_t* reader, unsigned short* out);
extern bool Neo_Buf_ReadShort(neo_buffer_reader_t* reader, short* out);
extern bool Neo_Buf_ReadString(neo_buffer_reader_t *reader, char *out, size_t bufLen);
extern bool Neo_Buf_IsReaderValid(neo_buffer_reader_t reader);

extern long Neo_Buf_GetReadPos(neo_buffer_reader_t* reader);
extern void Neo_Buf_Seek(neo_buffer_reader_t* reader, long pos);
extern void Neo_Buf_CreateReaderForMemory(neo_buffer_reader_t* reader, void* data);
extern void Neo_Buf_CreateReaderForFile(neo_buffer_reader_t* reader, FILE* file);
extern void Neo_Buf_CloseReader(neo_buffer_reader_t* reader);

extern void Neo_Event_GetEvents(void);
extern void Neo_Event_ProcessEvents(void);
extern void Neo_Event_Add(int eventType, int param, int param2);
extern void Neo_Event_ClearKeyCharQueue(void);
extern bool Neo_Event_GetKeyChar(uint8_t *ch);

extern bool Neo_Sound_Init(void);
extern neo_sfx_t Neo_Sound_LoadEffect(neo_buffer_reader_t *reader);
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

#ifdef NEO_IMPLEMENTATION

#ifdef PLATFORM_DESKTOP

static ScanCode _raylibKeyToScancode[400] = {
    [32] = kSpace,
    [65] = kA,
    [68] = kD,
    [69] = kE,
    [73] = kI,
    [79] = kO,
    [80] = kP,
    [81] = kQ,
    [83] = kS,
    [87] = kW,
    [96] = kTilde,
    [257] = kEnter,
    [265] = kUp,
    [264] = kDn,
    [263] = kLf,
    [262] = kRt,
};

static KeyboardKey neo_scanCodeToRaylibKey[kMAX] = {
    0,
    KEY_ESCAPE,
    KEY_ONE,
    KEY_TWO,
    KEY_THREE,
    KEY_FOUR,
    KEY_FIVE,
    KEY_SIX,
    KEY_SEVEN,
    KEY_EIGHT,
    KEY_NINE,
    KEY_ZERO,
    KEY_MINUS,
    KEY_EQUAL,
    KEY_BACKSPACE,
    KEY_TAB,

    // 0x10...
    KEY_Q,
    KEY_W,
    KEY_E,
    KEY_R,
    KEY_T,
    KEY_Y,
    KEY_U,
    KEY_I,
    KEY_O,
    KEY_P,
    KEY_LEFT_BRACKET,
    KEY_RIGHT_BRACKET,
    KEY_ENTER,
    KEY_LEFT_CONTROL,
    KEY_A,
    KEY_S,

    // 0x20...
    KEY_D,
    KEY_F,
    KEY_G,
    KEY_H,
    KEY_J,
    KEY_K,
    KEY_L,
    KEY_SEMICOLON,
    KEY_APOSTROPHE,
    KEY_GRAVE,
    KEY_LEFT_SHIFT,
    KEY_BACKSLASH,
    KEY_Z,
    KEY_X,
    KEY_C,
    KEY_V,

    // 0x30...
    KEY_B,
    KEY_N,
    KEY_M,
    KEY_COMMA,
    KEY_PERIOD,
    KEY_SLASH,
    KEY_RIGHT_SHIFT,
    KEY_KP_MULTIPLY,
    KEY_LEFT_ALT,
    KEY_SPACE,
    KEY_CAPS_LOCK,
    KEY_F1,
    KEY_F2,
    KEY_F3,
    KEY_F4,
    KEY_F5,

    // 0x40...
    KEY_F6,
    KEY_F7,
    KEY_F8,
    KEY_F9,
    KEY_F10,
    KEY_NUM_LOCK,
    KEY_SCROLL_LOCK,
    KEY_KP_7,
    KEY_KP_8,
    KEY_KP_9,
    KEY_KP_SUBTRACT,
    KEY_KP_4,
    KEY_KP_5,
    KEY_KP_6,
    KEY_KP_ADD,
    KEY_KP_1,

    // 0x50...
    KEY_KP_2,
    KEY_KP_3,
    KEY_KP_0,
    KEY_KP_DECIMAL,
    0,           // 0x54 sc_alt_printScreen - no direct raylib equivalent
    0,           // 0x55 unused
    0,           // 0x56 sc_bracketAngle - no standard raylib equivalent
    KEY_F11,
    KEY_F12,
};
#endif

typedef struct
{
    neo_sfx_t* curSound;
    // Update timer
    unsigned short ticks;

    unsigned short curFreq;
    unsigned short curSample;
#ifdef PLATFORM_DESKTOP
    AudioStream stream;
    unsigned int runningSampleIndex;
#endif
} neo_sound_state_t;

typedef struct
{
    // Current state of keys
    unsigned char current_keys[256];

    // Keys that were pressed down this frame
    unsigned char pressed_keys[256];

    // Keys that were released this frame
    unsigned char released_keys[256];

    unsigned char keyCharQueue[16];
    int keyCharHead, keyCharTail;
} neo_keyboard_state_t;

static struct
{
    neo_config_t config;
    neo_event_t events[MAX_EVENTS];

    bool did_shutdown;
    bool keyboard_did_init;
    bool mouse_did_init;
    bool done;

    int16_t event_head;
    int16_t event_tail;


    struct
    {
        bool did_init;
        unsigned short tick_count;
        unsigned short accum;
        unsigned short old_timer_ticks;
        unsigned short old_timer_tick_count;
    } timer;

    neo_keyboard_state_t keyboard;

    neo_sound_state_t sound;

    struct
    {
        FILE* logFile;
    } log;

    struct
    {
        char msg[32][100];
    } console;

#ifdef PLATFORM_DOS
    void interrupt far(* timer_old_int)();
    void interrupt far(* keyboard_old_int)();
#endif
} neo_state;

#pragma region Buffer
#pragma mark - Buffer

static bool _FileReadData(neo_buffer_reader_t* reader, void* data, size_t length)
{
    int numRead = fread(data, 1, length, reader->file);
    return numRead == length;
}

static long _FileGetPos(neo_buffer_reader_t* reader)
{
    return ftell(reader->file);
}

static void _FileSeek(neo_buffer_reader_t* reader, long pos)
{
    fseek(reader->file, pos, SEEK_SET);
}

static void _FileClose(neo_buffer_reader_t* reader)
{
    if (reader->file)
    {
        fclose(reader->file);
        reader->file = NULL;
    }
}

static bool _MemoryReadData(neo_buffer_reader_t* reader, void* data, size_t length)
{
    // TODO: Check buffer size...
    uint8_t* src = (uint8_t*)reader->data + reader->pos;
    memcpy(data, src, length);
    reader->pos += length;
    return true;
}

static long _MemoryGetPos(neo_buffer_reader_t* reader)
{
    return reader->pos;
}

static void _MemorySeek(neo_buffer_reader_t* reader, long pos)
{
    reader->pos = pos;
}

bool Neo_Buf_ReadData(neo_buffer_reader_t* reader, void* dst, size_t length)
{
    return reader->readData(reader, dst, length);
}

bool Neo_Buf_ReadByte(neo_buffer_reader_t* reader, unsigned char* out)
{
    return Neo_Buf_ReadData(reader, out, 1);
}

bool Neo_Buf_ReadUShort(neo_buffer_reader_t* reader, unsigned short* out)
{
    return Neo_Buf_ReadData(reader, out, 2);
}

bool Neo_Buf_ReadShort(neo_buffer_reader_t* reader, short* out)
{
    return Neo_Buf_ReadData(reader, out, 2);
}

bool Neo_Buf_ReadString(neo_buffer_reader_t *reader, char *out, size_t bufLen)
{
    uint8_t len;
    if (!Neo_Buf_ReadByte(reader, &len))
    {
        return false;
    }

    if (len >= bufLen)
    {
        return false;
    }

    memset(out, 0, bufLen);

    return Neo_Buf_ReadData(reader, out, len);
}

extern bool Neo_Buf_IsReaderValid(neo_buffer_reader_t reader)
{
    return reader.data != NULL || reader.file != NULL;
}

long Neo_Buf_GetReadPos(neo_buffer_reader_t* reader)
{
    return reader->getPos(reader);
}

void Neo_Buf_Seek(neo_buffer_reader_t* reader, long pos)
{
    reader->seek(reader, pos);
}

void Neo_Buf_CreateReaderForMemory(neo_buffer_reader_t* reader, void* data)
{
    memset(reader, 0, sizeof(neo_buffer_reader_t));
    reader->data = data;
    reader->readData = _MemoryReadData;
    reader->getPos = _MemoryGetPos;
    reader->seek = _MemorySeek;
}

void Neo_Buf_CreateReaderForFile(neo_buffer_reader_t* reader, FILE* file)
{
    memset(reader, 0, sizeof(neo_buffer_reader_t));
    reader->file = file;
    reader->readData = _FileReadData;
    reader->getPos = _FileGetPos;
    reader->close = _FileClose;
    reader->seek = _FileSeek;
}

void Neo_Buf_CloseReader(neo_buffer_reader_t* reader)
{
    if (reader->close)
    {
        reader->close(reader);
    }
}

#pragma endregion


#pragma region Event
#pragma mark - Event


void Neo_Event_GetEvents(void)
{
#ifdef PLATFORM_DESKTOP
    while (true)
    {
        int charPressed = GetCharPressed();
        if (charPressed == 0)
        {
            break;
        }

        Neo_Event_Add(SE_KEYCHAR, charPressed, 0);
    }

    // while (true)
    // {
    //     int key = GetKeyPressed();
    //     if (key == 0)
    //         break;
    //     Neo_Event_Add(SE_KEYDOWN, _raylibKeyToScancode[key], 0);
    //     LogInfo("Key pressed: %d ---", key);
    // }

    for (int i = 0; i < 400; i++)
    {
        if (IsKeyPressed(i))
        {
            if (_raylibKeyToScancode[i] == 0) {
                LogInfo("Didn't handle raylib key down: %d", i);
            } else {
                // LogInfo("Key down (raylib): %d", i);
                Neo_Event_Add(SE_KEYDOWN, _raylibKeyToScancode[i], 0);
            }
        }
        if (IsKeyReleased(i))
        {
            Neo_Event_Add(SE_KEYUP, _raylibKeyToScancode[i], 0);
            // LogInfo("Key up (raylib): %d", i);
        }
    }

#endif
}

void Neo_Event_ProcessEvents(void)
{
    neo_event_t* event;

    while (neo_state.event_tail != neo_state.event_head)
    {
        neo_state.event_tail = (neo_state.event_tail + 1) & (MAX_EVENTS - 1);
        event = &neo_state.events[neo_state.event_tail];
        //        printf("process event %d: %d %d %d\n", neo_state.event_tail, event->eventType, event->param, event->param2);
        switch (event->eventType)
        {
        case SE_KEYDOWN:
            //                printf("SE_KEYDOWN: %d\n", event->param);
            neo_state.keyboard.current_keys[event->param] = 1;
            neo_state.keyboard.pressed_keys[event->param] = 1;

            break;
        case SE_KEYUP:
            //                printf("SE_KEYUP: %d\n", event->param);
            neo_state.keyboard.current_keys[event->param] = 0;
            neo_state.keyboard.released_keys[event->param] = 1;
            break;
        case SE_KEYCHAR:
            // if keycharfunc...
            // lastkeychar =

            neo_state.keyboard.keyCharQueue[neo_state.keyboard.keyCharHead] = event->param;
            neo_state.keyboard.keyCharHead = (neo_state.keyboard.keyCharHead + 1) & 15;
            //                printf("SE_KEYCHAR: %c (%d)\n", event->param, event->param);
            break;
        default:
            //                printf("Didn't process event %d\n", event->eventType);
            break;
        }

        if (neo_state.config.eventFunc)
        {
            neo_state.config.eventFunc(event);
        }
    }
}

void Neo_Event_ClearKeyCharQueue(void)
{
    neo_state.keyboard.keyCharHead = 0;
    neo_state.keyboard.keyCharTail = 0;
    neo_state.keyboard.keyCharQueue[0] = 0;
}

bool Neo_Event_GetKeyChar(uint8_t *ch)
{
    neo_keyboard_state_t *k = &neo_state.keyboard;

    if (k->keyCharHead == k->keyCharTail) {
        return false;
    }

    *ch = k->keyCharQueue[k->keyCharTail];

    //k->keyCharQueue[k->keyCharTail] = 0;

    k->keyCharTail = (k->keyCharTail + 1) & 15;

    return true;
}

void Neo_Event_Add(int eventType, int param, int param2)
{
    neo_event_t* event;

    int nextHead = (neo_state.event_head + 1) & (MAX_EVENTS - 1);
    if (nextHead != neo_state.event_tail)
    {
        //        printf("Add event %d: %d %d %d\n", nextHead, eventType, param, param2);
        event = &neo_state.events[nextHead];
        event->eventType = eventType;
        event->param = param;
        event->param2 = param2;

        neo_state.event_head = nextHead;
    }
    else
    {
        //        printf("Didn't add event!\n");
    }
}

#pragma endregion
#pragma region Keyboard
#pragma mark - Keyboard
#ifdef PLATFORM_DOS

unsigned char scancode_lower[] = {
    0, 27, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 8,
    9, 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', 13,
    0, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'', '`',
    0, '\\', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0,
    '*', 0, ' '
};

unsigned char scancode_upper[] = {
    0, 27, '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '+', 8,
    9, 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '{', '}', 13,
    0, 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ':', '"', '~',
    0, '|', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '<', '>', '?', 0,
    '*', 0, ' '
};

static void interrupt _DOS_KeyISR(void)
{
    unsigned char scancode = inportb(0x60);
    unsigned char temp;
    unsigned char keyChar = 0;
    outportb(0x61, (temp = inportb(0x61)) | 0x80);
    outportb(0x61, temp);

    if (scancode == 224)
    {
    }
    else
    {
        if (scancode & 0x80)
        {
            scancode &= 0x7f;

            // If this key isn't already down, send a down event
            // Send a char event

            neo_state.keyboard.current_keys[scancode] = 0;
            neo_state.keyboard.released_keys[scancode] = 1;

            //            printf("DOS Key ISR: Released %d\n", scancode);

            Neo_Event_Add(SE_KEYUP, scancode, 0);
        }
        else
        {
            keyChar = scancode_lower[scancode];

            if (neo_state.keyboard.current_keys[kLShift] || neo_state.keyboard.current_keys[kRShift])
            {
                keyChar = scancode_upper[scancode];
            }

            if (!neo_state.keyboard.current_keys[scancode])
            {
                //                printf("DOS Key ISR: Pressed  %d\n", scancode);
                Neo_Event_Add(SE_KEYDOWN, scancode, 0);
            }

            //            printf("DOS Key ISR: Char %c\n", keyChar);

            neo_state.keyboard.current_keys[scancode] = 1;
            neo_state.keyboard.pressed_keys[scancode] = 1;

            if (keyChar > 0)
            {
                Neo_Event_Add(SE_KEYCHAR, keyChar, 0);
            }
        }
    }

    outportb(0x20, 0x20);
}

#endif

#pragma region Sound
#pragma mark - Sound


static void _Sound_Update(void)
{
    neo_sound_state_t *s = &neo_state.sound;

    if (s->curSound != NULL)
    {
        s->curFreq = 0;

        if (s->curSample >= s->curSound->length)
        {
            s->curSound = NULL;
        } else
        {
            s->curFreq = s->curSound->data[s->curSample];
        }

        s->curSample ++;

#ifdef PLATFORM_DOS
        if (s->curFreq == 0)
        {
            nosound();
        } else
        {
            sound(s->curFreq);
        }
#endif
    }
}

#ifdef PLATFORM_DESKTOP


static void _AudioInputCallback(void* data, unsigned int frames)
{
    neo_sound_state_t *s = &neo_state.sound;

    short toneVolume = 3000;
    short *d = data;
    for (unsigned int i = 0; i < frames; i++)
    {
        int toneHz = s->curFreq;
        *d = 0;

        if (toneHz != 0)
        {
            short sampleValue = 0;
            int squareWavePeriod = 22050 / toneHz;
            int halfSquareWavePeriod = squareWavePeriod >> 1;

            if (((s->runningSampleIndex / halfSquareWavePeriod) % 2) == 1)
            {
                sampleValue = toneVolume;
            }
            else
            {
                sampleValue = -toneVolume;
            }

            *d = sampleValue;
        }

        s->runningSampleIndex += 1;
        s->ticks++;
        // ~0.00689 sec/sample
        if (s->ticks > 151)
        {
            s->ticks = 0;
            _Sound_Update();
        }

        d++;
    }
}

#endif


void Neo_Sound_PlaySound(neo_sfx_t *sfx)
{
    neo_sound_state_t *s = &neo_state.sound;
    s->curSound = sfx;
    s->curSample = 0;
}

neo_sfx_t Neo_Sound_LoadEffect(neo_buffer_reader_t *reader)
{
    unsigned short *data;
    neo_sfx_t sfx = {NULL, 0};

    if (!Neo_Buf_ReadUShort(reader, &sfx.length))
    {
        return sfx;
    }

    data = (unsigned short *) malloc(sizeof(unsigned short) * sfx.length);
    if (!Neo_Buf_ReadData(reader, data, sizeof(unsigned short) * sfx.length))
    {
        free(data);
        data = NULL;
    }

    sfx.data = data;
    return sfx;
}

void Neo_Sound_FreeEffect(neo_sfx_t sfx)
{
    free(sfx.data);
}

bool Neo_Sound_IsValidEffect(neo_sfx_t sfx)
{
    return sfx.data != NULL;
}

bool Neo_Sound_Init(void)
{
#ifdef PLATFORM_DESKTOP
    InitAudioDevice();
    // SetAudioStreamBufferSizeDefault(4096);
    // SetAudioStreamBufferSizeDefault(2048);
    SetAudioStreamBufferSizeDefault(512);
    if (IsAudioDeviceReady())
    {
        neo_state.sound.stream = LoadAudioStream(22050, 16, 1);
        SetAudioStreamVolume(neo_state.sound.stream, 1.0);
        if (!IsAudioStreamValid(neo_state.sound.stream))
        {
            LogInfo("Audio stream not ready");
            return false;
        }

        neo_state.sound.curFreq = 0;
        SetAudioStreamCallback(neo_state.sound.stream, _AudioInputCallback);
        PlayAudioStream(neo_state.sound.stream);
        return true;
    }

    return false;
#else
    return true;
#endif
}

#pragma endregion

bool Neo_IsKeyDown(ScanCode sc)
{
    return neo_state.keyboard.current_keys[sc];
}

bool Neo_WasKeyDown(ScanCode sc)
{
    return neo_state.keyboard.current_keys[sc] || neo_state.keyboard.pressed_keys[sc];
}

void Neo_Keyboard_Init(void)
{
    if (!neo_state.keyboard_did_init)
    {
        neo_state.keyboard_did_init = true;

#ifdef PLATFORM_DOS
        neo_state.keyboard_old_int = _dos_getvect(0x09);
        _dos_setvect(0x09, _DOS_KeyISR);
#endif
    }
}

void Neo_Keyboard_Shutdown(void)
{
    if (neo_state.keyboard_did_init)
    {
        neo_state.keyboard_did_init = false;

#ifdef PLATFORM_DOS
        if (neo_state.keyboard_old_int != NULL)
        {
            _dos_setvect(0x09, neo_state.keyboard_old_int);
        }
#endif
    }
}


#ifdef PLATFORM_DOS
static void interrupt _DOS_TimerISR()
{
    neo_sound_state_t *s = &neo_state.sound;
    neo_state.timer.old_timer_tick_count--;
    neo_state.timer.tick_count += 1;
    neo_state.timer.accum += 72;

    while (neo_state.timer.accum >= 100)
    {
        neo_state.timer.tick_count += 1;
        neo_state.timer.accum -= 100;
    }

    if (neo_state.timer.old_timer_tick_count == 0)
    {
        neo_state.timer.old_timer_tick_count = neo_state.timer.old_timer_ticks;
        _chain_intr(neo_state.timer_old_int);
    }

    outportb(0x20, 0x20);

    s->ticks ++;
    if (s->ticks == 4)
    {
        s->ticks = 0;
        _Sound_Update();
    }
}
#endif
#pragma endregion

#pragma region Mouse
#pragma mark - Mouse

void Neo_Mouse_GetStatus(unsigned short* mouse_x, unsigned short* mouse_y, unsigned short* mouse_buttons)
{
    unsigned short cursor_x, cursor_y, buttons;
#ifdef PLATFORM_DOS
    asm{
        mov ax, 3
        int 33h
        mov buttons, bx
        mov cursor_x, cx
        mov cursor_y, dx
        }

        * mouse_x = cursor_x;
    *mouse_y = cursor_y;
    *mouse_buttons = buttons;
#else
    *mouse_x = GetMouseX();
    *mouse_y = GetMouseY();
    *mouse_buttons = 0;
    if (IsMouseButtonDown(0))
    {
        *mouse_buttons |= 1;
    }
#endif
}

#pragma endregion


#pragma region Timer
#pragma mark - Timer
#ifdef PLATFORM_DOS
void Neo_Timer_SetClockRate(int numBits)
{
    unsigned long ticks = 65536 >> numBits;
    unsigned short t = ticks;
    neo_state.sound.ticks = 1;
    neo_state.timer.accum = 1;

    neo_state.timer.old_timer_ticks = 1 << numBits;
    neo_state.timer.old_timer_tick_count = neo_state.timer.old_timer_ticks;

    outportb(0x43, 0x36);
    outportb(0x40, t & 0xff);
    outportb(0x40, (t >> 8) & 0xff);
}
#endif
uint32_t Neo_Timer_GetTicks(void)
{
#ifdef PLATFORM_DOS
    return neo_state.timer.tick_count;
#else
    return (uint32_t)round(GetTime() * 1000);
#endif
}

void Neo_Timer_Init(void)
{
    if (!neo_state.timer.did_init)
    {
        neo_state.timer.did_init = true;
        neo_state.sound.ticks = 1;

#ifdef PLATFORM_DOS
        neo_state.timer_old_int = _dos_getvect(0x08);
        _dos_setvect(0x08, _DOS_TimerISR);
        Neo_Timer_SetClockRate(5);
#endif
    }
}

void Neo_Timer_Shutdown(void)
{
    if (neo_state.timer.did_init)
    {
        neo_state.timer.did_init = false;

#ifdef PLATFORM_DOS
        Neo_Timer_SetClockRate(0);
        if (neo_state.timer_old_int != NULL)
        {
            _dos_setvect(0x08, neo_state.timer_old_int);
        }
#endif
    }
}
#pragma endregion

#pragma region Loop
#pragma mark - Loop
void Neo_Run(void)
{
#ifdef PLATFORM_DOS
    while (!neo_state.done)
    {
        Neo_ClearKeyData();
        Neo_Event_GetEvents();
        Neo_Event_ProcessEvents();

        if (Neo_ShouldQuit())
        {
            break;
        }

        if (neo_state.config.updateFunc)
        {
            neo_state.config.updateFunc();
        }

        if (neo_state.config.drawFunc)
        {
            neo_state.config.drawFunc();
        }
    }
#else
    while (!neo_state.done)
    {
        Neo_ClearKeyData();
        Neo_Event_GetEvents();
        Neo_Event_ProcessEvents();

        if (neo_state.config.updateFunc)
        {
            neo_state.config.updateFunc();
        }

        BeginDrawing();
        ClearBackground(BLACK);

        if (neo_state.config.drawFunc)
        {
            neo_state.config.drawFunc();
        }

        EndDrawing();

        if (WindowShouldClose())
        {
            Neo_Quit();
        }
    }
#endif
}
#pragma endregion

void Neo_Init(neo_config_t config)
{
#ifdef PLATFORM_DOS
    textmode(C80);
    clrscr();
    textattr(7);
    textbackground(4);
    cprintf("                                                                                \n");
    gotoxy(40 - strlen(config.app_name) / 2, 1);
    cprintf("%s\n\n", config.app_name);
    gotoxy(1, 2);
    textattr(7);
    textbackground(0);
#endif

    // int a = sizeof(neo_state);
    // printf("Size of int: %d, short: %d, state: %ld\n", sizeof(int), sizeof(unsigned short), sizeof(neo_state));
    memset(&neo_state, 0, sizeof(neo_state));
    neo_state.config = config;

    if (config.logFilePath)
    {
        neo_state.log.logFile = fopen(config.logFilePath, "wb");
    }
}

extern void Neo_Quit(void)
{
    neo_state.done = true;
}

bool Neo_ShouldQuit(void)
{
    return neo_state.done;
}

void Neo_ClearKeyData(void)
{
    memset(&neo_state.keyboard.pressed_keys, 0, sizeof(neo_state.keyboard.pressed_keys));
    memset(&neo_state.keyboard.released_keys, 0, sizeof(neo_state.keyboard.released_keys));
}

bool Neo_IsEGAAvailable(void)
{
#ifdef PLATFORM_DOS
    unsigned char result;
    asm{
        mov ax, 1200h
        mov bl, 10h
        mov cx, 0xFFFF
        int 10h
        inc cx
        mov al, cl
        or al, ch
        mov result, al
    }
    return result;
#else
    return true;
#endif
}

bool Neo_IsVGAAvailable(void)
{
#ifdef PLATFORM_DOS
    unsigned char result;
    asm{
        mov ax, 0x1a00
        int 10h

        // Check for VGA BIOS
        cmp al, 0x1a
        jne err

        // Check for VGA
        cmp bl, 8 // or 7?
        jb err

        // Check for unknown
        cmp bl, 0xff
        jz err
    }
    return true;
err:
    return false;
#else
    return true;
#endif
}

void Neo_Shutdown(void)
{
    if (!neo_state.did_shutdown)
    {
        neo_state.did_shutdown = true;

        printf("Neo_Shutdown\n");
        Neo_Keyboard_Shutdown();
        Neo_Timer_Shutdown();
        /*
         *     _Keybrd_Shutdown;
    _Mouse_Shutdown;
*/
#ifdef PLATFORM_DOS
        // asm mov al, $3 ; mov ah, 0 ; int $10 end; }
        //clrscr();
        textattr(7);
        textbackground(0);
#endif
        /*
         SND_Close;
         Text.Close;
     */
        /*
            {$ifndef fpc}
            Console_Dump;
            {$endif}
                 */
    }
}

void LogInfoV(const char *format, va_list args)
{
#ifdef PLATFORM_DOS
    vprintf(format, args);
    if (neo_state.log.logFile != NULL)
    {
        vfprintf(neo_state.log.logFile, format, args);
        fputs("\r\n", neo_state.log.logFile);
    }
    putchar('\n');
#else
    char buffer[1024];
    vsnprintf(buffer, sizeof(buffer), format, args);
    TraceLog(LOG_INFO, "%s", buffer);
#endif
}

void Neo_Panic(const char *format, ...)
{
    va_list args;
    va_start(args, format);
    LogInfoV(format, args);
    va_end(args);

    exit(1);
}

void LogInfo(const char* format, ...)
{
    va_list args;
    va_start(args, format);
    LogInfoV(format, args);
    va_end(args);
}

#endif  // NEO_IMPLEMENTATION
#endif  // NEO_H
