unit gameloop;

{$F+}

interface

uses
  {$ifdef fpc}
  SDL2,
  {$endif}
  Timer, GFX;

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
  lastFrameTime, frameTime: longint;
var
  accum: real;
const
  dt: real = 1000 / 60;
const
  dt_int: integer = 16;

begin
  _done := False;

  accum := 0;
  lastTime := Timer_GetTicks;
  lastFrameTime := lastTime;

  repeat

        {$ifdef fpc}
        SDL_PumpEvents;
        {$endif}
    frameTime := Timer_GetTicks;

    accum := accum + (frameTime - lastFrameTime);

    if accum > 2000 then accum := 2000;

    while accum >= dt do
    begin
      _updateProc(dt_int);
      accum := accum - dt;
    end;

    _drawProc;

    SwapBuffers;

    lastFrameTime := frameTime;

    {$ifdef fpc}
    {repeat

          SDL_PumpEvents;

      Timer_Delay(1);

    until Timer_GetTicks - frameTime >= 8;}
    SDL_Delay(8);
    {$endif}
    {writeln('update + draw time: ', Timer_GetTicks - frameTime);}

  until _done;
end;

end.
