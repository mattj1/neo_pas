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

  TBufferReader = record
    readData: BufferReadDataProc;
    userData: Pointer;
    _file: file;
  end;


  PBufferWriter = ^TBufferWriter;

  BufferWriteIntProc = procedure(writer: PBufferWriter; Value: integer);
  BufferWriteDataProc = procedure(writer: PBufferWriter; Data: Pointer; length: integer);

  TBufferWriter = record
    writeData: BufferWriteDataProc;
    userData: Pointer;
    _file: file;
  end;

function Buf_ReadInt(reader: PBufferReader): integer;
function Buf_ReadLong(reader: PBufferReader): longint;
procedure Buf_ReadData(reader: PBufferReader; Data: Pointer; length: integer);
function Buf_ReadString(reader: PBufferReader): string;

procedure Buf_WriteInt(writer: PBufferWriter; Value: integer);
procedure Buf_WriteLong(writer: PBufferWriter; Value: longint);
procedure Buf_WriteData(writer: PBufferWriter; Data: Pointer; length: integer);
procedure Buf_WriteString(writer: PBufferWriter; Value: string);

implementation

function Buf_ReadInt(reader: PBufferReader): integer;
var
  Value: integer;
begin
  reader^.readData(reader, @Value, sizeof(integer));
  { writeln('Buf_ReadInt ', Value); }
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

end.
