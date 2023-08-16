unit Sys;

{$mode tp}{$H+}

interface

uses Event, Engine;

type 
     PFile = ^TFile;

 TFile = record
  pointer: Pointer;
end;

function File_OpenImpl(fileName: PChar; _file: PFile): boolean; external;
function File_BlockReadImpl(_file: PFile; var buf; size: integer): integer; external;
procedure ConsoleLog1(s: PChar);
{$I sys.inc}

procedure FillChar(var x;count : {$ifdef FILLCHAR_HAS_SIZEUINT_COUNT}SizeUInt{$else}SizeInt{$endif};value : byte );

procedure ConsoleLogImpl(s: PChar); external;

procedure ConsoleLog(s: string);
implementation

uses Text;

procedure ConsoleLog(s: string);
begin
     ConsoleLogImpl(PChar(s))
end;

procedure ConsoleLog1(s: PChar);
begin
     ConsoleLogImpl(s)
end;

procedure FillChar(var x;count : {$ifdef FILLCHAR_HAS_SIZEUINT_COUNT}SizeUInt{$else}SizeInt{$endif};value : byte );
begin
end;

function File_Open(fileName: string; var _file: TFile): boolean;
begin
     File_Open := File_OpenImpl(PChar(fileName), @_file);
end;

procedure File_Close(var _file: TFile);
begin
  // System.Close(_file._file);
end;

procedure File_BlockRead(_file: TFile; var buf; size: integer);
begin
     // BlockRead(_file._file, buf, size);
     File_BlockReadImpl(@_file, buf, size);
end;

procedure File_Seek(_file: TFile;Pos:Int64);
begin
     // Seek(_file._file, Pos);
end;

function File_Pos(_file: TFile): Int64;
begin
    // File_Pos := FilePos(_file._file);
end;

function File_EOF(_file: TFile): boolean;
begin
     File_EOF := true;
    // File_Pos := FilePos(_file._file);
end;


procedure SYS_PollEvents;

var
  sc: scanCode;

begin
  

end;

procedure SYS_InitGraphicsDriver(driverType: integer);
begin

end;

end.
