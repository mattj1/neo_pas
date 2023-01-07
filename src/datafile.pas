unit datafile;

{$ifdef fpc}
{$mode tp}
{$endif}

interface

procedure Datafile_Init;
function Datafile_Open(Name: string; var f: file; recSize: integer): boolean;
procedure Datafile_Close(var f: file);

implementation

uses strings;

type
  PEntry = ^entry;

  entry = record
    Name: array[0..8] of byte;
    offset: integer;
  end;


  PEntryArray = ^EntryArray;
  EntryArray = array[0..2048] of Entry;

var
  _numEntries: integer;
  _entries: PEntryArray;
  _start: longint;


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
      Reset(f, recSize);
      { writeln('found ', Name, ' at offs ', _start + _entries^[i].offset); }
      Seek(f, _start + _entries^[i].offset);
      Datafile_Open := True;

      Exit;
    end;
  end;

  Assign(f, Name + '.bin');
  Reset(f, recSize);
  Datafile_Open := True;
end;

procedure Datafile_Close(var f: file);
begin
  System.Close(f);
end;

procedure Datafile_Init;
var
  i, l: integer;
  _file: File;

begin
  Assign(_file, 'data.dat');
  Reset(_file, 1);

  BlockRead(_file, _numEntries, sizeof(integer));
  writeln(sizeof(entry));
  l := sizeof(entry) * _numEntries;

  GetMem(_entries, l);

  writeln('num entries ', _numEntries);

  for i := 1 to _numEntries do
  begin
    BlockRead(_file, _entries^[i].Name, 9);
    BlockRead(_file, _entries^[i].offset, sizeof(integer));

    writeln(PChar(@_entries^[i].Name), ' ', _entries^[i].offset);
  end;

  _start := FilePos(_file);
  System.Close(_file);
end;


end.
