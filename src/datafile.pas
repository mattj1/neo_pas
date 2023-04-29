unit datafile;

{$ifdef fpc}
{$mode tp}
{$endif}

interface

procedure Datafile_Init;
function Datafile_Open(Name: string; var f: file; recSize: integer): boolean;
procedure Datafile_Close(var f: file);
procedure Datafile_ReadString(var f: file; var s: string);
function DirExists(Name: String): Boolean;

implementation

uses strings, engine, dos
  {$ifdef fpc}
          , sysutils
  {$else}

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


{$ifdef fpc}
function DirExists(Name: string): boolean;
var

  DirInfo: TSearchRec;         { For Windows, use TSearchRec }
begin
  DirExists := False;
  if FindFirst(Name, Directory, DirInfo) = 0 then begin
    DirExists := True;
  end;
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
  { writeln('DataFile_Open ', Name); }
  Datafile_Open := False;

  for i := 1 to _numEntries do
  begin
    if StrPas(@_entries^[i].Name) = Name then
    begin
      Assign(f, 'data.dat');
      Reset(f, 1);
      {      writeln('found ', Name, ' at offs ', _start + _entries^[i].offset); }
      Seek(f, _start + _entries^[i].offset);
      Datafile_Open := True;
      Exit;
    end;
  end;

  Assign(f, Name + '.bin');
  Reset(f, 1);
  Datafile_Open := True;
end;

procedure Datafile_Close(var f: file);
begin
  System.Close(f);
end;

procedure Datafile_Init;
var
  i, l: integer;
  _file: file;
{  currentDir: string;
}
begin
 { currentDir := GetCurrentDir;
  writeln('Datafile_Init, working directory: ', GetCurrentDir); }
  Assign(_file, 'data.dat');
  Reset(_file, 1);

  BlockRead(_file, _numEntries, sizeof(integer));

  l := sizeof(entry) * _numEntries;

  GetMem(_entries, l);

  writeln('Datafile_Init: Number of entries: ', _numEntries);

  for i := 1 to _numEntries do
  begin
    BlockRead(_file, _entries^[i].Name, 9);
    BlockRead(_file, _entries^[i].offset, sizeof(integer));

    {writeln(PChar(@_entries^[i].Name), ' ', _entries^[i].offset);}
  end;

  _start := FilePos(_file);
  System.Close(_file);
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

end.
