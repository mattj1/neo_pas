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
  end;

  Event_KeyDownProc = procedure(sc: scanCode);
  Event_KeyUpProc = procedure(sc: scanCode);

var
  _keyDownProc: Event_KeyDownProc;
  _keyUpProc: Event_KeyUpProc;

procedure Event_Add(eventType: eventType; param: integer);
procedure Event_ProcessEvents;
procedure Event_SetKeyDownProc(proc: Event_KeyDownProc);
procedure Event_SetKeyUpProc(proc: Event_KeyUpProc);

implementation

const
  MAX_EVENTS: integer = 64;

var
  events: array[0..63] of TEvent;

var
  head, tail: integer;


procedure Event_SetKeyDownProc(proc: Event_KeyDownProc);
begin
  _keyDownProc := proc;
end;

procedure Event_SetKeyUpProc(proc: Event_KeyUpProc);
begin
  _keyUpProc := proc;
end;

procedure Event_Add(eventType: eventType; param: integer);
var
  nextHead: integer;
begin

  nextHead := (head + 1) and (MAX_EVENTS - 1);

  if nextHead <> tail then
  begin
    head := nextHead;

    events[head].eventType := eventType;
    events[head].param := param;
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

        {common.keys := common.keys + [scanCode(e.param)];}
      end;
      SE_KEYUP:
      begin
        {writeln('SE_KEYUP ', e.param);}
        engine.keys := engine.keys - [scanCode(e.param)];

        if Assigned(_keyUpProc) then _keyUpProc(scanCode(e.param));
      end;
      else
        writeln('unhandled event ', Ord(e.eventType), ' ', e.param);
    end;

  end;
end;

begin
  head := 0;
  tail := 0;

end.
