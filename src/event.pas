unit Event;

{$F+}
{$G+}

interface

uses engine;

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

procedure Event_Add(eventType: eventType; param, param2: integer);
procedure Event_ProcessEvents;
procedure Event_SetKeyDownProc(proc: Event_KeyDownProc);
procedure Event_SetKeyUpProc(proc: Event_KeyUpProc);
function Event_GetKeyPress(var keyPress: TKeyPress): boolean;
procedure Event_ClearKeypressQueue;

var
  _keyDownProc: Event_KeyDownProc;
  _keyUpProc: Event_KeyUpProc;
  _keyCharProc: Event_KeyCharProc;
  lastKeyChar: char;


implementation

const
  MAX_EVENTS: integer = 64;

var
  events: array[0..63] of TEvent;
  head, tail: integer;
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

procedure Event_Add(eventType: eventType; param, param2: integer);
var
  nextHead: integer;
begin

  nextHead := (head + 1) and (MAX_EVENTS - 1);

  if nextHead <> tail then
  begin
    head := nextHead;

    events[head].eventType := eventType;
    events[head].param := param;
    events[head].param2 := param2;
  end;
end;

procedure Event_ProcessEvents;
var
  e: TEvent;

begin
  {writeln('Event_ProcessEvents ', head, ' ', tail);}

  while tail <> head do
  begin
    tail := (tail + 1) and (MAX_EVENTS - 1);

    { writeln('process event tail =', tail); }
    e := events[tail];
    case e.eventType of
      SE_KEYDOWN:
      begin
        {writeln('SE_KEYDOWN ', e.param);}
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
        {writeln('SE_KEYUP ', e.param);}
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
        writeln('unhandled event ', Ord(e.eventType), ' ', e.param);
    end;

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

begin
  head := 0;
  tail := 0;

end.
