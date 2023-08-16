unit Timer;

interface

// uses
//   Classes, SysUtils, SDL2;

{$I timer.inc}
implementation

procedure Init;
begin

end;

procedure Close;
begin

end;

function Timer_GetTicks: longint;
begin
  // Timer_GetTicks := SDL_GetTicks();
end;

procedure Timer_Delay(ms: longint);
begin
  // SDL_Delay(ms);
end;

end.
