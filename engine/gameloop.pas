unit gameloop;

{$F+}

interface

uses
  Sys, common,
  com_kb,
  Timer, GFX, Event;

type
  UpdateProc = procedure(deltaTime: integer);
  DrawProc = procedure;

{$I gameloop.inc}
implementation

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

    R_SwapBuffers;

    lastFrameTime := frameTime;

    Inc(fpsCount, 1);
    if frameTime - fpsTimer >= 1000 then
    begin
      fpsTimer := frameTime;
      writeln('fps: ', fpsCount);
      fpsCount := 0;
    end;

    {$ifdef fpc}
    repeat
           Timer_Delay(1);
    until Timer_GetTicks - frameTime >= 16;
    {Timer_Delay(8);}
    {$endif}
    com_kb.prevKeys := com_kb.keys;
  until _done or shouldQuit;
end;

end.
