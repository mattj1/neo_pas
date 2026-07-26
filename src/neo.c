#include "neo.h"

#ifdef PLATFORM_DESKTOP
#include <raylib.h>
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
    [KEY_ESCAPE] = kEsc,
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

neo_sfx_t Neo_Sound_LoadEffect(neo_buf_reader_t *reader)
{
    unsigned short *data;
    neo_sfx_t sfx = {NULL, 0};

    sfx.length = Neo_Buf_ReadUInt16(reader);

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
        // if (!IsAudioStreamValid(neo_state.sound.stream))
        // {
            // LogInfo("Audio stream not ready");
            // return false;
        // }

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

#ifndef PLATFORM_DOS
static void _UpdateDrawFrame()
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
#ifndef NEO_WEB
    if (WindowShouldClose())
    {
        Neo_Quit();
    }
#endif
}
#endif

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
#ifdef NEO_WEB
    emscripten_set_main_loop(_UpdateDrawFrame, 0, 1);
#else
    while (!neo_state.done)
    {
        _UpdateDrawFrame();
    }
#endif
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

