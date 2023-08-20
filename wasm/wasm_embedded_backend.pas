unit wasm_embedded_backend;

{$H-}
{$mode fpc}

interface

uses SysUtils, ConsoleIO;

procedure InitWasmEmbeddedBackend;

procedure stdout_putc(ch: char); external;

function SysGetMem(Size: ptruint): pointer; external;
function SysFreeMem(Addr: Pointer): ptruint; external;
function SysFreeMemSize(Addr: Pointer;Size:ptruint): ptruint; external;
function SysAllocMem(Size: ptruint): pointer; external;
function SysReAllocMem(var p:pointer;Size:ptruint):Pointer; external;
function SysMemSize(p:pointer):ptruint; external;

function Do_Open_Impl(fileName: PChar; userData: Pointer; mode: longint): integer; external;
function Do_Write_Impl(h: longint; addr: Pointer; len: longint): integer; external;
procedure Do_Seek_Impl(handle, pos: longint); external;
function Do_FileSize_Impl(handle: longint): longint; external;

function ftell(f: Pointer): longint; external;
function fread(buf: Pointer; recSize: integer; numRec: integer; f: pointer): ptruint; external;
function fclose(f: Pointer): longint; external;

implementation

function Do_Read_Impl(h: longint; addr: Pointer; len: longint): integer;
begin
	Do_Read_Impl := fread(addr, 1, len, Pointer(h));
end;

procedure Do_Close_Impl(handle: longint);
begin
	fclose(Pointer(handle));
end;

function Do_FilePos_Impl(handle: longint) : longint;
begin
	Do_FilePos_Impl := ftell(Pointer(handle));
end;

const MyMemoryManager: TMemoryManager = (
        NeedLock: false;  // Obsolete
        GetMem: @SysGetMem;
        FreeMem: @SysFreeMem;
        FreeMemSize: @SysFreeMemSize;
        AllocMem: @SysAllocMem;
        ReAllocMem: @SysReAllocMem;
        MemSize: @SysMemSize;
        InitThread: nil;
        DoneThread: nil;
        RelocateHeap: nil;
        GetHeapStatus: nil; //@SysGetHeapStatus;
        GetFPCHeapStatus: nil; //@SysGetFPCHeapStatus;
        );

function WriteChar(ACh: AnsiChar; AUserData: pointer): boolean;
  begin
    stdout_putc(ACh);
    WriteChar:=true;
  end;


function ReadChar(var ACh: AnsiChar; AUserData: pointer): boolean;
  begin
    ReadChar:=false; { TODO }
 end;

procedure Do_Open(var f;p:PAnsiChar;flags:longint);
begin
  writeln('Do_Open...' , p , ' with flags ', flags);
   
   { convert filemode to filerec modes }
  case (flags and 3) of
   0 : filerec(f).mode:=fminput;
   1 : filerec(f).mode:=fmoutput;
   2 : filerec(f).mode:=fminout;
  end;

  if Do_Open_Impl(PChar(filerec(f).name), @filerec(f), filerec(f).mode) = 0 then begin
    InOutRes := 1;
  end;
end;


function GetErrorCode: WORD; alias:'GetErrorCode';
begin
  GetErrorCode := ErrorCode;
end;

procedure InitWasmEmbeddedBackend; alias:'InitWasmEmbeddedBackend';
begin
	SetMemoryManager(MyMemoryManager);
	ConsoleIO.OpenIO(Output, @WriteChar, @ReadChar, fmOutput, nil);

	rtl_do_close := trtl_do_close(@Do_Close_Impl);
	rtl_do_open := trtl_do_open(@Do_Open);
  	rtl_do_write := trtl_do_write(@Do_Write_Impl);
  	rtl_do_read := trtl_do_read(@Do_Read_Impl);
  	rtl_do_seek := trtl_do_seek(@Do_Seek_Impl);
  	rtl_do_filepos := trtl_do_filepos(@Do_FilePos_Impl);
  	rtl_do_filesize := trtl_do_filesize(@Do_FileSize_Impl);

	writeln('InitWasmEmbeddedBackend: Done!');
end;

begin
end.
