#ifndef VM_H
#define VM_H

#include <neo.h>

#define VM_MAX_SCRIPT_EXPORTS 8

// typedef struct vm_state_s vm_state_t;
typedef struct vm_state_t vm_state_t;
typedef neo_buf_reader_t (*vm_script_load_func)(const char *name);
typedef bool (*vm_trap_func)(vm_state_t *state, uint8_t trapNo, bool isInvoke, uint16_t self);
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

struct vm_state_t
{
    int16_t id;             // -1 = unused
    int16_t refCount;
    uint8_t ram[256];
    vm_script_t *script;

    // Registers
    uint16_t r0, r1, sp, bp;

    uint16_t pc;

    // This is the game-specific handle that the state is connected to. 0 = none.
    uint16_t self;

    uint8_t cf;

    bool isRunning;
}; // vm_state_t;


void VM_LoadState(i16 stateID, neo_buf_reader_t *reader);
void VM_SaveState(i16 stateID, neo_buf_writer_t *writer);

extern void VM_Init(vm_config_t config);
extern vm_script_t *VM_GetScript(const char *name);
extern vm_state_t *VM_StateForID(i16 state_id);
extern vm_state_t *VM_StateForHandle(const uint16_t handle);
extern bool VM_CreateState(i16 *out_state_id);
extern bool VM_AttachState(i16 state_id, vm_script_t *script);
extern void VM_ReleaseState(vm_state_t *state);
extern bool VM_GetExport(vm_state_t *state, const char *name, uint16_t *out_addr);
extern bool VM_SetPC(vm_state_t *state, uint16_t addr);
extern bool VM_Call(vm_state_t* state, uint16_t addr);
bool VM_CallExport(vm_state_t *state, const char *name);
extern bool VM_Run(vm_state_t *state);

uint16_t VM_ReadReg(vm_state_t *state, uint8_t reg);
int16_t VM_ReadShort(vm_state_t *state, uint16_t addr);
uint16_t VM_ReadUShort(vm_state_t *state, uint16_t addr);
const char *VM_ReadAddrToString(vm_state_t *state, uint16_t addr);
uint16_t VM_PopInt(vm_state_t *state);
const char *VM_PopAddrToString(vm_state_t *state);

#endif

