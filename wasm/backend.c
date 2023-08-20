#include <stdio.h>
#include <stdlib.h>
#include <memory.h>

#define fmClosed 0xD7B0
#define  fmInput  0xD7B1
#define  fmOutput 0xD7B2
#define  fmInOut  0xD7B3
#define  fmAppend 0xD7B4

extern unsigned short GetErrorCode();

void *INITFINAL;
void *_stack_top;

void stdout_putc(char ch) {
    fputc(ch, stdout);
}

void _haltproc() {
    printf("_haltproc ErrorCode: %d\n", GetErrorCode());
}

unsigned int SysMemSize(void *ptr) {
    return *((int *)ptr - 1);
}

void *SysGetMem(unsigned int sz) {
    int *p = (int *)malloc(sz + 4);

    *p = sz; 
    // printf("SysGetMem... %d %d %d.  %d %d\n", sz, *p, SysMemSize(p + 1), p, p + 1);
    return p + 1;
}

void *SysAllocMem(unsigned int sz) {
    int *p = (int *)malloc(sz + 4);

    *p = sz; 
    // printf("SysAllocMem... %d %d %d.  %d %d\n", sz, *p, SysMemSize(p + 1), p, p + 1);
    memset(p + 1, 0, sz);
    return p + 1;
}

int SysFreeMem(void *ptr) {
    int sz = SysMemSize(ptr);
    int *p = (int *)ptr - 1;
    // printf("SysFreeMem... %d %d\n", ptr, sz);
    free(p);
    return sz;
}


int SysFreeMemSize(void *ptr, unsigned int _size) {
    int sz = SysMemSize(ptr);
    int *p = (int *)ptr - 1;
    // printf("SysFreeMemSize... %d %d\n", ptr, sz);
    free(p);
    return sz;
}

void *SysReAllocMem(void *ptr, unsigned int sz) {
    // printf("SysReAllocMem %d\n", ptr);
    int oldBlockSz = SysMemSize(ptr);
    // printf("SysReAllocMem %d %d, will realloc orig size %d\n", ptr, sz, oldBlockSz);
    int *newBlock = SysGetMem(sz);

    if (sz > oldBlockSz)
        sz = oldBlockSz;

    memcpy(newBlock, ptr, sz);

    SysFreeMem(ptr);

    return newBlock;
}

int Do_FileSize_Impl(int handle) {
    FILE *f = (FILE *) handle;
    int pos = ftell(f);

    fseek(f, 0, SEEK_END);
    int sz = ftell(f);

    fseek(f, pos, SEEK_SET);

    return sz;
}

int Do_Open_Impl(const char *fileName, void *userData, int mode) {
    printf("Do_Open_Impl: %s mode %d\n", fileName, mode);

    const char *fileMode = "";
    switch(mode) {
    case fmClosed: 
        printf("fmClosed\n");
        return 0; 
    case fmInput: printf("fmInput\n"); fileMode = "r"; break;
    case fmOutput: printf("fmOutput\n"); fileMode = "w"; break;
    case fmInOut: printf("fmInOut\n"); fileMode = "a+"; break;
           case fmAppend: printf("fmAppend\n"); fileMode = "a"; break; 
    }

    FILE *f = fopen(fileName, fileMode);
    printf("after fopen: %d\n", f);
    memcpy(userData, &f, sizeof(FILE *));

    return f != NULL ? 1 : 0;
}

int Do_Write_Impl(int handle, void *addr, int len) {
    // printf("Do_Write_Impl %d %d %d\n", handle, addr, len);
    return fwrite((FILE *)handle, len, 1, addr);;
}

void Do_Seek_Impl(int handle, int offset) {
    fseek((FILE *) handle, offset, SEEK_SET);
}

