#include "neo.h"
#include <string.h>

/* ---------------------------------------------------------------------------
 * Internal helpers
 * --------------------------------------------------------------------------- */

static void reader_fail(neo_buf_reader_t *r, const char *msg)
{
    r->valid = 0;
    Neo_Panic(msg);
}

static void writer_fail(neo_buf_writer_t *w, const char *msg)
{
    w->valid = 0;
    Neo_Panic(msg);
}

static int16_t reader_ensure(neo_buf_reader_t *r, uint16_t nbytes)
{
    if (!r->valid) {
        return 0;
    }
    if (r->file != NULL) {
        return 1; /* FILE* checked on actual read */
    }
    if (r->mem == NULL) {
        reader_fail(r, "Neo_Buf: reader has no source");
        return 0;
    }
    if ((uint32_t)r->mem_pos + nbytes > r->mem_len) {
        reader_fail(r, "Neo_Buf: memory buffer underrun");
        return 0;
    }
    return 1;
}

static int16_t writer_ensure(neo_buf_writer_t *w, uint16_t nbytes)
{
    if (!w->valid) {
        return 0;
    }
    if (w->file != NULL) {
        return 1;
    }
    if (w->mem == NULL) {
        writer_fail(w, "Neo_Buf: writer has no destination");
        return 0;
    }
    if ((uint32_t)w->mem_pos + nbytes > w->mem_cap) {
        writer_fail(w, "Neo_Buf: memory buffer overrun");
        return 0;
    }
    return 1;
}

/* ---------------------------------------------------------------------------
 * Reader creation / validity
 * --------------------------------------------------------------------------- */

neo_buf_reader_t Neo_Buf_CreateReaderFromFile(FILE *f)
{
    neo_buf_reader_t r;
    r.file    = f;
    r.mem     = NULL;
    r.mem_len = 0;
    r.mem_pos = 0;
    r.valid   = (f != NULL) ? 1 : 0;
    if (!r.valid) {
        Neo_Panic("Neo_Buf: CreateReaderFromFile received NULL FILE*");
    }
    return r;
}

neo_buf_reader_t Neo_Buf_CreateReaderFromMemory(void *mem, size_t length)
{
    neo_buf_reader_t r;
    r.file    = NULL;
    r.mem     = (uint8_t *)mem;
    r.mem_len = length;
    r.mem_pos = 0;
    r.valid   = (mem != NULL) ? 1 : 0;
    if (!r.valid) {
        Neo_Panic("Neo_Buf: CreateReaderFromMemory received NULL pointer");
    }
    return r;
}

int16_t Neo_Buf_ReaderIsValid(const neo_buf_reader_t *reader)
{
    return (reader != NULL && reader->valid) ? 1 : 0;
}

/* ---------------------------------------------------------------------------
 * Low-level byte read
 * --------------------------------------------------------------------------- */

static uint8_t reader_get_byte(neo_buf_reader_t *r)
{
    uint8_t b = 0;
    if (r->file != NULL) {
        if (fread(&b, 1, 1, r->file) != 1) {
            reader_fail(r, "Neo_Buf: FILE* read failed");
            return 0;
        }
    } else {
        if (!reader_ensure(r, 1)) {
            return 0;
        }
        b = r->mem[r->mem_pos++];
    }
    return b;
}

/* ---------------------------------------------------------------------------
 * Integer readers (little-endian)
 * --------------------------------------------------------------------------- */

uint8_t Neo_Buf_ReadUInt8(neo_buf_reader_t *reader)
{
    return reader_get_byte(reader);
}

int8_t Neo_Buf_ReadInt8(neo_buf_reader_t *reader)
{
    return (int8_t)reader_get_byte(reader);
}

uint16_t Neo_Buf_ReadUInt16(neo_buf_reader_t *reader)
{
    uint8_t lo = reader_get_byte(reader);
    uint8_t hi = reader_get_byte(reader);
    return (uint16_t)lo | ((uint16_t)hi << 8);
}

int16_t Neo_Buf_ReadInt16(neo_buf_reader_t *reader)
{
    return (int16_t)Neo_Buf_ReadUInt16(reader);
}

uint32_t Neo_Buf_ReadUInt32(neo_buf_reader_t *reader)
{
    uint32_t v = 0;
    v |= (uint32_t)reader_get_byte(reader);
    v |= (uint32_t)reader_get_byte(reader) << 8;
    v |= (uint32_t)reader_get_byte(reader) << 16;
    v |= (uint32_t)reader_get_byte(reader) << 24;
    return v;
}

int32_t Neo_Buf_ReadInt32(neo_buf_reader_t *reader)
{
    return (int32_t)Neo_Buf_ReadUInt32(reader);
}

/* ---------------------------------------------------------------------------
 * Data / string readers
 * --------------------------------------------------------------------------- */

int16_t Neo_Buf_ReadData(neo_buf_reader_t *reader, void *dest, uint16_t size)
{
    if (size == 0) {
        return 0;
    }
    if (reader->file != NULL) {
        if (fread(dest, 1, size, reader->file) != size) {
            reader_fail(reader, "Neo_Buf: FILE* ReadData failed");
        }
    } else {
        if (!reader_ensure(reader, size)) {
            return 0;
        }
        memcpy(dest, reader->mem + reader->mem_pos, size);
        reader->mem_pos = (uint16_t)(reader->mem_pos + size);
    }

    return 1;
}

void Neo_Buf_ReadString(neo_buf_reader_t *reader, char *dest, uint8_t size)
{
    uint8_t len = Neo_Buf_ReadUInt8(reader);

    if (len > size) {
        reader_fail(reader, "Neo_Buf: string length > buffer size");
        dest[0] = '\0';
        return;
    }

    if (!reader->valid) {
        dest[0] = '\0';
        return;
    }
    if (len > 255) { /* defensive, though uint8_t cannot exceed */
        reader_fail(reader, "Neo_Buf: string length > 255");
        dest[0] = '\0';
        return;
    }
    Neo_Buf_ReadData(reader, dest, len);
    dest[len] = '\0';
}

/* ---------------------------------------------------------------------------
 * Writer creation / validity
 * --------------------------------------------------------------------------- */

neo_buf_writer_t Neo_Buf_CreateWriterFromFile(FILE *f)
{
    neo_buf_writer_t w;
    w.file    = f;
    w.mem     = NULL;
    w.mem_cap = 0;
    w.mem_pos = 0;
    w.valid   = (f != NULL) ? 1 : 0;
    if (!w.valid) {
        Neo_Panic("Neo_Buf: CreateWriterFromFile received NULL FILE*");
    }
    return w;
}

neo_buf_writer_t Neo_Buf_CreateWriterFromMemory(void *mem, uint16_t capacity)
{
    neo_buf_writer_t w;
    w.file    = NULL;
    w.mem     = (uint8_t *)mem;
    w.mem_cap = capacity;
    w.mem_pos = 0;
    w.valid   = (mem != NULL) ? 1 : 0;
    if (!w.valid) {
        Neo_Panic("Neo_Buf: CreateWriterFromMemory received NULL pointer");
    }
    return w;
}

int16_t Neo_Buf_WriterIsValid(const neo_buf_writer_t *writer)
{
    return (writer != NULL && writer->valid) ? 1 : 0;
}

/* ---------------------------------------------------------------------------
 * Low-level byte write
 * --------------------------------------------------------------------------- */

static void writer_put_byte(neo_buf_writer_t *w, uint8_t b)
{
    if (w->file != NULL) {
        if (fwrite(&b, 1, 1, w->file) != 1) {
            writer_fail(w, "Neo_Buf: FILE* write failed");
        }
    } else {
        if (!writer_ensure(w, 1)) {
            return;
        }
        w->mem[w->mem_pos++] = b;
    }
}

/* ---------------------------------------------------------------------------
 * Integer writers (little-endian)
 * --------------------------------------------------------------------------- */

void Neo_Buf_WriteUInt8(neo_buf_writer_t *writer, uint8_t value)
{
    writer_put_byte(writer, value);
}

void Neo_Buf_WriteInt8(neo_buf_writer_t *writer, int8_t value)
{
    writer_put_byte(writer, (uint8_t)value);
}

void Neo_Buf_WriteUInt16(neo_buf_writer_t *writer, uint16_t value)
{
    writer_put_byte(writer, (uint8_t)(value & 0xFF));
    writer_put_byte(writer, (uint8_t)((value >> 8) & 0xFF));
}

void Neo_Buf_WriteInt16(neo_buf_writer_t *writer, int16_t value)
{
    Neo_Buf_WriteUInt16(writer, (uint16_t)value);
}

void Neo_Buf_WriteUInt32(neo_buf_writer_t *writer, uint32_t value)
{
    writer_put_byte(writer, (uint8_t)(value & 0xFF));
    writer_put_byte(writer, (uint8_t)((value >> 8) & 0xFF));
    writer_put_byte(writer, (uint8_t)((value >> 16) & 0xFF));
    writer_put_byte(writer, (uint8_t)((value >> 24) & 0xFF));
}

void Neo_Buf_WriteInt32(neo_buf_writer_t *writer, int32_t value)
{
    Neo_Buf_WriteUInt32(writer, (uint32_t)value);
}

/* ---------------------------------------------------------------------------
 * Data / string writers
 * --------------------------------------------------------------------------- */

void Neo_Buf_WriteData(neo_buf_writer_t *writer, const void *src, uint16_t size)
{
    if (size == 0) {
        return;
    }
    if (writer->file != NULL) {
        if (fwrite(src, 1, size, writer->file) != size) {
            writer_fail(writer, "Neo_Buf: FILE* WriteData failed");
        }
    } else {
        if (!writer_ensure(writer, size)) {
            return;
        }
        memcpy(writer->mem + writer->mem_pos, src, size);
        writer->mem_pos = (uint16_t)(writer->mem_pos + size);
    }
}

void Neo_Buf_WriteString(neo_buf_writer_t *writer, const char *str)
{
    uint16_t len = 0;
    if (str == NULL) {
        writer_fail(writer, "Neo_Buf: WriteString received NULL");
        return;
    }
    while (str[len] != '\0' && len < 255) {
        len++;
    }
    if (str[len] != '\0') {
        writer_fail(writer, "Neo_Buf: string longer than 255 bytes");
        return;
    }
    Neo_Buf_WriteUInt8(writer, (uint8_t)len);
    Neo_Buf_WriteData(writer, str, len);
}

/* ---------------------------------------------------------------------------
 * Position / seek / close (reader)
 * --------------------------------------------------------------------------- */

uint16_t Neo_Buf_ReaderGetPos(const neo_buf_reader_t *reader)
{
    long pos;

    if (reader == NULL || !reader->valid) {
        Neo_Panic("Neo_Buf: ReaderGetPos on invalid reader");
        return 0;
    }

    if (reader->file != NULL) {
        pos = ftell(reader->file);
        if (pos < 0 || pos > 65535L) {
            Neo_Panic("Neo_Buf: FILE* position out of uint16_t range");
            return 0;
        }
        return (uint16_t)pos;
    }

    return reader->mem_pos;
}

void Neo_Buf_ReaderSeek(neo_buf_reader_t *reader, uint16_t pos)
{
    if (reader == NULL || !reader->valid) {
        Neo_Panic("Neo_Buf: ReaderSeek on invalid reader");
        return;
    }

    if (reader->file != NULL) {
        if (fseek(reader->file, (long)pos, SEEK_SET) != 0) {
            reader_fail(reader, "Neo_Buf: FILE* seek failed");
        }
        return;
    }

    if (reader->mem == NULL) {
        reader_fail(reader, "Neo_Buf: reader has no source");
        return;
    }
    if (pos > reader->mem_len) {
        reader_fail(reader, "Neo_Buf: seek past end of memory buffer");
        return;
    }
    reader->mem_pos = pos;
}

void Neo_Buf_ReaderClose(neo_buf_reader_t *reader)
{
    if (reader == NULL) {
        return;
    }
    if (reader->file != NULL) {
        fclose(reader->file);
        reader->file = NULL;
    }
    reader->mem     = NULL;
    reader->mem_len = 0;
    reader->mem_pos = 0;
    reader->valid   = 0;
}

/* ---------------------------------------------------------------------------
 * Close (writer)
 * --------------------------------------------------------------------------- */

void Neo_Buf_WriterClose(neo_buf_writer_t *writer)
{
    if (writer == NULL) {
        return;
    }
    if (writer->file != NULL) {
        fclose(writer->file);
        writer->file = NULL;
    }
    writer->mem     = NULL;
    writer->mem_cap = 0;
    writer->mem_pos = 0;
    writer->valid   = 0;
}
