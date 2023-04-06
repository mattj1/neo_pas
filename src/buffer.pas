unit buffer;

{$mode tp}

interface

uses
  engine;

type


  PBufferWriter = ^TBufferWriter;

  BufferWriteIntProc = procedure(writer: PBufferWriter; Value: integer);

  TBufferWriter = record
    writeInt: BufferWriteIntProc;
    userData: Pointer;
  end;

procedure Buf_WriteInt(writer: PBufferWriter; Value: integer);

implementation

procedure Buf_WriteInt(writer: PBufferWriter; Value: integer);
begin
  writer^.writeInt(writer, Value);
end;

end.
