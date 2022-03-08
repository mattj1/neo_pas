unit gameloop;
{$F+}

interface

uses
  {SDL2,} Timer, GFX;

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
  _done := true;
end;

procedure Loop_Run;
var
  accum, lastFrameTime, frameTime: longint;
begin
  _done := false;

  accum := 0;
  lastTime := Timer_GetTicks;
  lastFrameTime := lastTime;

  repeat
    {SDL_PumpEvents;}

    frameTime := Timer_GetTicks;

    inc(accum, frameTime - lastFrameTime);

    while accum >= 16 do
    begin
      _updateProc(16);
      dec(accum, 16);
    end;

    _drawProc;
    SwapBuffers;

    lastFrameTime := frameTime;

    repeat
      Timer_Delay(1);
    until Timer_GetTicks - frameTime >= 15;

  until _done;
end;

end.
