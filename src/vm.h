#ifndef VM_H
#define VM_H

#include "neo.h"

#define VM_MAX_SCRIPT_EXPORTS 8

typedef struct vm_state_s vm_state_t;
typedef neo_buffer_reader_t (*vm_script_load_func)(const char *name);
typedef void (*vm_trap_func)(vm_state_t *state, uint8_t trapNo);
typedef void *(*vm_mem_func)(vm_state_t *state, uint16_t addr);

typedef struct
{
    vm_script_load_func script_load_func;
    vm_trap_func trap_func;
    vm_mem_func mem_func;
} vm_config_t;

typedef struct
{
    char name[20];
    uint16_t addr;
} vm_export_t;

typedef struct vm_script_t
{
    uint8_t *rom;
    uint8_t ram[256];
    vm_export_t exports[VM_MAX_SCRIPT_EXPORTS];
    int refCount;
    char name[20];
    uint16_t romSize;
} vm_script_t;

typedef struct vm_state_s
{
    int16_t id;             // -1 = unused
    int16_t refCount;
    uint8_t ram[256];
    vm_script_t *script;

    uint16_t pc, sp, bp;
    uint8_t cf;

    uint16_t r0, r1;
    uint16_t e0, e1;
    uint16_t i0, i1;

    bool isRunning;
} vm_state_t;

extern void VM_Init(vm_config_t config);
extern vm_script_t *VM_GetScript(const char *name);
extern vm_state_t *VM_StateForID(int16_t state_id);
extern bool VM_CreateState(int16_t *out_state_id);
extern bool VM_AttachState(int16_t state_id, vm_script_t *script);
extern void VM_ReleaseState(vm_state_t *state);
extern bool VM_GetExport(vm_state_t *state, const char *name, uint16_t *out_addr);
extern bool VM_SetPC(vm_state_t *state, uint16_t addr);
extern bool VM_Call(vm_state_t* state, uint16_t addr);

uint16_t VM_ReadReg(vm_state_t *state, uint8_t reg);
uint16_t VM_PopInt(vm_state_t *state);
const char *VM_PopAddrToString(vm_state_t *state);

#ifdef NEO_VM_IMPLEMENTATION
#define MAX_SCRIPTS 32
#define MAX_STATES 68

#define STATE_VALID(state) (state != NULL && state->id != -1)

typedef union
{
    uint8_t regVal;
    int16_t intVal;
    uint16_t uintVal;
} vm_instruction_arg_t;

typedef struct
{
    uint16_t pc;
    vm_instruction_arg_t args[3];
    vm_instruction_arg_t arg2;
    uint8_t opcode;
    uint8_t cond;
    bool cond_run;
} vm_instruction_t;

static struct
{
    // stringbuilder
    vm_script_t **scripts;
    int numScripts;

    long memUse;
    vm_state_t states[MAX_STATES];
    int numActiveStates;
    vm_config_t config;
} G;

static void State_Init(int16_t state_id)
{
    vm_state_t *state = &G.states[state_id];
    memset(state, 0, sizeof(vm_state_t));

    state->id = state_id;
    state->sp = 0xc100;
    state->pc = 0xffff;
}

static vm_script_t *LoadScript(neo_buffer_reader_t *reader, const char *name)
{
    vm_script_t script;
    uint16_t sz;
    bool done = false;
    int current_export = 0;

    memset(&script, 0, sizeof(script));

    strcpy(&script.name[0], name);

    Neo_Buf_ReadUShort(reader, &sz);
    if (sz > 0)
    {
        Neo_Buf_ReadData(reader, script.ram, sz);
    }

    Neo_Buf_ReadUShort(reader, &sz);
    script.romSize = sz;
    script.rom = malloc(sz);
    printf("ROM size: %d\n", sz);
    Neo_Buf_ReadData(reader, script.rom, sz);

    uint8_t code;
    while (!done)
    {
        Neo_Buf_ReadByte(reader, &code);
        if (code == 0)
        {
            done = true;
            continue;
        }

        if (code == 3)
        {
            vm_export_t *export = &script.exports[current_export];
            Neo_Buf_ReadString(reader, export->name, 20);
            Neo_Buf_ReadUShort(reader, &export->addr);

            current_export ++;
        }
    }

    vm_script_t *newScript = malloc(sizeof(vm_script_t));
    memcpy(newScript, &script, sizeof(vm_script_t));

    Neo_Buf_CloseReader(reader);
    return newScript;
}

static void RetainState(vm_state_t *state)
{
    if (state != NULL && state->id != -1)
    {
        state->refCount ++;
    }
}

static void ReleaseScript(vm_script_t *script)
{
    if (script != NULL)
    {
        script->refCount--;
        if (script->refCount <= 0)
        {
            // ???
        }
    }
}

void VM_ReleaseState(vm_state_t *state)
{
    if (state != NULL && state->id != -1)
    {
        state->refCount --;
        if (state->refCount <= 0)
        {
            ReleaseScript(state->script);
            free(state->ram);
            state->id = -1;
        }
    }
}

static vm_script_t *GetLoadedScriptForName(const char *name)
{
    int i;
    for (i = 0; i < G.numScripts; i++)
    {
        if (!strcmp(G.scripts[i]->name, name))
        {
            return G.scripts[i];
        }
    }

    return NULL;
}

vm_script_t *VM_GetScript(const char *name)
{
    neo_buffer_reader_t reader;

    vm_script_t *script = NULL;
    script = GetLoadedScriptForName(name);

    if (script)
    {
        return script;
    }

    if (G.numScripts == MAX_SCRIPTS)
    {
        return NULL;
    }

    if (G.config.script_load_func == NULL)
    {
        return NULL;
    }

    reader = G.config.script_load_func(name);

    if (!Neo_Buf_IsReaderValid(reader))
    {
        return NULL;
    }

    script = LoadScript(&reader, name);
    G.scripts[G.numScripts ++] = script;
    return script;
}

bool VM_CreateState(int16_t *out_state_id)
{
    int16_t i;

    if (out_state_id == NULL)
    {
        return false;
    }

    for (i = 0; i < MAX_STATES; i++)
    {
        if (G.states[i].id == -1)
        {
            State_Init(i);
            *out_state_id = i;
            return true;
        }
    }

    return false;
}

vm_state_t *VM_StateForID(int16_t state_id)
{
    vm_state_t *state;

    if (state_id < 0 || state_id >= MAX_STATES)
    {
        return NULL;
    }

    state = &G.states[state_id];

    if (state->id == -1)
    {
        return NULL;
    }

    return state;
}

bool VM_AttachState(int16_t state_id, vm_script_t *script)
{
    vm_state_t *state = VM_StateForID(state_id);

    if (!state)
    {
        return false;
    }

    state->script = script;
    memcpy(&state->ram, script->ram, 256);

    RetainState(state);
    script->refCount++;
    return true;
}


bool VM_GetExport(vm_state_t *state, const char *name, uint16_t *out_addr)
{
    vm_export_t *e;

    if (!STATE_VALID(state) || state->script == NULL)
    {
        return false;
    }

    for (int i = 0; i < VM_MAX_SCRIPT_EXPORTS; i++)
    {
        e = &state->script->exports[i];

        if (!strcmp(e->name, name))
        {
            *out_addr = e->addr;
            return true;
        }
    }

    return false;
}



void *VM_Ptr(vm_state_t *state, uint16_t addr)
{
    if (!STATE_VALID(state))
    {
        return NULL;
    }

    // 48 KB ROM
    if (addr < 0xc000)
    {
        return &state->script->rom[addr];
    }

    // 256 B RAM
    if (addr < 0xc100)
    {
        return &state->ram[addr - 0xc000];
    }

    // TODO: Move this to callback

    // 3 KB Unused

    // The 12K from d000-ffff are user-defined.

    if (addr >= 0xd000 && G.config.mem_func)
    {
        return G.config.mem_func(state, addr);
    }

    return NULL;
}

void VM_WriteShort(vm_state_t *state, uint16_t addr, uint16_t val)
{
    if (!STATE_VALID(state) || addr < 0xc000)
    {
        return;
    }

    uint16_t *p = VM_Ptr(state, addr);

    if (p == NULL)
    {
        printf("Error: Can't write to %x\n", addr);
        return;
    }

    *p = val;
}

void VM_WriteMem(vm_state_t *state, uint16_t addr, void *data, int size)
{
    if (!STATE_VALID(state) || addr < 0xc000)
    {
        return;
    }

    memcpy(VM_Ptr(state, addr), data, size);
}

uint8_t VM_ReadByte(vm_state_t *state, uint16_t addr)
{
    uint8_t *p = VM_Ptr(state, addr);
    return *p;
}

uint16_t VM_ReadShort(vm_state_t *state, uint16_t addr)
{
    uint16_t *p = VM_Ptr(state, addr);
    return *p;
}

uint16_t VM_PopShort(vm_state_t *state)
{
    // printf("VM_PopShort at sp=%d\n", state->sp);
    uint16_t val = VM_ReadShort(state, state->sp);
    state->sp += 2;
    return val;
}

uint16_t VM_PopInt(vm_state_t *state)
{
    return VM_PopShort(state);
}

const char *VM_PopAddrToString(vm_state_t *state)
{
    uint16_t addr = VM_PopShort(state);
    // printf("addr popped: %d\n", addr);
    return VM_Ptr(state, addr);
}

bool VM_PushInt(vm_state_t *state, uint16_t val)
{
    if (!STATE_VALID(state))
    {
        return false;
    }

    // printf("VM_PushInt: %d to %d\n", val, state->sp);
    if (state->sp <= 0xc002)
    {
        exit(0);
        return false;
    }

    state->sp -= 2;

    VM_WriteShort(state, state->sp, val);
    return true;
}

bool VM_SetPC(vm_state_t *state, uint16_t addr)
{
    if (state == NULL || state->id == -1 || addr > 1024 * 48)
    {
        return false;
    }

    state->pc = addr;
    return true;
}


uint8_t VM_NextByte(vm_state_t *state)
{
    uint8_t val = VM_ReadByte(state, state->pc);
    state->pc ++;

    return val;
}

int16_t VM_NextShort(vm_state_t *state)
{
    int16_t val = VM_ReadShort(state, state->pc);
    state->pc += 2;

    return val;
}

uint16_t VM_NextMemOperand(vm_state_t *state)
{
    uint8_t reg;
    int16_t offset;
    uint8_t opType = VM_NextByte(state);
    uint16_t addr;
    switch (opType)
    {
    case 0:
        // Absolute address
        return VM_NextShort(state);
    case 2:
        // 8-bit signed offset relative to value in register
        reg = VM_NextByte(state);
        offset = VM_NextByte(state);
        if (offset > 127)
        {
            offset -= 256;
        }

        return VM_ReadReg(state, reg) + offset;

    default:
       // printf("Unsupported memory operand\n");

    }
}

uint16_t *VM_Reg(vm_state_t *state, uint8_t reg)
{
    switch (reg)
    {
    case 0x00: return &state->r0;
    case 0x01: return &state->r1;
    case 0x0e: return &state->bp;
    case 0x0f: return &state->sp;
    case 0x10: return &state->e0;
    case 0x20: return &state->e1;
    case 0x40: return &state->i0;
    case 0x80: return &state->i1;
    default:
        printf("unsupported register %d\n", reg);
        return NULL;
    }
}

uint16_t VM_ReadReg(vm_state_t *state, uint8_t reg)
{
    return *VM_Reg(state, reg);
}

void VM_WriteReg(vm_state_t *state, uint8_t reg, uint16_t val)
{
    uint16_t *r = VM_Reg(state, reg);
    if (r != NULL)
    {
        *r = val;
    }
}

bool LoadInstruction(vm_state_t *state, vm_instruction_t *i)
{
    bool cond_run = true;
    uint8_t cond = 0;
    uint8_t cf = state->cf;
    uint8_t opcode = VM_NextByte(state);

    if (opcode & 0x80)
    {
        cond = VM_NextByte(state);
        switch (cond)
        {
        case 1:      // eq
            if (cf != 1) cond_run = false;
            break;
        case 2:      // gt
            if ((cf & 2) == 0) cond_run = false;
            break;
        case 3:     // lt
            if ((cf & 4) == 0) cond_run = false;
            break;
        case 4:     // ge
            if ((cf & 3) == 0) cond_run = false;
            break;
        case 5:     // le
            if ((cf & 5) == 0) cond_run = false;
            break;
        case 6:     // ne
            if (cf == 1) cond_run = false;
            break;
        default:
            break;
        }
    }

    i->opcode = opcode & 0x7f;
    i->cond = cond;
    i->cond_run = cond_run;

    return true;
}

void LoadInstructionArgs(vm_state_t *state, vm_instruction_t *i, const char *args)
{
    int p = 0;
    char a;
    while (args[p] != 0)
    {
        a = (char) args[p];

        vm_instruction_arg_t *arg = &i->args[p];

        if (a == 'r')
        {
            arg->regVal = VM_NextByte(state);
        }

        if (a == 'i')
        {
            arg->intVal = VM_NextShort(state);
        }

        if (a == 'm')
        {
            arg->uintVal = VM_NextMemOperand(state);
        }

        p++;
    }
}

bool VM_Run(vm_state_t *state)
{
    int numExecuted = 0;
    uint16_t param, param2;
    vm_instruction_t i;

    if (!STATE_VALID(state))
    {
        return false;
    }

    RetainState(state);

    state->isRunning = true;

    while (state->isRunning)
    {
        numExecuted ++;
        if (numExecuted > 128)
        {
            printf("Stop...\n");
            state->isRunning = false;
            continue;
        }

        if (!LoadInstruction(state, &i))
        {
            state->isRunning = false;
            continue;
        }

        switch (i.opcode)
        {
        case 3:
            // ret
            if (i.cond_run)
            {
                if (state->sp == 0xc100)
                {
                    printf("done?");
                    state->isRunning = false;
                    break;
                }

                state->pc = VM_PopInt(state);
                if (state->pc == 0xffff)
                {
                    printf("done?");
                    state->isRunning = false;
                    break;
                }
            }
            break;
        case 4:
            // add reg, imm
            i.args[0].regVal = VM_NextByte(state);
            i.args[1].intVal = VM_NextShort(state);
            printf("add r%d, %d\n", i.args[0].regVal, i.args[1].intVal);

            param = VM_ReadReg(state, i.args[0].intVal);
            if (i.cond_run)
            {
                param += i.args[1].intVal;
                VM_WriteReg(state, i.args[0].regVal, param);
            }
            break;
        case 9:
            // j imm
            i.args[0].uintVal = VM_NextShort(state);
            if (i.cond_run)
            {
                VM_SetPC(state, i.args[0].uintVal);
            }
            break;
        case 10:
            // b imm
            i.args[0].uintVal = VM_NextShort(state);
            if (i.cond_run)
            {
                printf("b %d (%d)\n", i.args->uintVal, i.args->uintVal);
                VM_PushInt(state, state->pc);
                VM_SetPC(state, i.args[0].uintVal);
            }
            break;
        case 64:
            // move mem, imm
            LoadInstructionArgs(state, &i, "mi");
            if (i.cond_run)
            {
                VM_WriteShort(state, i.args[0].uintVal, i.args[1].uintVal);
            }
            break;
        case 65:
            // mov reg, imm
            LoadInstructionArgs(state, &i, "ri");
            printf("mov r%d, %d\n", i.args[0].regVal, i.args[1].uintVal);
            if (i.cond_run)
            {
                VM_WriteReg(state, i.args[0].regVal, i.args[1].uintVal);
            }
            break;
        case 67:
            // mov reg, mem
            i.args[0].regVal = VM_NextByte(state);
            i.args[1].uintVal = VM_NextMemOperand(state);
            printf("mov reg %d, [%d]\n", i.args[0].regVal, i.args[1].uintVal);
            if (i.cond_run)
            {
                VM_WriteReg(state, i.args[0].regVal, i.args[1].uintVal);
            }
            break;
        case 68:
            // mov reg, reg
            i.args[0].intVal = VM_NextByte(state);
            i.args[1].intVal = VM_NextByte(state);
            printf("mov reg, reg: %d %d\n", i.args[0].intVal, i.args[1].intVal);
            VM_WriteReg(state, i.args[0].regVal, VM_ReadReg(state, i.args[1].intVal));
            break;
        case 80:
            // push imm
            i.args[0].intVal = VM_NextShort(state);
            printf("push imm: %d\n", i.args[0].intVal);
            if (i.cond_run)
            {
                VM_PushInt(state, i.args[0].intVal);
            }
            break;
        case 81:
            // Push reg
            i.args[0].intVal = VM_NextByte(state);
            printf("push reg: %d\n", i.args[0].intVal);
            if (i.cond_run)
            {
                param = VM_ReadReg(state, i.args[0].intVal);
                VM_PushInt(state, param);
            }

            break;
        case 82:
            // Push mem
            {
                LoadInstructionArgs(state, &i, "m");
                printf("push mem [%x]\n", i.args[0].uintVal);
                if (i.cond_run)
                {
                    unsigned short *ptr = VM_Ptr(state, i.args[0].uintVal);
                    VM_PushInt(state, *ptr);
                }
            }
            break;
        case 83:
            // pop reg
            LoadInstructionArgs(state, &i, "r");
            if (i.cond_run)
            {
                unsigned short val = VM_PopInt(state);
                printf("pop r%d  got: (%d)\n", i.args[0].regVal, val);
                VM_WriteReg(state, i.args[0].regVal, val);
            }
            break;
        case 84:
            {
                i.args[0].uintVal = VM_NextMemOperand(state);
                printf("pop mem [%x]\n", i.args[0].uintVal);
                // if (i.cond_run)
                // {

                unsigned short *ptr = VM_Ptr(state, i.args[0].uintVal);
                *ptr = VM_PopInt(state);
                // }
                break;
            }
        case 90:
            // s_cmp
            param2 = VM_PopInt(state);
            param = VM_PopInt(state);

            state->cf &= 0xf0;

            if (param == param2) state->cf |= 0x01;
            if (param > param2) state->cf |= 0x02;
            if (param < param2) state->cf |= 0x04;

            break;
        case 91:
        case 92:
        case 93:
        case 94:
        case 95:
        case 96:
        case 97:
        case 98:
        case 99:
        case 100:
        case 101:
            param2 = VM_PopInt(state);
            param = VM_PopInt(state);
            switch (i.opcode)
            {
            case 91:
                VM_PushInt(state, param + param2);
                break;
            case 94:
                VM_PushInt(state, param > param2);
                break;
            case 98:
                VM_PushInt(state, param == param2);
                break;
            default:
                printf("Unhandled stack op: %d\n", i.opcode);
            }

           break;
        case 127:
            i.args[0].intVal = VM_NextShort(state);
            printf("trap %d\n", i.args[0].intVal);
            if (i.cond_run)
            {
                G.config.trap_func(state, i.args[0].intVal);
            }
            break;
        default:
            printf("Unhandled opcode: %d\n", i.opcode);
            state->isRunning = false;
            break;
        }

    }

    return true;
}

bool VM_Call(vm_state_t* state, uint16_t addr)
{
    if (!state)
    {
        return false;
    }

    VM_PushInt(state, state->pc);
    VM_SetPC(state, addr);
    return VM_Run(state);
}


void VM_Init(vm_config_t config)
{
    int i;

    LogInfo("VM_Init: State size: %d", sizeof(G));
    memset(&G, 0, sizeof(G));
    G.scripts = calloc(MAX_SCRIPTS, sizeof(vm_script_t));
    G.config = config;

    for (i = 0; i < MAX_STATES; i++)
    {
        G.states[i].id = -1;
    }
}

#endif
#endif

