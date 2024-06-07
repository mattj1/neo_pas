unit datafile;



interface

uses buffer;

procedure Datafile_InitWithFile(path: string);
procedure Datafile_InitWithMemory(Data: PChar);
function Datafile_Open(Name: string; var f: file; recSize: integer): boolean;
function DataFile_OpenWithReader(Name: string; var reader: TBufferReader): boolean;
procedure Datafile_Close(var f: file);
procedure Datafile_ReadString(var f: file; var s: string);
function DirExists(Name: string): boolean;
procedure FS_CopyFile(srcPath, dstPath: string);

implementation

uses strings, engine, dos, console
  {$ifdef fpc}
{$ifndef WASM}
          , sysutils
  {$endif}
  {$endif}  ;

type
  PEntry = ^entry;

  entry = record
    Name: array[0..8] of byte;
    offset: integer;
  end;

  PEntryArray = ^EntryArray;
  EntryArray = array[1..2048] of Entry;

var
  _numEntries: integer;
  _entries: PEntryArray;
  _start: longint;
  _isMemoryBlob: boolean;
  _memoryBlob: Pointer;
  _path: string;


{$ifdef fpc}
function DirExists(Name: string): boolean;
{$ifndef WASM}
var
  DirInfo: TSearchRec;         { For Windows, use TSearchRec }
{$endif}
begin
  DirExists := False;
{$ifndef WASM}  
  if FindFirst(Name, Directory, DirInfo) = 0 then begin
    DirExists := True;
  end;
{$endif}
end;

  {$endif}

{$ifndef fpc}
function DirExists(Name: string): boolean;
var
  {$ifdef fpc}
  DirInfo: TSearchRec;         { For Windows, use TSearchRec }
  {$else}
  DirInfo: SearchRec;
  {$endif}
begin
  DirExists := False;
  FindFirst(Name, Directory, DirInfo); { Same as DIR *.PAS }
  while DosError = 0 do
  begin
    Writeln('found ', DirInfo.Name);
    DirExists := True;
    Exit;
  end;
end;

{$endif}

function Datafile_Open(Name: string; var f: file; recSize: integer): boolean;
var
  i: integer;
begin

  { Console_Print('DataFile_Open ' + Name); }

  Datafile_Open := False;

  for i := 1 to _numEntries do
  begin
    {Console_Print('check ' + itoa(i) + ': ' + StrPas(@_entries^[i].Name) + ' ' + itoa(_entries^[i].offset) + ' == ' + Name); 
    }if StrPas(@_entries^[i].Name) = Name then
    begin
      Assign(f, 'data.dat');
      Reset(f, 1);
      {Console_Print('found ' + Name + ' at offs ' + itoa(_start + _entries^[i].offset));}
      Seek(f, _start + _entries^[i].offset);
      Datafile_Open := True;
      Exit;
    end;
  end;

  Console_Print('DataFile_Open: did not find ' + Name);
  Assign(f, Name + '.bin');
  Reset(f, 1);
  Datafile_Open := True;
end;

procedure ReadData(reader: PBufferReader; Data: Pointer; length: integer);
begin
  BlockRead(reader^._file, Data^, length);
end;


function DataFile_OpenWithReader(Name: string; var reader: TBufferReader): boolean;
var
  i: integer;
  localPath: string;
begin
  DataFile_OpenWithReader := False;

  {$I-}
  localPath := 'mods/game/data/' + Name + '.bin';
  Assign(reader._file, localPath);
  Reset(reader._file, 1);
  {$I+}
  if IOResult = 0 then
  begin
    writeln('DataFile_OpenWithReader: Opening local file ', localPath);
    Buf_CreateReaderForFile(reader);
    DataFile_OpenWithReader := True;
    Exit;
  end;

  for i := 1 to _numEntries do
  begin
    {Console_Print('check ' + itoa(i) + ': ' + StrPas(@_entries^[i].Name) + ' ' + itoa(_entries^[i].offset) + ' == ' + Name);
    }if StrPas(@_entries^[i].Name) = Name then
    begin
      if _isMemoryBlob then
      begin
        {$ifdef USE_DATA_BLOB}
        Buf_CreateReaderForMemory(_memoryBlob, reader);
        reader.pos := _start + _entries^[i].offset;
        {$endif}
      end
      else
      begin
        Assign(reader._file, 'data.dat');
        Reset(reader._file, 1);
        {Console_Print('found ' + Name + ' at offs ' + itoa(_start + _entries^[i].offset));}
        Seek(reader._file, _start + _entries^[i].offset);
        Buf_CreateReaderForFile(reader);

      end;

      DataFile_OpenWithReader := True;
      Exit;

    end;
  end;

  Console_Print('DataFile_OpenWithReader: did not find ' + Name);
end;

procedure Datafile_Close(var f: file);
begin
  System.Close(f);
end;

procedure Datafile_Init(var reader: TBufferReader);
var
  i, l: integer;
begin

  _numEntries := Buf_ReadInt(@reader);
  { BlockRead(_file, _numEntries, sizeof(integer));  }

  l := sizeof(entry) * _numEntries;

  GetMem(_entries, l);

  Console_Print('Datafile_Init: Number of entries: ' + itoa(_numEntries));

  for i := 1 to _numEntries do
  begin
    Buf_ReadData(@reader, @_entries^[i].Name, 9);

    { BlockRead(_file, _entries^[i].Name, 9); }

    _entries^[i].offset := Buf_ReadInt(@reader);
    { BlockRead(_file, _entries^[i].offset, sizeof(integer)); }

    { Console_Print('Entry: ' + StrPas(@_entries^[i].Name) + ' ' + itoa(_entries^[i].offset)); }
  end;

  _start := Buf_GetReadPos(@reader); {FilePos(_file);}
end;

procedure Datafile_InitWithFile(path: string);
var
  currentDir: string;
  reader: TBufferReader;
begin
  { currentDir := GetCurrentDir;
  writeln('Datafile_Init, working directory: ', GetCurrentDir);
}

  _isMemoryBlob := False;
  _path := path;

  Assign(reader._file, _path);
  Reset(reader._file, 1);

  Buf_CreateReaderForFile(reader);
  Datafile_Init(reader);


  System.Close(reader._file);
end;

procedure Datafile_InitWithMemory(Data: PChar);
var
  reader: TBufferReader;
begin
  {$ifdef USE_DATA_BLOB}
  _isMemoryBlob := True;
  _memoryBlob := Data;

  Buf_CreateReaderForMemory(_memoryBlob, reader);
  Datafile_Init(reader);
  {$endif}
end;

procedure Datafile_ReadString(var f: file; var s: string);
var
  bp: byte_ptr;
  str_len: byte;
begin
  bp := @s;
  BlockRead(f, str_len, sizeof(byte));
  bp^ := str_len;
  Inc(bp);
  BlockRead(f, bp^, str_len);
end;

procedure FS_CopyFile(srcPath, dstPath: string);
var
  srcFile, dstFile: file;
  bytesRemaining, bytesToCopy: longint;
  buf: array[0..4095] of byte;
begin
  Assign(srcFile, srcPath);
  Reset(srcFile, 1);

  Assign(dstFile, dstPath);
  Rewrite(dstFile, 1);

  bytesRemaining := FileSize(srcFile);

  {$ifdef fpc}
  writeln('FS_CopyFile: ', srcPath, ' -> ', dstPath + '  Size: ', bytesRemaining);
  {$endif}

  repeat
    bytesToCopy := bytesRemaining;
    if bytesToCopy > 4096 then bytesToCopy := 4096;

    BlockRead(srcFile, buf, bytesToCopy);
    BlockWrite(dstFile, buf, bytesToCopy);

    Dec(bytesRemaining, bytesToCopy);

    {$ifdef fpc}
    { writeln('num bytes left to copy ', bytesRemaining); }
    {$endif}

  until bytesRemaining = 0;

  System.Close(srcFile);
  System.Close(dstFile);
end;

end.
