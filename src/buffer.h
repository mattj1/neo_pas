#ifndef NEO_BUF_H
#define NEO_BUF_H

#include <stdint.h>
#include <stdio.h>

/* ---------------------------------------------------------------------------
 * Reader
 * --------------------------------------------------------------------------- */

typedef struct neo_buf_reader
{
    FILE* file; /* non-NULL when reading from FILE* */
    uint8_t* mem; /* non-NULL when reading from memory */
    size_t mem_len; /* total size of memory buffer */
    uint16_t mem_pos; /* current read position in memory */
    int16_t valid; /* 1 = usable, 0 = invalid / exhausted / error */
} neo_buf_reader_t;

neo_buf_reader_t Neo_Buf_CreateReaderFromFile(FILE* f);
neo_buf_reader_t Neo_Buf_CreateReaderFromMemory(void* mem, size_t length);

int16_t Neo_Buf_ReaderIsValid(const neo_buf_reader_t* reader);

/* Integer readers (little-endian) */
uint8_t Neo_Buf_ReadUInt8(neo_buf_reader_t* reader);
int8_t Neo_Buf_ReadInt8(neo_buf_reader_t* reader);
uint16_t Neo_Buf_ReadUInt16(neo_buf_reader_t* reader);
int16_t Neo_Buf_ReadInt16(neo_buf_reader_t* reader);
uint32_t Neo_Buf_ReadUInt32(neo_buf_reader_t* reader);
int32_t Neo_Buf_ReadInt32(neo_buf_reader_t* reader);

/* Generic data and length-prefixed string (max 255 bytes + null) */
int16_t Neo_Buf_ReadData(neo_buf_reader_t* reader, void* dest, uint16_t size);
void Neo_Buf_ReadString(neo_buf_reader_t* reader, char* dest, uint8_t size);

/* ---------------------------------------------------------------------------
 * Writer
 * --------------------------------------------------------------------------- */

typedef struct neo_buf_writer
{
    FILE* file; /* non-NULL when writing to FILE* */
    uint8_t* mem; /* non-NULL when writing to memory */
    uint16_t mem_cap; /* capacity of memory buffer */
    uint16_t mem_pos; /* current write position in memory */
    int16_t valid; /* 1 = usable, 0 = invalid / full / error */
} neo_buf_writer_t;

neo_buf_writer_t Neo_Buf_CreateWriterFromFile(FILE* f);
neo_buf_writer_t Neo_Buf_CreateWriterFromMemory(void* mem, uint16_t capacity);

int16_t Neo_Buf_WriterIsValid(const neo_buf_writer_t* writer);

/* Integer writers (little-endian) */
void Neo_Buf_WriteUInt8(neo_buf_writer_t* writer, uint8_t value);
void Neo_Buf_WriteInt8(neo_buf_writer_t* writer, int8_t value);
void Neo_Buf_WriteUInt16(neo_buf_writer_t* writer, uint16_t value);
void Neo_Buf_WriteInt16(neo_buf_writer_t* writer, int16_t value);
void Neo_Buf_WriteUInt32(neo_buf_writer_t* writer, uint32_t value);
void Neo_Buf_WriteInt32(neo_buf_writer_t* writer, int32_t value);

/* Generic data and length-prefixed string (max 255 bytes) */
void Neo_Buf_WriteData(neo_buf_writer_t* writer, const void* src, uint16_t size);
void Neo_Buf_WriteString(neo_buf_writer_t* writer, const char* str);

uint16_t Neo_Buf_ReaderGetPos(const neo_buf_reader_t* reader);
void Neo_Buf_ReaderSeek(neo_buf_reader_t* reader, uint16_t pos); /* absolute from start */
void Neo_Buf_ReaderClose(neo_buf_reader_t* reader);
void Neo_Buf_WriterClose(neo_buf_writer_t* writer);

#endif /* NEO_BUF_H */
