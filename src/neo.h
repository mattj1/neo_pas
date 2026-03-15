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
typedef unsigned char uint8_t;
typedef char int8_t;
typedef int int16_t;
typedef unsigned int uint16_t;
typedef unsigned long uint32_t;

#endif

typedef enum {
    kNone = 0x00,    kEsc = 0x01,    k1 = 0x02,    k2 = 0x03,    k3 = 0x04,    k4 = 0x05,
    k5 = 0x06,    k6 = 0x07,    k7 = 0x08,    k8 = 0x09,    k9 = 0x0A,    k0 = 0x0B,
    kMinus = 0x0C,    kEqual = 0x0D,    kBack = 0x0E,    kTab = 0x0F,    kQ = 0x10,
    kW = 0x11,    kE = 0x12,    kR = 0x13,    kT = 0x14,    kY = 0x15,    kU = 0x16,    kI = 0x17,
    kO = 0x18,    kP = 0x19,    kLBracket = 0x1A,    kRBracket = 0x1B,    kEnter = 0x1C,    kCtrl = 0x1D,
    kA = 0x1E,    kS = 0x1F,    kD = 0x20,    kF = 0x21,    kG = 0x22,    kH = 0x23,
    kJ = 0x24,    kK = 0x25,    kL = 0x26,    kColon = 0x27,    kQuote = 0x28,    kTilde = 0x29,
    kLShift = 0x2A,    kBackSlash = 0x2B,    kZ = 0x2C,    kX = 0x2D,    kC = 0x2E,    kV = 0x2F,
    kB = 0x30,    kN = 0x31,    kM = 0x32,    kComma = 0x33,    kPeriod = 0x34,    kSlash = 0x35,
    kRShift = 0x36,    kPadStar = 0x37,    kAlt = 0x38,    kSpace = 0x39,    kCaps = 0x3A,    kF1 = 0x3B,    kF2 = 0x3C,    kF3 = 0x3D,
    kF4 = 0x3E,    kF5 = 0x3F,    kF6 = 0x40,    kF7 = 0x41,    kF8 = 0x42,    kF9 = 0x43,    kF10 = 0x44,    kNum = 0x45,
    kScroll = 0x46,    kHome = 0x47,    kUp = 0x48,    kPgUp = 0x49,    kPadMinus = 0x4A,    kLf = 0x4B,    kPad5 = 0x4C,    kRt = 0x4D,
    kPadPlus = 0x4E,    kEnd = 0x4F,    kDn = 0x50,    kPgDn = 0x51,    kIns = 0x52,    kDel = 0x53,    kSysReq = 0x54,    kUnknown55 = 0x55,
    kUnknown56 = 0x56,    kF11 = 0x57,    kF12 = 0x58, kMAX = 0x59
} ScanCode;

enum {
    SE_NONE,
    SE_KEYDOWN,
    SE_KEYUP,
    SE_KEYCHAR
};

#define MAX_EVENTS 64

// typedef struct neo_buffer_reader_s neo_buffer_reader_t;
struct neo_buffer_reader_s;

typedef void (*BufferReadDataProc)(struct neo_buffer_reader_s *reader, void *data, int length);

typedef void (*NeoUpdateProc)(void);
typedef void (*NeoDrawProc)(void);

typedef struct neo_config_s {
    const char *app_name;
    const char *logFilePath;
    NeoUpdateProc updateFunc;
    NeoDrawProc drawFunc;
} neo_config_t;

typedef struct neo_buffer_reader_s {
    FILE *file;
    void *data;
    void *userdata;

    BufferReadDataProc readData;
} neo_buffer_reader_t;

typedef struct neo_event_s {
    int eventType;
    int param;
    int param2;
} neo_event_t;

extern void Neo_Event_GetEvents(void);
extern void Neo_Event_ProcessEvents(void);
extern void Neo_Event_Add(int eventType, int param, int param2);

extern void Neo_Keyboard_Init(void);
extern bool Neo_IsKeyDown(ScanCode sc);
extern bool Neo_WasKeyDown(ScanCode sc);

void Neo_Mouse_GetStatus(unsigned short *x, unsigned short *y, unsigned short *buttons);

uint32_t Neo_Timer_GetTicks(void);
extern void Neo_Timer_Init(void);


extern void Neo_ClearKeyData(void);
extern void Neo_Init(neo_config_t config);
extern void Neo_Run(void);
extern void Neo_Shutdown(void);
bool Neo_ShouldQuit(void);
void Neo_Quit(void);
void LogInfo(const char *format, ...);

#ifdef NEO_IMPLEMENTATION

#ifdef PLATFORM_DESKTOP

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
};
#endif

static struct {
    neo_config_t config;
    neo_event_t events[MAX_EVENTS];

    bool did_shutdown;
    bool keyboard_did_init;
    bool mouse_did_init;

    int event_head;
    int event_tail;

    bool done;

    struct {
        bool did_init;
        unsigned short tick_count;
        unsigned short accum;
        unsigned short old_timer_ticks;
        unsigned short old_timer_tick_count;
    } timer;

    struct {
        // Current state of keys
        unsigned char current_keys[256];

        // Keys that were pressed down this frame
        unsigned char pressed_keys[256];

        // Keys that were released this frame
        unsigned char released_keys[256];
    } keyboard;

    struct {
        unsigned short ticks;
    } sound;

    struct
    {
        FILE *logFile;
    } log;

#ifdef PLATFORM_DOS
    void interrupt far (*timer_old_int)();
    void interrupt far (*keyboard_old_int)();
#endif
} neo_state;

#pragma region Event
#pragma mark - Event


void Neo_Event_GetEvents(void) {
#ifdef PLATFORM_DESKTOP
    while(true) {
        int charPressed = GetCharPressed();
        if(charPressed == 0) {
            break;
        }

        Neo_Event_Add(SE_KEYCHAR, charPressed, 0);
    }

    for(int i = 0; i < kMAX; i++) {
        if(IsKeyPressed(neo_scanCodeToRaylibKey[i])) {
            Neo_Event_Add(SE_KEYDOWN, i, 0);
//            printf("Key down (raylib): %d\n", i);
        }
        if(IsKeyReleased(neo_scanCodeToRaylibKey[i])) {
            Neo_Event_Add(SE_KEYUP, i, 0);
//            printf("Key up (raylib): %d\n", i);
        }
    }

#endif
}

void Neo_Event_ProcessEvents(void) {
    neo_event_t *event;

    while(neo_state.event_tail != neo_state.event_head) {
        neo_state.event_tail = (neo_state.event_tail + 1) & (MAX_EVENTS - 1);
        event = &neo_state.events[neo_state.event_tail];
//        printf("process event %d: %d %d %d\n", neo_state.event_tail, event->eventType, event->param, event->param2);
        switch(event->eventType) {
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
//                printf("SE_KEYCHAR: %c (%d)\n", event->param, event->param);
                break;
            default:
//                printf("Didn't process event %d\n", event->eventType);
                break;
        }
    }
}

void Neo_Event_Add(int eventType, int param, int param2) {

    neo_event_t *event;

    int nextHead = (neo_state.event_head + 1) & (MAX_EVENTS - 1);
    if (nextHead != neo_state.event_tail) {
//        printf("Add event %d: %d %d %d\n", nextHead, eventType, param, param2);
        event = &neo_state.events[nextHead];
        event->eventType = eventType;
        event->param = param;
        event->param2 = param2;

        neo_state.event_head = nextHead;
    } else {
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

static void interrupt _DOS_KeyISR(void) {
    unsigned char scancode = inportb(0x60);
    unsigned char temp;
    unsigned char keyChar = 0;
    outportb(0x61,(temp = inportb(0x61)) | 0x80);
	outportb(0x61,temp);

    if(scancode == 224) {

    } else {
        if(scancode & 0x80) {
            scancode &= 0x7f;

            // If this key isn't already down, send a down event
            // Send a char event

            neo_state.keyboard.current_keys[scancode] = 0;
            neo_state.keyboard.released_keys[scancode] = 1;

//            printf("DOS Key ISR: Released %d\n", scancode);

            Neo_Event_Add(SE_KEYUP, scancode, 0);
        } else {
            keyChar = scancode_lower[scancode];

            if(neo_state.keyboard.current_keys[kLShift] || neo_state.keyboard.current_keys[kRShift]) {
                keyChar = scancode_upper[scancode];
            }

            if(!neo_state.keyboard.current_keys[scancode]) {
//                printf("DOS Key ISR: Pressed  %d\n", scancode);
                Neo_Event_Add(SE_KEYDOWN, scancode, 0);
            }

//            printf("DOS Key ISR: Char %c\n", keyChar);

            neo_state.keyboard.current_keys[scancode] = 1;
            neo_state.keyboard.pressed_keys[scancode] = 1;

            if(keyChar > 0) {
                Neo_Event_Add(SE_KEYCHAR, keyChar, 0);
            }
        }
    }

    outportb(0x20, 0x20);
}

#endif

bool Neo_IsKeyDown(ScanCode sc) {
    return neo_state.keyboard.current_keys[sc];
}

bool Neo_WasKeyDown(ScanCode sc) {
    return neo_state.keyboard.current_keys[sc] || neo_state.keyboard.pressed_keys[sc];
}

void Neo_Keyboard_Init(void){
    if(!neo_state.keyboard_did_init) {
        neo_state.keyboard_did_init = true;

#ifdef PLATFORM_DOS
        neo_state.keyboard_old_int = _dos_getvect(0x09);
        _dos_setvect(0x09, _DOS_KeyISR);
#endif
    }
}

void Neo_Keyboard_Shutdown(void) {
    if(neo_state.keyboard_did_init) {
        neo_state.keyboard_did_init = false;

#ifdef PLATFORM_DOS
        if(neo_state.keyboard_old_int != NULL) {
            _dos_setvect(0x09, neo_state.keyboard_old_int);
        }
#endif
    }
}


#ifdef PLATFORM_DOS
static void interrupt _DOS_TimerISR() {
    neo_state.timer.old_timer_tick_count --;
    neo_state.timer.tick_count += 1;
    neo_state.timer.accum += 72;

    while(neo_state.timer.accum >= 100) {
        neo_state.timer.tick_count += 1;
        neo_state.timer.accum -= 100;
    }

    if(neo_state.timer.old_timer_tick_count == 0) {
        neo_state.timer.old_timer_tick_count = neo_state.timer.old_timer_ticks;
        _chain_intr(neo_state.timer_old_int);
    }

    outportb(0x20, 0x20);
}
#endif
#pragma endregion

#pragma region Mouse
#pragma mark - Mouse

void Neo_Mouse_GetStatus(unsigned short *mouse_x, unsigned short *mouse_y, unsigned short *mouse_buttons) {
    unsigned short cursor_x, cursor_y, buttons;
#ifdef PLATFORM_DOS
    asm {
        mov ax, 3
        int 33h
        mov buttons, bx
        mov cursor_x, cx
        mov cursor_y, dx
    }

    *mouse_x = cursor_x;
    *mouse_y = cursor_y;
    *mouse_buttons = buttons;
#else
    *mouse_x = GetMouseX();
    *mouse_y = GetMouseY();
    *mouse_buttons = 0;
    if(IsMouseButtonDown(0)) {
        *mouse_buttons |= 1;
    }
#endif
}

#pragma endregion


#pragma region Timer
#pragma mark - Timer
#ifdef PLATFORM_DOS
void Neo_Timer_SetClockRate(int numBits) {
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
uint32_t Neo_Timer_GetTicks(void) {
#ifdef PLATFORM_DOS
    return neo_state.timer.tick_count;
#else
    return (uint32_t) round(GetTime() * 1000);
#endif
}

void Neo_Timer_Init(void) {
    if(!neo_state.timer.did_init) {
        neo_state.timer.did_init = true;
        neo_state.sound.ticks = 1;

#ifdef PLATFORM_DOS
        neo_state.timer_old_int = _dos_getvect(0x08);
        _dos_setvect(0x08, _DOS_TimerISR);
        Neo_Timer_SetClockRate(5);
#endif
    }
}

void Neo_Timer_Shutdown(void) {
    if(neo_state.timer.did_init) {
        neo_state.timer.did_init = false;

#ifdef PLATFORM_DOS
        Neo_Timer_SetClockRate(0);
        if(neo_state.timer_old_int != NULL) {
            _dos_setvect(0x08, neo_state.timer_old_int);
        }
#endif
    }
}
#pragma endregion

#pragma region Loop
#pragma mark - Loop
void Neo_Run(void) {

#ifdef PLATFORM_DOS
    while(!neo_state.done) {
        Neo_ClearKeyData();
        Neo_Event_GetEvents();
        Neo_Event_ProcessEvents();

        if(Neo_ShouldQuit()) {
            break;
        }

        if(neo_state.config.updateFunc) {
            neo_state.config.updateFunc();
        }

        if(neo_state.config.drawFunc) {
            neo_state.config.drawFunc();
        }
    }
#else
    while(!neo_state.done) {

        Neo_ClearKeyData();
        Neo_Event_GetEvents();
        Neo_Event_ProcessEvents();

        if(neo_state.config.updateFunc) {
            neo_state.config.updateFunc();
        }

        BeginDrawing();
        ClearBackground(BLACK);

        if(neo_state.config.drawFunc) {
            neo_state.config.drawFunc();
        }

        EndDrawing();

        if(WindowShouldClose()) {
            Neo_Quit();
        }
    }
#endif
}
#pragma endregion

void Neo_Init(neo_config_t config) {
#ifdef PLATFORM_DOS
    clrscr();
    textattr(7);
    textbackground(4);
	cprintf("                                                                                \n");
    gotoxy(40 - strlen(config.app_name) / 2,1);
    cprintf("%s\n\n", config.app_name);
    gotoxy(1,2);
    textattr(7);
    textbackground(0);
#endif

//    printf("Size of int: %d, short: %d\n", sizeof(int), sizeof(unsigned short));
    memset(&neo_state, 0, sizeof(neo_state));
    neo_state.config = config;

    if (config.logFilePath)
    {
        neo_state.log.logFile = fopen(config.logFilePath, "wb");
    }
}

void Neo_Quit(void) {
    neo_state.done = true;
}

bool Neo_ShouldQuit(void) {
    return neo_state.done;
}

void Neo_ClearKeyData(void) {
    memset(&neo_state.keyboard.pressed_keys, 0, sizeof(neo_state.keyboard.pressed_keys));
    memset(&neo_state.keyboard.released_keys, 0, sizeof(neo_state.keyboard.released_keys));
}

void Neo_Shutdown(void) {
    if (!neo_state.did_shutdown) {
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

void LogInfo(const char *format, ...) {
#ifdef PLATFORM_DOS
    va_list args;
    va_start(args, format);
    // vprintf(format, args);
    if (neo_state.log.logFile != NULL)
    {
        vfprintf(neo_state.log.logFile, format, args);
        fputs("\r\n", neo_state.log.logFile);
    }
    putchar('\n');
    va_end(args);
#else
    char buffer[1024];
    va_list args;
    va_start(args, format);
    vsnprintf(buffer, sizeof(buffer), format, args);
    va_end(args);
    TraceLog(LOG_INFO, "%s", buffer);
#endif
}

#endif  // NEO_IMPLEMENTATION
#endif  // NEO_H
