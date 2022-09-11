unit Event;

{$F+}
{$G+}

interface

uses common;

type
  eventType = (
    SE_NONE, SE_KEYDOWN, SE_KEYUP, SE_KEYCHAR
    );

type
  TEvent = record
    eventType: eventType;
    param: integer;
  end;

procedure Event_Add(eventType: eventType; param: integer);
procedure Event_ProcessEvents;

implementation

const
  MAX_EVENTS: integer = 64;

var
  events: array[0..63] of TEvent;

var
  head, tail: integer;


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
        Include(common.keys, scanCode(e.param));
        {common.keys := common.keys + [scanCode(e.param)];}
      end;
      SE_KEYUP:
      begin
        {writeln('SE_KEYUP ', e.param);}
        common.keys := common.keys - [scanCode(e.param)];
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
