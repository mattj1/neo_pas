unit buffer;

{$ifdef fpc}
{$mode tp}
{$endif}

interface

uses
  engine;

type


  PBufferReader = ^TBufferReader;

  BufferReadIntProc = function(reader: PBufferReader): integer;
  BufferReadDataProc = procedure(reader: PBufferReader; Data: Pointer; length: integer);




  PBufferBase = ^TBufferBase;

  TBufferBase = record
    userData: Pointer;
    _file: file;
  end;

  BufferReaderGetPosProc = function(reader: PBufferReader): longint;
  BufferCloseProc = procedure(reader: PBufferBase);

  TBufferReader = record
    userData: Pointer;
    _file: file;
    pos: longint;
    readData: BufferReadDataProc;
    getPos: BufferReaderGetPosProc;
    closeProc: BufferCloseProc;
  end;


  PBufferWriter = ^TBufferWriter;

  BufferWriteIntProc = procedure(writer: PBufferWriter; Value: integer);
  BufferWriteDataProc = procedure(writer: PBufferWriter; Data: Pointer; length: integer);

  TBufferWriter = record
    writeData: BufferWriteDataProc;
    userData: Pointer;
    _file: file;
  end;

function Buf_ReadByte(reader: PBufferReader): byte;
function Buf_ReadInt(reader: PBufferReader): integer;
function Buf_ReadLong(reader: PBufferReader): longint;
procedure Buf_ReadData(reader: PBufferReader; Data: Pointer; length: integer);
function Buf_ReadString(reader: PBufferReader): string;

function Buf_GetReadPos(reader: PBufferReader): longint;

procedure Buf_CloseReader(reader: PBufferReader);

procedure Buf_WriteInt(writer: PBufferWriter; Value: integer);
procedure Buf_WriteLong(writer: PBufferWriter; Value: longint);
procedure Buf_WriteData(writer: PBufferWriter; Data: Pointer; length: integer);
procedure Buf_WriteString(writer: PBufferWriter; Value: string);

procedure Buf_CreateReaderForFile(var _file: file; var reader: TBufferReader);
procedure Buf_CreateReaderForMemory(var Data: PChar; var reader: TBufferReader);

implementation

procedure _FileReadData(reader: PBufferReader; Data: Pointer; length: integer);
begin
  BlockRead(reader^._file, Data^, length);
end;

function _FileGetPos(reader: PBufferReader): longint;
begin
  _FileGetPos := FilePos(reader^._file);
end;

procedure _FileClose(stream: PBufferBase);
begin
  System.Close(stream^._file);
end;

procedure _MemoryReadData(reader: PBufferReader; Data: Pointer; length: integer);
var
  bp: byte_ptr;
begin

  bp := reader^.userData;
  Inc(bp, reader^.pos);
  Move(bp^, Data^, length);
  Inc(reader^.pos, length);
end;

function _MemoryGetPos(reader: PBufferReader): longint;
begin
  _MemoryGetPos := reader^.pos;
end;

function Buf_ReadByte(reader: PBufferReader): byte;
var
  Value: byte;
begin
  reader^.readData(reader, @Value, sizeof(byte));
  Buf_ReadByte := Value;
end;

function Buf_ReadInt(reader: PBufferReader): integer;
var
  Value: integer;
begin
  reader^.readData(reader, @Value, sizeof(integer));
  Buf_ReadInt := Value;
end;

function Buf_ReadLong(reader: PBufferReader): longint;
var
  Value: longint;
begin
  reader^.readData(reader, @Value, sizeof(longint));
  { writeln('Buf_ReadInt ', Value); }
  Buf_ReadLong := Value;
end;

procedure Buf_ReadData(reader: PBufferReader; Data: Pointer; length: integer);
begin
  reader^.readData(reader, Data, length);
end;

function Buf_ReadString(reader: PBufferReader): string;
var
  Value: string;
  bp: ^byte;
  len: byte;
begin
  bp := @Value;

  reader^.readData(reader, @len, 1);
  bp^ := len;
  Inc(bp);
  reader^.readData(reader, bp, len);

  Buf_ReadString := Value;
end;

procedure Buf_WriteInt(writer: PBufferWriter; Value: integer);
begin
  writer^.writeData(writer, @Value, sizeof(integer));
end;

procedure Buf_WriteLong(writer: PBufferWriter; Value: longint);
begin
  writer^.writeData(writer, @Value, sizeof(longint));
end;

procedure Buf_WriteData(writer: PBufferWriter; Data: Pointer; length: integer);
begin
  writer^.writeData(writer, Data, length);
end;

procedure Buf_WriteString(writer: PBufferWriter; Value: string);
begin
  writer^.writeData(writer, @Value, Length(Value) + 1);
end;

function Buf_GetReadPos(reader: PBufferReader): longint;
begin
  Buf_GetReadPos := reader^.getPos(reader);
end;

procedure Buf_CreateReaderForFile(var _file: file; var reader: TBufferReader);
begin

  { Move(_file, reader._file, sizeof(file)); }
  reader.readData := _FileReadData;
  reader.getPos := _FileGetPos;
  reader._file := _file;
  reader.closeProc := _FileClose;
end;

procedure Buf_CreateReaderForMemory(var Data: PChar; var reader: TBufferReader);
begin
  reader.pos := 0;
  reader.userData := Data;
  reader.readData := _MemoryReadData;
  reader.getPos := _MemoryGetPos;
  reader.closeProc := nil;
end;

procedure Buf_CloseReader(reader: PBufferReader);
begin
  if Assigned(reader^.closeProc) then reader^.closeProc(PBufferBase(reader));
end;

end.
