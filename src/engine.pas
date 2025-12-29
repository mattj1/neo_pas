unit engine;


interface

{$ifdef SDL2}
uses SDL2, SDL2_Image;
{$else}
{$endif}

type
  byte_ptr = ^byte;
  integer_ptr = ^integer;
  dIntArray = array [0..32760] of integer;
  pIntArray = ^dIntArray;

  scanCode = (
    kNone, kEsc, k1, k2, k3, k4, k5, k6, k7, k8, k9, k0, kMinus, kEqual,
    kBack, kTab, kQ, kW, kE, kR, kT, kY, kU, kI, kO, kP, kLBracket,
    kRBracket, kEnter, kCtrl, kA, kS, kD, kF, kG, kH, kJ, kK, kL, kColon,
    kQuote, kTilde, kLShift, kBackSlash, kZ, kX, kC, kV, kB, kN, kM, kComma,
    kPeriod, kSlash, kRShift, kPadStar, kAlt, kSpace, kCaps, kF1, kF2, kF3,
    kF4, kF5, kF6, kF7, kF8, kF9, kF10, kNum, kScroll, kHome, kUp, kPgUp,
    kPadMinus, kLf, kPad5, kRt, kPadPlus, kend, kDn, kPgDn, kIns, kDel,
    kSysReq, kUnknown55, kUnknown56, kF11, kF12);

  { Sound }

  PSoundEffect = ^TSoundEffect;

  TSoundEffect = record
    data: pIntArray;
    size: integer;
    length: integer;
  end;

  { Game loop }
type
  UpdateProc = procedure(deltaTime: integer);
  DrawProc = procedure;

type
  eventType = (
    SE_NONE, SE_KEYDOWN, SE_KEYUP, SE_KEYCHAR
    );

  TEvent = record
    eventType: eventType;
    param: integer;
    param2: integer;

    { SE_KEYDOWN }
    { param: scanCode }

    { SE_KEYCHAR }
    { param: scanCode }
    { param2: char }

  end;

  TKeyPress = record
    code: scanCode;
    ch: char;
  end;

  Event_KeyDownProc = procedure(sc: scanCode);
  Event_KeyUpProc = procedure(sc: scanCode);
  Event_KeyCharProc = procedure(ch: char);


type
  image_t = record
    Width: word;
    Height: word;
{$ifdef SDL2}
    surface: PSDL_Surface;
    texture: PSDL_Texture;
{$else}
    Data: byte_ptr;
{$endif}

  end;

  Palette = record
{$ifdef SDL2}
    sdlPalette: PSDL_Palette;
{$else}
    c: array[0..255] of array[0..2] of byte;
{$endif}
  end;

type
  {$ifdef fpc}
  R_FillColorProc = procedure(c: longint);
  {$else}
  R_FillColorProc = procedure(c: byte);
  {$endif}
  R_FillRectProc = procedure(x, y, w, h: integer; color: byte);
  R_DrawSubImageTransparentProc = procedure(var img: image_t;
    dstX, dstY, srcX, srcY, srcWidth, srcHeight: integer);
  R_DrawSubImageOpaqueProc = procedure(var img: image_t;
    dstX, dstY, srcX, srcY, srcWidth, srcHeight: integer);
  R_DrawSpriteProc = procedure(x, y: integer; var img: image_t);
  R_AllocPaletteProc = procedure(var pal: Palette);

  R_LoadPaletteProc = procedure(filename: string; var pal: Palette);
  R_SetPaletteColorProc = procedure(index: integer; r, g, b: byte);
  R_SetPaletteProc = procedure(var pal: Palette);

  R_DrawTextProc = procedure(x, y: integer; str: string);
  R_DrawLineProc = procedure(x0, y0, x1, y1, r, g, b, a: integer);
  R_SwapBuffersProc = procedure;
  R_InitProc = procedure;
  R_CloseProc = procedure;


{ Keyboard --------------------------------------------------------- }

{ Credit: http://swag.outpostbbs.net/KEYBOARD/0010.PAS.html }



const
  kPad7 = kHome;
  kPad8 = kUp;
  kPad9 = kPgUp;
  kPad4 = kLf;
  kPad6 = kRt;
  kPad1 = kend;
  kPad2 = kDn;
  kPad3 = kPgDn;
  letters = [kQ..kP, kA..kL, kZ..kM];
  numbers = [k1..k0, kPad1..kPad3, kPad4..kPad6, kPad7..kPad9];
  FunctionKeys = [kF1..kF10, kF11..kF12];
  keyPad = [kPadStar, kNum..kDel];

var
  keys: set of scanCode;
  prevKeys: set of ScanCode;

  pressedKeys: set of scanCode;

  lastKeyDown: scanCode;




function itoa(i: longint): string;
function WordToString(i: word): string;
function StrToPChar(const s: string): PChar;


var
  R_FillRect: R_FillRectProc;
  R_FillColor: R_FillColorProc;
  R_DrawSubImageTransparent: R_DrawSubImageTransparentProc;
  R_DrawSubImageOpaque: R_DrawSubImageOpaqueProc;
  R_DrawSprite: R_DrawSpriteProc;
  R_AllocPalette: R_AllocPaletteProc;
  R_LoadPalette: R_LoadPaletteProc;
  R_SetPaletteColor: R_SetPaletteColorProc;
  R_SetPalette: R_SetPaletteProc;
  R_SwapBuffers: R_SwapBuffersProc;
  R_DrawText: R_DrawTextProc;
  R_DrawLine: R_DrawLineProc;
  R_Init: R_InitProc;
  R_Close: R_CloseProc;


var
  shouldQuit: boolean;

type
  PBufferReader = ^TBufferReader;
  PBufferWriter = ^TBufferWriter;

  BufferReadIntProc = function(reader: PBufferReader): integer;
  BufferReadDataProc = procedure(reader: PBufferReader; Data: Pointer; length: integer);

  BufferWriteIntProc = procedure(writer: PBufferWriter; Value: integer);
  BufferWriteDataProc = procedure(writer: PBufferWriter; Data: Pointer; length: integer);

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

procedure Buf_CreateReaderForFile(var reader: TBufferReader);
procedure Buf_CreateReaderForMemory(var Data: PChar; var reader: TBufferReader);

procedure Console_Print(s: string);
procedure Console_DrawText;
procedure Console_Dump;
procedure Console_ToggleVisible;
function Console_IsVisible: boolean;
procedure Console_SetWriteStdOut(b: boolean);

procedure Event_Add(eventType: eventType; param, param2: integer);
procedure Event_ProcessEvents;
procedure Event_SetKeyDownProc(proc: Event_KeyDownProc);
procedure Event_SetKeyUpProc(proc: Event_KeyUpProc);
function Event_GetKeyPress(var keyPress: TKeyPress): boolean;
procedure Event_ClearKeypressQueue;

function I_IsKeyDown(sc: scanCode) : boolean;
function I_WasKeyReleased(sc: scanCode) : boolean;
function I_WasKeyPressed(sc: scanCode) : boolean;

procedure Keybrd_Init;

procedure Loop_SetUpdateProc(proc: UpdateProc);
procedure Loop_SetDrawProc(proc: DrawProc);
procedure Loop_Run;
procedure Loop_Cancel;

function Neo_Mouse_IsAvailable: boolean;
procedure Neo_Mouse_Init;

function SND_AllocSoundEffect(length: integer) : PSoundEffect;
function SND_LoadSoundEffect(filename: string) : PSoundEffect;
procedure SND_FreeSoundEffect(soundEffect: PSoundEffect);
procedure SND_PlaySound(snd: PSoundEffect);
procedure SND_Update;
function SND_IsPlaying : boolean;
procedure SND_Init;
procedure SND_Close;

procedure SYS_FlushStdIO;
procedure SYS_PollEvents;

procedure Timer_Init;
procedure Timer_Delay(ms: longint);
function Timer_GetTicks: longint;

procedure Neo_Init;
procedure Neo_Shutdown;

implementation


uses 
  {$ifdef PLATFORM_DOS}
  crt,
  dos,
  {$endif}
  text,
  strings;
  

function I_IsKeyDown(sc: scanCode) : boolean;
begin
     I_IsKeyDown := (sc in keys) or (sc in pressedKeys);
end;

function I_WasKeyReleased(sc: scanCode) : boolean;
begin
     I_WasKeyReleased := (not (sc in keys)) and (sc in prevKeys);
end;

function I_WasKeyPressed(sc: scanCode) : boolean;
begin
     I_WasKeyPressed := (sc in keys) and (not(sc in prevKeys));
end;

function WordToString(i: word): string;
var s: string;
begin
  str(i, s);
  WordToString := s;
end;

function itoa(i: longint): string;
var s: string;
begin
  str(i, s);
  itoa := s;
end;


var StrToPCharBuf: array[0..1023] of byte;

function StrToPChar(const s: string): PChar;
var p: PChar;
begin
  StrPCopy(@StrToPCharBuf, s);

  StrToPChar := @StrToPCharBuf;
end;

procedure SYS_FlushStdIO;
begin
  {$ifdef FPC_HAS_FEATURE_CONSOLEIO}
  {$ifndef EMBEDDED}
  SysFlushStdIO;
  {$endif EMBEDDED}
  {$endif FPC_HAS_FEATURE_CONSOLEIO}
end;

{
########  ##     ## ######## ######## ######## ########  
##     ## ##     ## ##       ##       ##       ##     ## 
##     ## ##     ## ##       ##       ##       ##     ## 
########  ##     ## ######   ######   ######   ########  
##     ## ##     ## ##       ##       ##       ##   ##   
##     ## ##     ## ##       ##       ##       ##    ##  
########   #######  ##       ##       ######## ##     ## 
}


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

  { writeln('IOResult ', IOResult);}
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

{ It is up to the user to set reader._file, since Turbo Pascal doesn't let you assign "file" values }

procedure Buf_CreateReaderForFile(var reader: TBufferReader);
begin

  { Move(_file, reader._file, sizeof(file)); }
  {reader.readData := _FileReadData;
  reader.getPos := _FileGetPos;
  reader.closeProc := _FileClose;}
end;

procedure Buf_CreateReaderForMemory(var Data: PChar; var reader: TBufferReader);
begin
  reader.pos := 0;
  reader.userData := Data;
  {reader.readData := _MemoryReadData;
  reader.getPos := _MemoryGetPos;}
  reader.closeProc := nil;
end;

procedure Buf_CloseReader(reader: PBufferReader);
begin
  if Assigned(reader^.closeProc) then reader^.closeProc(PBufferBase(reader));
end;

{
 ######   #######  ##    ##  ######   #######  ##       ######## 
##    ## ##     ## ###   ## ##    ## ##     ## ##       ##       
##       ##     ## ####  ## ##       ##     ## ##       ##       
##       ##     ## ## ## ##  ######  ##     ## ##       ######   
##       ##     ## ##  ####       ## ##     ## ##       ##       
##    ## ##     ## ##   ### ##    ## ##     ## ##       ##       
 ######   #######  ##    ##  ######   #######  ######## ######## 
}


var
  msg: array[0..31] of array[0..100] of char;
  p: integer;
  visible: boolean;
  writeStdOut: boolean;

procedure Console_SetWriteStdOut(b: boolean);
begin
  writeStdOut := b;
end;

procedure Console_Print(s: string);
begin
              {$ifdef fpc}  writeln('Console_Print');  {$endif}
  { TODO: Ensure that the string isn't longer than 100 characters }
  if writeStdOut then begin
    writeln(s);
{$ifdef fpc}
{$ifndef WASM}
    write(#27'[0m');
    SYS_FlushStdIO;
{$endif}
{$endif}

  end;
  StrPCopy(msg[p and 31], s);
  Inc(p);
end;


procedure Console_Dump;
var
  j: integer;
begin

  for j := (p - 31) to (p - 1) do
  begin
    if j >= 0 then
    begin
      writeln(msg[j and 31]);
      {$ifdef fpc}
      write(#27'[0m');
      {$endif}
    end;
  end;
end;

procedure Console_DrawText;
var
  i, j: integer;
begin
  if not visible then Exit;

  i := 10;
  Text_FillRectEx(0, 0, 80, 11, 0, 7, $ff);
  for j := (p - 1) downto (p - 31) do
  begin
    if j >= 0 then
    begin
      Text_DrawColorStringEx(0, i, msg[j and 31], 7, $ff);
    end;

    dec(i);
    if i < 0 then break;
  end;

  Text_FillRectEx(0, 11, 80, 1, 205, 7, $ff);
end;

procedure Console_ToggleVisible;
begin
  visible := not visible;
end;

function Console_IsVisible: boolean;
begin
  Console_IsVisible := visible;
end;


{
######## ##     ## ######## ##    ## ######## 
##       ##     ## ##       ###   ##    ##    
##       ##     ## ##       ####  ##    ##    
######   ##     ## ######   ## ## ##    ##    
##        ##   ##  ##       ##  ####    ##    
##         ## ##   ##       ##   ###    ##    
########    ###    ######## ##    ##    ##    
}


const
  MAX_EVENTS: integer = 64;
var
  _keyDownProc: Event_KeyDownProc;
  _keyUpProc: Event_KeyUpProc;
  _keyCharProc: Event_KeyCharProc;
  lastKeyChar: char;

var
  events: array[0..63] of TEvent;
  event_head, event_tail: integer;
  keyPresses: array[0..7] of TKeyPress;
  keyPressCount: integer;
  keyPressTail: integer;

procedure Event_SetKeyDownProc(proc: Event_KeyDownProc);
begin
  _keyDownProc := proc;
end;

procedure Event_SetKeyUpProc(proc: Event_KeyUpProc);
begin
  _keyUpProc := proc;
end;

var _event_is_adding: boolean;

function _Event_Reserve: integer;
begin
  event_head := (event_head + 1) and (MAX_EVENTS - 1);
  _Event_Reserve := event_head;
end;

procedure _Event_Set(idx: integer; eventType: eventType; param, param2: integer);
begin
  events[idx].eventType := eventType;
  events[idx].param := param;
  events[idx].param2 := param2;
end;

procedure Event_Add(eventType: eventType; param, param2: integer);
var
  nextHead: integer;
begin
  if _event_is_adding then begin
    { writeln('Event_Add START ', _event_is_adding); }
  end;
  _event_is_adding := True;

  nextHead := (event_head + 1) and (MAX_EVENTS - 1);

  if nextHead <> event_tail then
  begin
    event_head := nextHead;

    { writeln('Event_Add: #', event_head, ', type: ', ord(eventType)); }
    _Event_Set(event_head, eventType, param, param2);

  end else begin
    { writeln('didn''t add event'); }
  end;

  _event_is_adding := False;
end;

procedure Event_ProcessEvents;
var
  e: TEvent;

begin
  {writeln('Event_ProcessEvents ', head, ' ', tail);}

  while event_tail <> event_head do
  begin
    event_tail := (event_tail + 1) and (MAX_EVENTS - 1);

    e := events[event_tail];
    if e.eventType <> SE_NONE then begin
      {writeln('process event tail #', event_tail, ' type: ', ord(e.eventType), ' param: ', e.param);}
    end;
    case e.eventType of
      SE_NONE:
      begin
      end;

      SE_KEYDOWN:
      begin
        writeln('SE_KEYDOWN ', e.param);
        lastKeyDown := scanCode(e.param);
        Include(engine.keys, lastKeyDown);

        if Assigned(_keyDownProc) then _keyDownProc(lastKeyDown);
{
        keyPresses[keyPressCount].ch := chr(0);
        keyPresses[keyPressCount].code := scanCode(e.param);
        Inc(keyPressCount);
        keyPressCount := (keyPressCount and 7);
}

        {common.keys := common.keys + [scanCode(e.param)];}
      end;
      SE_KEYUP:
      begin
        writeln('SE_KEYUP ', e.param);
        engine.keys := engine.keys - [scanCode(e.param)];

        if Assigned(_keyUpProc) then _keyUpProc(scanCode(e.param));
      end;
      SE_KEYCHAR:
      begin
        if Assigned(_keyCharProc) then _keyCharProc(chr(e.param));

        lastKeyChar := chr(e.param);

        keyPresses[keyPressCount].code := scanCode(e.param);
        keyPresses[keyPressCount].ch := chr(e.param2);
        Inc(keyPressCount);
        keyPressCount := (keyPressCount and 7);

        { writeln('SE_KEYCHAR: keypressCount: ', keyPressCount, ' tail: ', keyPressTail); }

      end;
      else
      begin
        {writeln('unhandled event #', event_tail, ' type: ', Ord(e.eventType), ' param: ', e.param);}
      end;
    end;

    events[event_tail].eventType := SE_NONE;

  end;
end;

procedure Event_ClearKeypressQueue;
begin
  keyPressTail := 0;
  keyPressCount:= 0;
  keyPresses[keyPressTail].code := kNone;
  keyPresses[keyPressTail].ch := chr(0);
end;

function Event_GetKeyPress(var keyPress: TKeyPress): boolean;
begin
  keyPress.code := kNone;
  keyPress.ch := chr(0);
  Event_GetKeyPress := False;
  if keyPressTail = keyPressCount then Exit;

  if (keyPresses[keyPressTail].code <> kNone) or (ord(keyPresses[keyPressTail].ch) <> 0) then begin
    keyPress := keyPresses[keyPressTail];
    Event_GetKeyPress := True;

    keyPresses[keyPressTail].code := kNone;
    keyPresses[keyPressTail].ch := chr(0);

    keyPressTail := (keyPresstail + 1) and 7;
  end;
end;

{
######## #### ##       ######## 
##        ##  ##       ##       
##        ##  ##       ##       
######    ##  ##       ######   
##        ##  ##       ##       
##        ##  ##       ##       
##       #### ######## ######## 
}

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
    { Writeln('found ', DirInfo.Name); }
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
      Assign(f, _path);
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
    writeln('DataFile_OpenWithReader: local: ', localPath);
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
        Assign(reader._file, _path);
        Reset(reader._file, 1);
        { Console_Print('DataFile_OpenWithReader: found ' + Name + ' at offs ' + itoa(_start + _entries^[i].offset)); }
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
  Console_Print('Datafile_InitWithFile: Using ' + path);

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




{
 ######   #######  ##     ## ##    ## ########  
##    ## ##     ## ##     ## ###   ## ##     ## 
##       ##     ## ##     ## ####  ## ##     ## 
 ######  ##     ## ##     ## ## ## ## ##     ## 
      ## ##     ## ##     ## ##  #### ##     ## 
##    ## ##     ## ##     ## ##   ### ##     ## 
 ######   #######   #######  ##    ## ########  
}


var curSound: PSoundEffect;

var curSoundSample: integer;
procedure SND_Update;
    var freq: integer;
begin
  if curSound <> nil then begin
    inc(curSoundSample, 1);

    if curSoundSample = curSound^.length - 1 then begin
      curSound := nil;
      NoSound;
    end else begin
      freq := curSound^.data^[curSoundSample];
      if freq = 0 then begin
        NoSound;
      end else begin
        Sound(freq);
      end;
    end;
  end;
end;

function SND_AllocSoundEffect(length: integer) : PSoundEffect;
  var soundEffect: PSoundEffect;
begin
  GetMem(soundEffect, sizeof(TSoundEffect));
  GetMem(soundEffect^.data, length * sizeof(integer));

  { Allocated size }
  soundEffect^.size := length;
  
  { Length of sound. Shouldn't exceed size. }
  soundEffect^.length := length;

  SND_AllocSoundEffect := soundEffect;
end;

procedure SND_FreeSoundEffect(soundEffect: PSoundEffect);
begin
  FreeMem(soundEffect^.data, soundEffect^.size);
  FreeMem(soundEffect, sizeof(TSoundEffect));
end;

procedure SND_PlaySound(snd: PSoundEffect);
begin
  if snd = nil then Exit;

  curSound := snd;
  curSoundSample := -1;
end;

function SND_IsPlaying : boolean;
begin
  SND_IsPlaying := curSound <> nil;
end;

function SND_LoadSoundEffect(filename: string) : PSoundEffect;
var f: file;
  length: integer;
  soundEffect: PSoundEffect;
begin
  SND_LoadSoundEffect := nil;
  Datafile_Open(filename, f, 1);

  BlockRead(f, length, 2);

  soundEffect := SND_AllocSoundEffect(length);
  BlockRead(f, soundEffect^.data^, length * 2);

  System.Close(f);

  SND_LoadSoundEffect := soundEffect;
end;

procedure SND_Init;
begin
end;


procedure SND_Close;
begin
end;


{

######## #### ##     ## ######## ########  
   ##     ##  ###   ### ##       ##     ## 
   ##     ##  #### #### ##       ##     ## 
   ##     ##  ## ### ## ######   ########  
   ##     ##  ##     ## ##       ##   ##   
   ##     ##  ##     ## ##       ##    ##  
   ##    #### ##     ## ######## ##     ## 

}

var
  _keyboard_did_init: boolean;
  _mouse_did_init: boolean;
  _timer_did_init: boolean;
  _neo_did_shutdown: boolean;
  
{$ifdef PLATFORM_DOS}
var
  oldTimerInt: pointer;
  oldTimerTickCount, oldTimerTicks: integer;
  tickCount: longint;
  accum: word;
  soundTicks: word;
  soundDebug: word;


procedure _DOS_Timer_Int; interrupt;
begin
  asm 
   cli
  end;
  Dec(oldTimerTickCount);
  inc(tickCount, 1);
  inc(accum, 72);

  while (accum > 99) do
  begin
    inc(tickCount, 1);
    dec(accum, 100);
  end;

  {write('.');}
  if oldTimerTickCount = 0 then
  begin

    asm
             pushf
             call    oldTimerInt
    end;
    oldTimerTickCount := oldTimerTicks;
  end
  else
  begin
    port[$20] := $20;
  end;


  Dec(soundTicks);
  if soundTicks = 0 then
  begin
    soundTicks := 4; { if 8, the tone changes every ~13 ms}
    SND_Update;
  end;
  asm
   sti
  end;
end;
{$endif}

procedure Timer_SetClockRate(bits: integer);
var
  ticks: longint;
begin
  ticks := 65536 shr bits;
  {1193182}
  oldTimerTicks := 1 shl bits;
  oldTimerTickCount := oldTimerTicks;

  soundTicks := 1;
  accum := 1;

  port[$43] := $36;
  port[$40] := lo(ticks);
  port[$40] := hi(ticks);
end;



procedure Timer_Init;
  var i, j: integer;
begin
  if not _timer_did_init then begin
    { writeln('--- Timer Init ---'); }
    getIntVec($08, oldTimerInt);
    setIntVec($08, @_DOS_Timer_Int);

    soundTicks := 1;

    Timer_SetClockRate(5);
    _timer_did_init := true;
  end;

end;

procedure _Timer_Shutdown;
begin
  if _timer_did_init then begin
    _timer_did_init := False;
    Timer_SetClockRate(0);
    setIntVec($08, oldTimerInt);
    NoSound;
  end;
end;

function Timer_GetTicks: longint;
begin
    Timer_GetTicks := tickCount;
end;

procedure Timer_Delay(ms: longint);
  var t: longint;
begin
  if not _timer_did_init then Exit;

  t := Timer_GetTicks;
  repeat until Timer_GetTicks - t >= ms;

  {  Delay(ms);}
end;

{
##        #######   #######  ########  
##       ##     ## ##     ## ##     ## 
##       ##     ## ##     ## ##     ## 
##       ##     ## ##     ## ########  
##       ##     ## ##     ## ##        
##       ##     ## ##     ## ##        
########  #######   #######  ##        
}

var
  _updateProc: UpdateProc;
  _drawProc: DrawProc;
  _done: boolean;

var
  lastTime: longint;

procedure Loop_SetUpdateProc(proc: UpdateProc);
begin
  _updateProc := proc;
end;

procedure Loop_SetDrawProc(proc: DrawProc);
begin
  _drawProc := proc;
end;

procedure Loop_Cancel;
begin
  _done := True;
end;

procedure Loop_Run;
var
  lastFrameTime, frameTime, fpsTimer: longint;
var
  fpsCount, numUpdates: integer;
var
  accum, accum_saved: real;

const
  dt: real = 1000 / 60;
const
  dt_int: integer = 16;

begin
  _done := False;
  fpsCount := 0;

  accum := 0;
  lastTime := Timer_GetTicks;
  fpsTimer := lastTime;

  lastFrameTime := lastTime;

  repeat
    SYS_PollEvents;

    Event_ProcessEvents;

    numUpdates := 0;
    frameTime := Timer_GetTicks;

    accum := accum + (frameTime - lastFrameTime);

    if accum > 2000 then accum := 2000;

    accum_saved := accum;

    while accum >= dt do
    begin
      Inc(numUpdates);
      _updateProc(dt_int);
      accum := accum - dt;
    end;

{    writeln('accum ', accum_saved:3:0, ' delta time ', (frameTime - lastFrameTime), ' num updates: ', numUpdates);
 }
    _drawProc;

    {R_SwapBuffers;}

    lastFrameTime := frameTime;

    Inc(fpsCount, 1);
    if frameTime - fpsTimer >= 1000 then
    begin
      fpsTimer := frameTime;
      {writeln('fps: ', fpsCount);}
      fpsCount := 0;
    end;

    {$ifdef fpc}
    { repeat
           Timer.Timer_Delay(1);
    until Timer.Timer_GetTicks - frameTime >= 16;
    }{Timer_Delay(8);}
    {$endif}
    prevKeys := keys;
  until _done or shouldQuit;
end;

procedure SYS_PollEvents;
begin
end;

procedure _DOS_Mouse_Int; far; assembler;
  asm 
    push ds
    push ax
    mov ax, seg @data
    mov ds, ax
    pop ax

    {mov x, cx
    }
    pop ds
  end;

function Neo_Mouse_IsAvailable: boolean;
var 
  regs: Registers;
begin
  regs.AX := 0;
  Intr($33, regs);

  Neo_Mouse_IsAvailable := regs.AX <> 0;
end;

procedure Neo_Mouse_Init;
var 
  regs: Registers;
begin
  if _mouse_did_init or not Neo_Mouse_IsAvailable then Exit;

  _mouse_did_init := True;
  
  asm
  MOV  AX,000CH
          MOV  CX,00011111B   { All actions. }
          MOV  DX,Seg _DOS_Mouse_Int
          MOV  ES,DX
          MOV  DX,Offset _DOS_Mouse_Int
          INT  33H
end;

  { TOOD: Swap, using 14h}
{  Regs.AX := $0C;
  Regs.CX := $1f;       
  Regs.ES := Seg(_DOS_Mouse_Int);
  Regs.DX := Ofs(_DOS_Mouse_Int);
  
  Intr($33, Regs);
  } 
  Regs.AX := $01;
  Intr($33, Regs);
end;

procedure _Mouse_Shutdown;
var 
  regs: Registers;
begin
  if _mouse_did_init then begin
    _mouse_did_init := False;

    { Hide cursor }
  Regs.AX := $02;
  Intr($33, Regs);

  Regs.AX := $0C;
  Regs.CX := 0;       
  Regs.DX := 0;
  Regs.ES := 0;
  
  Intr($33, Regs);
  end;
end;
var
  oldKeyInt : Pointer;
  ExitSave: Pointer;
 { keyTable: array [0..127] of boolean;
}
procedure _DOS_keyISR; interrupt;
var
 k: scanCode;
 b: byte;
 keyChar, scanCode1: byte;
 head : Word Absolute $40 : $1A;
 tail : Word Absolute $40 : $1C;
 event_index0: integer;

begin
  asm
    cli
  end;

     keyChar := 0;
     scanCode1 := 0;

     asm
     in al, $60
     mov b, al
     and al, $7F
     mov k, al
     pushF
     call [oldKeyInt]

        { Check if key available }
        mov ax, $0100
        int 16h
        jz @no_key

        mov ax, $0000
        int 16h
        mov scanCode1, ah
        mov keyChar, al       
        
@no_key:
     end;
      if (b and $80) = 0 then begin
        event_index0 := _Event_Reserve;
      end;
   asm
    sti
   end;

   
  {writeln('Keyboard: got ', ord(k), ' ', b, ' ', (b and 128) = 0,  Char(mem[$40 : head])); }
  
  if (b and $80) = 0 then begin
    Include(engine.keys, k);
    Include(engine.pressedKeys, k);

    if keyChar <> 0 then begin
      _Event_Set(event_index0, SE_KEYCHAR, 0, keyChar);
    end;
  end else begin
    Exclude(engine.keys, k);
  end;

memW[$40 : $1A] := memW[$40 : $1C];
  
end;


procedure Keybrd_Init;
var i: integer;
begin
     { writeln('--- Keyboard Init ---'); }
  if not _keyboard_did_init then begin
    _keyboard_did_init := True;
     engine.keys := [];

     getIntVec(9, oldKeyInt);
     setIntVec(9, @_DOS_keyISR);
  end;
end;

procedure _Keybrd_Shutdown;
begin
  if _keyboard_did_init then begin
    _keyboard_did_init := False;
    
    setIntVec(9, oldKeyInt);
  end;
end;


procedure Neo_Init;
begin
  _neo_did_shutdown := False;
  _keyboard_did_init := False;
  _mouse_did_init := False;
  _timer_did_init := False;
  _event_is_adding := False;

  event_head := 0;
  event_tail := 0;
end;

procedure Neo_Shutdown;
begin
  if not _neo_did_shutdown then begin

    _neo_did_shutdown := True;

    _Keybrd_Shutdown;
    _Mouse_Shutdown;

    { asm mov al, $3 ; mov ah, 0 ; int $10 end; }

    TextColor(7);
    TextBackground(0);
    
    SND_Close;
    Text.Close;

    _Timer_Shutdown;

    {$ifndef fpc}
    Console_Dump;
    {$endif}
  end;
end;

begin

end.
