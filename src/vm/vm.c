#include "vm.h"

// ReSharper disable CppJoinDeclarationAndAssignment
#define MAX_SCRIPTS 32
#define MAX_STATES 68

#define STATE_VALID(state) (state != NULL && state->id != -1)

typedef union {
    uint8_t regVal;
    int16_t intVal;
    uint16_t uintVal;
    struct {
        uint32_t padding;
        int16_t *intPtrVal;
    } ptr;
} vm_instruction_arg_t;

typedef struct {
    uint16_t pc;
    uint16_t sp;
    vm_instruction_arg_t args[3];
    uint8_t opcode;
} vm_instruction_t;

static struct {
    // stringbuilder
    vm_script_t **scripts;
    int numScripts;

    long memUse;
    vm_state_t states[MAX_STATES];
    int numActiveStates;
    vm_config_t config;
} G;


#ifdef PLATFORM_DESKTOP
#define logi LogInfo
// #define logi printf
#else
#define logi  1 ? (void)0 : (void)
#endif

static void State_Init(int16_t state_id) {
    vm_state_t *state = &G.states[state_id];
    memset(state, 0, sizeof(vm_state_t));

    state->id = state_id;
    state->sp = 0xc100;
    state->pc = 0xffff;
}

static vm_script_t *LoadScript(neo_buf_reader_t *reader, const char *name) {
    vm_script_t script, *newScript;
    uint16_t sz;
    bool done = false;
    uint8_t code;
    int current_export = 0;

    memset(&script, 0, sizeof(script));

    strcpy(&script.name[0], name);

    sz = Neo_Buf_ReadUInt16(reader);
    logi("RAM size: %d", sz);
    if (sz > 0) {
        Neo_Buf_ReadData(reader, script.ram, sz);
    }

    sz = Neo_Buf_ReadUInt16(reader);
    script.romSize = sz;
    script.rom = malloc(sz);
    logi("ROM size: %d", sz);
    Neo_Buf_ReadData(reader, script.rom, sz);

    while (!done) {
        code = Neo_Buf_ReadUInt8(reader);
        if (code == 0) {
            done = true;
            continue;
        }

        if (code == 3) {
            vm_export_t *export = &script.exports[current_export];
            Neo_Buf_ReadString(reader, export->name, 20);
            export->addr = Neo_Buf_ReadUInt16(reader);

            current_export++;
        }
    }

    newScript = malloc(sizeof(vm_script_t));
    memcpy(newScript, &script, sizeof(vm_script_t));

    Neo_Buf_ReaderClose(reader);
    return newScript;
}

static void RetainState(vm_state_t *state) {
    if (state != NULL && state->id != -1) {
        state->refCount++;
    }
}

static void ReleaseScript(vm_script_t *script) {
    if (script != NULL) {
        script->refCount--;
        if (script->refCount <= 0) {
            // ???
        }
    }
}

void VM_ReleaseState(vm_state_t *state) {
    if (state != NULL && state->id != -1) {
        state->refCount--;
        if (state->refCount <= 0) {
            ReleaseScript(state->script);
            // free(state->ram);
            state->id = -1;
        }
    }
}

static vm_script_t *GetLoadedScriptForName(const char *name) {
    int i;
    for (i = 0; i < G.numScripts; i++) {
        if (!strcmp(G.scripts[i]->name, name)) {
            return G.scripts[i];
        }
    }

    return NULL;
}

vm_script_t *VM_GetScript(const char *name) {
    neo_buf_reader_t reader;

    vm_script_t *script = NULL;
    script = GetLoadedScriptForName(name);

    if (script) {
        return script;
    }

    if (G.numScripts == MAX_SCRIPTS) {
        return NULL;
    }

    if (G.config.script_load_func == NULL) {
        return NULL;
    }

    reader = G.config.script_load_func(name);

    if (!Neo_Buf_ReaderIsValid(&reader)) {
        return NULL;
    }

    script = LoadScript(&reader, name);
    G.scripts[G.numScripts++] = script;
    return script;
}

bool VM_CreateState(i16 *out_state_id) {
    int16_t i;

    if (out_state_id == NULL) {
        return false;
    }

    for (i = 0; i < MAX_STATES; i++) {
        if (G.states[i].id == -1) {
            State_Init(i);
            *out_state_id = i;
            return true;
        }
    }

    return false;
}

vm_state_t *VM_StateForID(i16 state_id) {
    vm_state_t *state;

    if (state_id < 0 || state_id >= MAX_STATES) {
        return NULL;
    }

    state = &G.states[state_id];

    if (state->id == -1) {
        return NULL;
    }

    return state;
}

bool VM_AttachState(i16 state_id, vm_script_t *script) {
    vm_state_t *state = VM_StateForID(state_id);

    if (!state) {
        return false;
    }

    state->script = script;
    memcpy(&state->ram, script->ram, 256);

    RetainState(state);
    script->refCount++;
    return true;
}


bool VM_GetExport(vm_state_t *state, const char *name, uint16_t *out_addr) {
    vm_export_t *e;
    int i;

    if (!STATE_VALID(state) || state->script == NULL) {
        return false;
    }

    for (i = 0; i < VM_MAX_SCRIPT_EXPORTS; i++) {
        e = &state->script->exports[i];

        if (!strcmp(e->name, name)) {
            *out_addr = e->addr;
            return true;
        }
    }

    return false;
}


void *VM_Ptr(vm_state_t *state, uint16_t addr) {
    if (!STATE_VALID(state)) {
        return NULL;
    }

    // 48 KB ROM
    if (addr < 0xc000) {
        return &state->script->rom[addr];
    }

    // 256 B RAM
    if (addr < 0xc100) {
        return &state->ram[addr - 0xc000];
    }

    // TODO: Move this to callback

    // 3 KB Unused

    // The 12K from d000-ffff are user-defined.

    if (addr >= 0xd000 && G.config.mem_func) {
        return G.config.mem_func(state, addr);
    }

    return NULL;
}

static void *VM_RegPtr(vm_state_t *state, uint8_t reg) {
    switch (reg) {
        case 0x00: return &state->r0;
        case 0x01: return &state->r1;
        case 0x0e: return &state->bp;
        case 0x0f: return &state->sp;
    }

    Neo_Panic("VM_RegPtr: Invalid register");
    return NULL;
}

void VM_WriteShort(vm_state_t *state, uint16_t addr, uint16_t val) {
    uint16_t *p;

    if (!STATE_VALID(state) || addr < 0xc000) {
        return;
    }

    p = VM_Ptr(state, addr);

    if (p == NULL) {
        logi("Error: Can't write to %x\n", addr);
        return;
    }

    *p = val;
}

void VM_WriteMem(vm_state_t *state, uint16_t addr, void *data, int size) {
    if (!STATE_VALID(state) || addr < 0xc000) {
        return;
    }

    memcpy(VM_Ptr(state, addr), data, size);
}

uint8_t VM_ReadByte(vm_state_t *state, uint16_t addr) {
    uint8_t *p = VM_Ptr(state, addr);
    return *p;
}

uint16_t VM_ReadShort(vm_state_t *state, uint16_t addr) {
    uint16_t *p = VM_Ptr(state, addr);
    return *p;
}

uint16_t VM_PopShort(vm_state_t *state) {
    // LogInfo("VM_PopShort at sp=%x", state->sp);
    uint16_t val = VM_ReadShort(state, state->sp);
    state->sp += 2;
    return val;
}

uint16_t VM_PopInt(vm_state_t *state) {
    return VM_PopShort(state);
}

const char *VM_PopAddrToString(vm_state_t *state) {
    uint16_t addr = VM_PopShort(state);
    // printf("addr popped: %d\n", addr);
    return VM_Ptr(state, addr);
}

bool VM_PushInt(vm_state_t *state, uint16_t val) {
    if (!STATE_VALID(state)) {
        return false;
    }

    // LogInfo("VM_PushInt: %d to %x", val, state->sp);
    if (state->sp <= 0xc002) {
        exit(0);
        return false;
    }

    state->sp -= 2;

    VM_WriteShort(state, state->sp, val);
    return true;
}

bool VM_SetPC(vm_state_t *state, uint16_t addr) {
    if (state == NULL || state->id == -1
        || addr > 1024 * 48) {
        return false;
    }

    state->pc = addr;
    return true;
}


uint8_t VM_NextByte(vm_state_t *state) {
    uint8_t val = VM_ReadByte(state, state->pc);
    state->pc++;

    return val;
}

int16_t VM_NextShort(vm_state_t *state) {
    int16_t val = VM_ReadShort(state, state->pc);
    state->pc += 2;

    return val;
}

uint16_t VM_NextMemOperand(vm_state_t *state) {
    uint8_t reg;
    int16_t offset;
    uint8_t opType = VM_NextByte(state);
    uint16_t addr;
    switch (opType) {
        case 0:
            // Absolute address
            return VM_NextShort(state);
        case 2:
            // 8-bit signed offset relative to value in register
            reg = VM_NextByte(state);
            offset = VM_NextByte(state);
            if (offset > 127) {
                offset -= 256;
            }

            return VM_ReadReg(state, reg) + offset;

        default:
            Neo_Panic("Unsupported memory operand\n");
            return 0;
    }
}

uint16_t VM_ReadReg(vm_state_t *state, uint8_t reg) {
    switch (reg) {
        case 0x00: return state->r0;
        case 0x01: return state->r1;
        case 0x0e: return state->bp;
        case 0x0f: return state->sp;
        case 0x10: return state->e0;
        case 0x11:
            return G.config.get_entity_x_func(state, state->e0);
        case 0x12:
            return G.config.get_entity_y_func(state, state->e0);
        case 0x20: return state->e1;
        case 0x40: return state->i0;
        case 0x41:
            return G.config.get_item_type_func(state, state->i0);
        case 0x42:
            return G.config.get_item_quantity_func(state, state->i0);
        case 0x80: return state->i1;
        default:
            Neo_Panic("VM_ReadReg: Unsupported register: %d", reg);
            return 0;
    }
}

void VM_WriteReg(vm_state_t *state, uint8_t reg, uint16_t val) {
    switch (reg) {
        case 0x00: state->r0 = val;
            break;
        case 0x01: state->r1 = val;
            break;
        case 0x0e: state->bp = val;
            break;
        case 0x0f: state->sp = val;
            break;
        case 0x10:
            state->e0 = val;
            break;
        case 0x11:
            G.config.set_entity_x_func(state, state->e0, val);
            break;
        case 0x12:
            G.config.set_entity_y_func(state, state->e0, val);
            break;
        case 0x20: state->e1 = val;
            break;
        case 0x40: state->i0 = val;
            break;
        case 0x41:
            G.config.set_item_type_func(state, state->i0, val);
            break;
        case 0x42:
            G.config.set_item_quantity_func(state, state->i0, val);
            break;
        case 0x80: state->i1 = val;
            break;
        default:
            Neo_Panic("VM_WriteReg: Unsupported register: %d", reg);
    }
}

/*
 i = imm (2 bytes)
 r = reg
 */
#define IMM "i"
#define ADDR "a"
#define REG "r"
#define PTR_BP_OFFS "b"

static const char *paramList[] = {
    "", "", "", "", "", "", "", "",
    "", "", "", "", "", "", "", "",
    "", "", "", "", "", "", "", "",
    "", "", "", "", "", "", "", "",
    // 32 - 39 - j, j.eq
    IMM, IMM, "", "", "", "", "", "",

    // 40 - 47
    "", "", "", "", "", "", "", "",

    // 6 / b ...
    IMM, "", "", "", "", "", "", "",
    "", "", "", "", "", "", "", "",
    // 8 / 64 - 71 - push
    IMM, "", REG, "", PTR_BP_OFFS, "", "", "",

    // 9 / pop / 72 - 79
    "", "", REG, "", "", "", "", "",

    "", "", "", "", "", "", "", "",
    // 11 / 88 - 95
    "", "", "", "", ADDR IMM, ADDR ADDR, ADDR REG, ADDR PTR_BP_OFFS,

    // 12 / 96 - 103
    REG IMM, REG ADDR, REG REG, REG PTR_BP_OFFS, PTR_BP_OFFS IMM, PTR_BP_OFFS ADDR, PTR_BP_OFFS REG, PTR_BP_OFFS PTR_BP_OFFS,

    // 13 / add / 104 - 111
    REG IMM, "", "", "", "", "", "", "",

    "", "", "", "", "", "", "", "",
    "", "", "", "", "", "", "", "",
    "", "", "", "", "", "", "", "",
    "", "", "", "", "", "", "", "",
    "", "", "", "", "", "", "", "",
    "", "", "", "", "", "", "", "",
    "", "", "", "", "", "", "", "",
    "", "", "", "", "", "", "", "",
    "", "", "", "", "", "", "", "",
    "", "", "", "", "", "", "", "",
    "", "", "", "", "", "", "", "",
    "", "", "", "", "", "", "", "",
    "", "", "", "", "", "", "", "",
    "", "", "", "", "", "", "", "",
    "", "", "", "", "", "", "", "",
    "", "", "", "", "", "", "", "",
    "", "", "", "", "", "", "", "",

    // 31 / 248 - 255
    "i", "", "", "", "", "", "", "",
};

static void LoadInstructionArgs(vm_state_t *state, vm_instruction_t *i) {
    int p = 0;
    char a;
    vm_instruction_arg_t *arg;

    const char *args = paramList[i->opcode];
    while (args[p] != 0) {
        a = (char) args[p];

        arg = &i->args[p];

        switch (a) {
            case 'i':
                arg->intVal = VM_NextShort(state);
                arg->ptr.intPtrVal = &arg->intVal;
                break;
            case 'r':
                arg->regVal = VM_NextByte(state);
                arg->ptr.intPtrVal = VM_RegPtr(state, arg->regVal);
                break;
            case 'b':
                arg->intVal = VM_NextShort(state);
                arg->ptr.intPtrVal = VM_Ptr(state, state->bp + arg->intVal);
                break;
            case 'a':
                arg->uintVal = VM_NextShort(state);
                arg->ptr.intPtrVal = VM_Ptr(state, arg->intVal);
                break;
            default:
                printf("Unsupported argument type: %c\n", a);
                break;
        }
        // if (a == 'r')
        // {
        //
        // }
        //
        // if (a == 'i')
        // {
        // }
        //
        // if (a == 'm')
        // {
        //     arg->uintVal = VM_NextMemOperand(state);
        // }

        p++;
    }
}

static void LoadInstruction(vm_state_t *state, vm_instruction_t *i) {
    const uint8_t pc = state->pc;
    const uint8_t opcode = VM_NextByte(state);

    i->sp = state->sp;
    i->pc = pc;
    i->opcode = opcode;
    LoadInstructionArgs(state, i);
}

bool VM_Run(vm_state_t *state) {
    int numExecuted = 0;
    uint16_t param, param2, val;
    vm_instruction_t i;
    unsigned short *ptr;

    if (!STATE_VALID(state)) {
        return false;
    }

    RetainState(state);

    state->isRunning = true;

    while (true) {
        if (!state->isRunning) {
            VM_ReleaseState(state);
            break;
        }

        numExecuted++;
        if (numExecuted > 128) {
            printf("Stop...\n");
            state->isRunning = false;
            continue;
        }

        LoadInstruction(state, &i);

        // printf("opcode: %d\n", i.opcode);
        switch (i.opcode) {
            case 24:
                // ret
                logi("[ %04x sp: %04x ] ret", i.pc, i.sp);

                if (state->sp == 0xc100) {
                    // printf("done?");
                    logi("ret: can't pop!");
                    state->isRunning = false;
                    break;
                }

                state->pc = VM_PopInt(state);
                if (state->pc == 0xffff) {
                    // LogInfo("ret: popped pc=0xffff");
                    // printf("done?");
                    state->isRunning = false;
                    break;
                }

                // LogInfo("After ret: PC: %x  SP: %x\n", state->pc, state->sp);
                break;
            case 32:
                // j imm
                VM_SetPC(state, i.args[0].uintVal);
                break;
            case 33:
                // j.eq imm
                if (state->cf & 0x01) {
                    VM_SetPC(state, i.args[0].uintVal);
                }
                break;
            case 48:
                // b imm
                // i.args[0].uintVal = VM_NextShort(state);
                logi("[ %04x ] b %x (%d)\n", i.pc, i.args->uintVal, i.args->uintVal);
                VM_PushInt(state, state->pc);
                VM_SetPC(state, i.args[0].uintVal);
                break;
            case 64:
                // push imm
                logi("[ %04x ] push imm: %d", i.pc, i.args[0].intVal);
                VM_PushInt(state, i.args[0].intVal);

                break;
            case 65:
                break;
            case 66:
                // Push reg
                // i.args[0].intVal = VM_NextByte(state);
                param = VM_ReadReg(state, i.args[0].regVal);
                logi("[ %04x sp: %04x ] push r%d (pushing %d), To sp: %04x", i.pc, i.sp, i.args[0].regVal, param, i.sp - 2);
                VM_PushInt(state, param);
                break;
            // case 67:
            //     // mov reg, mem
            //     i.args[0].regVal = VM_NextByte(state);
            //     i.args[1].uintVal = VM_NextMemOperand(state);
            //     logi("[ %04x ] mov reg %d, [%d]", i.pc, i.args[0].regVal, i.args[1].uintVal);
            //     val = *(uint16_t *) VM_Ptr(state, i.args[1].uintVal);
            //     VM_WriteReg(state, i.args[0].regVal, val);
            //     break;
            case 68:
                // push [bp + ?]
                val = *(uint16_t *) i.args[0].ptr.intPtrVal;
                logi("[ %04x sp: %04x ] push [bp + %d] (pushing %d to %04x)", i.pc, i.sp, i.args[0].intVal, val, i.sp - 2);
                VM_PushInt(state, val);
                break;
            case 74: {
                // pop reg

                val = VM_PopInt(state);
                logi("[ %04x sp: %04x ] pop r%d  got: (%d), sp: %d", i.pc, i.sp, i.args[0].regVal, val, i.sp);
                VM_WriteReg(state, i.args[0].regVal, val);
                break;
            }
            // case 82:
            //     // Push mem
            // {
            //     // LoadInstructionArgs(state, &i, "m");
            //     unsigned short *ptr = VM_Ptr(state, i.args[0].uintVal);
            //     VM_PushInt(state, *ptr);
            //     logi("[ %x ] push mem [%x/%d] val: %d", i.pc, i.args[0].uintVal, i.args[0].uintVal, *ptr);
            // }
            // break;
            // case 84: {
            //     i.args[0].uintVal = VM_NextMemOperand(state);
            //     ptr = VM_Ptr(state, i.args[0].uintVal);
            //     val = VM_PopInt(state);
            //     *ptr = val;
            //     logi("[ %x ] pop mem [%x/%d] <- %d", i.pc, i.args[0].uintVal, i.args[0].uintVal, val);
            //     break;
            // }
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
            case 102:
            case 103:
                logi("[ %04x ] mov (%d)", i.pc, i.opcode);
                *i.args[0].ptr.intPtrVal = *i.args[1].ptr.intPtrVal;
                break;
            case 104: {
                // add reg, imm
                logi("[ %04x sp: %04x ] add r%d, %d", i.pc, i.sp, i.args[0].regVal, i.args[1].intVal);

                param = VM_ReadReg(state, i.args[0].regVal);
                param += i.args[1].intVal;
                VM_WriteReg(state, i.args[0].regVal, param);
                break;
            }
            // case 90:
            //     param2 = VM_PopInt(state);
            //     param = VM_PopInt(state);
            //
            //
            //     break;
            // case 91:
            // // case 92:
            // case 93:
            // case 94:
            // case 95:
            // case 96:
            // case 97:
            // case 98:
            // case 99:
            // case 100:
            // case 101:

            //     switch (i.opcode) {
            //         case 92:
            //             VM_PushInt(state, param - param2);
            //             break;
            //         case 94:
            //             VM_PushInt(state, param > param2);
            //             break;
            //         case 98:
            //             logi("s_eq: %d == %d", param, param2);
            //             VM_PushInt(state, param == param2);
            //             break;
            //         default:
            //
            //     }
            //
            //     break;
            case 192:
            case 200:
            case 201:
            case 202: {
                param2 = VM_PopInt(state);
                param = VM_PopInt(state);
                switch (i.opcode) {
                    case 192:
                        // s_cmp
                        logi("[ %04x sp: %04x ] s_cmp (%d, %d)", i.pc, i.sp, param, param2);

                        state->cf &= 0xf0;

                        if (param == param2) state->cf |= 0x01;
                        if (param > param2) state->cf |= 0x02;
                        if (param < param2) state->cf |= 0x04;
                        break;
                    case 200:
                        logi("[ %04x sp: %04x ] s_add (%d + %d)", i.pc, i.sp, param, param2);
                        VM_PushInt(state, param + param2);
                        break;
                    case 201:
                        logi("[ %04x sp: %04x ] s_sub (%d - %d)", i.pc, i.sp, param, param2);
                        VM_PushInt(state, param - param2);
                        break;
                    case 202:
                        logi("[ %04x sp: %04x ] s_mul (%d * %d)", i.pc, i.sp, param, param2);
                        VM_PushInt(state, param * param2);
                        break;
                    default:
                        logi("Unhandled stack op: %d\n", i.opcode);
                }
                break;
            }
            case 248:
                // i.args[0].intVal = VM_NextShort(state);
                logi("[ %04x ] trap %d", i.pc, i.args[0].intVal);
                if (!G.config.trap_func(state, i.args[0].intVal)) {
                    logi("Unhandled trap: %d\n", i.args[0].intVal);
                }
                break;
            default:
                logi("[ %04x ] Unhandled opcode: %d\n", i.pc, i.opcode);
                state->isRunning = false;
                break;
        }
    }

    // LogInfo("script finished running");
    return true;
}

bool VM_Call(vm_state_t *state, uint16_t addr) {
    if (!state) {
        return false;
    }

    if (state->isRunning) {
        exit(0);
    }

    VM_PushInt(state, state->pc);
    VM_SetPC(state, addr);
    return VM_Run(state);
}

void VM_LoadState(i16 stateID, neo_buf_reader_t *reader) {
    char scriptName[20];
    vm_state_t *state = VM_StateForID(stateID);

    if (state == NULL) {
        Neo_Panic("VM_LoadState: VM_StateForID returned NULL");
    }

    Neo_Buf_ReadString(reader, scriptName, 20);

    if (!VM_AttachState(stateID, VM_GetScript(scriptName))) {
        Neo_Panic("VM_LoadState: Couldn't attach state");
    }

    state->pc = Neo_Buf_ReadUInt16(reader);
    state->sp = Neo_Buf_ReadUInt16(reader);
    state->bp = Neo_Buf_ReadUInt16(reader);
    state->cf = Neo_Buf_ReadUInt16(reader);
    state->e0 = Neo_Buf_ReadUInt16(reader);
    state->e1 = Neo_Buf_ReadUInt16(reader);
    Neo_Buf_ReadData(reader, state->ram, 256);
}

void VM_SaveState(i16 stateID, neo_buf_writer_t *writer) {
    vm_state_t *state = VM_StateForID(stateID);

    if (state == NULL) {
        Neo_Panic("VM_SaveState: Couldn't attach state");
    }

    Neo_Buf_WriteString(writer, state->script->name);
    Neo_Buf_WriteUInt16(writer, state->pc);
    Neo_Buf_WriteUInt16(writer, state->sp);
    Neo_Buf_WriteUInt16(writer, state->bp);
    Neo_Buf_WriteUInt16(writer, state->cf);
    Neo_Buf_WriteUInt16(writer, state->e0);
    Neo_Buf_WriteUInt16(writer, state->e1);
    Neo_Buf_WriteData(writer, state->ram, 256);
}

void VM_Init(vm_config_t config) {
    int i;

    logi("VM_Init: State size: %d", sizeof(G));
    memset(&G, 0, sizeof(G));
    G.scripts = calloc(MAX_SCRIPTS, sizeof(vm_script_t));
    G.config = config;

    for (i = 0; i < MAX_STATES; i++) {
        G.states[i].id = -1;
    }
}
