unit timer;

interface

uses dos, crt;

var
  oldTimerInt: pointer;

var
  oldTimerTickCount, oldTimerTicks: integer;

var
  soundTicks: integer;

var
  time: longint;

var soundDebug: integer;

{$i timer.inc}

implementation

var accum: integer;

procedure TimerInt; interrupt;
begin
  Dec(oldTimerTickCount);
  inc(time, 1);
  inc(accum, 72);

  while (accum > 99) do
  begin
    inc(time, 1);
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
{
  Dec(soundTicks);
  if soundTicks = 0 then
  begin
    soundTicks := 8;

    inc(soundDebug, 1);
    if soundDebug = 10 then soundDebug := 0;

    if (soundDebug mod 2) = 0 then
       begin
         Sound(50 + Random(50));
       end
    else begin
      Sound(100 + soundDebug * 30);
    end;

  end;
}
end;

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

procedure Init;
begin
  writeln('--- Timer Init ---');
  getIntVec($08, oldTimerInt);
  setIntVec($08, @TimerInt);

  soundTicks := 1;

  Timer_SetClockRate(5);
end;

procedure Close;
begin
  Timer_SetClockRate(0);
  setIntVec($08, oldTimerInt);
end;

function Timer_GetTicks: longint;
begin
    Timer_GetTicks := time;
end;

procedure Timer_Delay(ms: longint);
begin
    Delay(ms);
end;

begin

end.
