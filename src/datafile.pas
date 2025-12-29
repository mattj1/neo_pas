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
