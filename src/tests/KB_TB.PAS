uses crt, common, keybrd, timer, event, gameloop;
{$F+}
var t, player_input: integer;

  procedure Update(deltaTime: integer);
  begin
    if time > 3000 then Loop_Cancel;
    
    player_input := 0;
    
    if I_IsKeyDown(kUp) then player_input := player_input or 1;
    if I_IsKeyDown(kDn) then player_input := player_input or 2;
    if I_IsKeyDown(kLf) then player_input := player_input or 4;
    if I_IsKeyDown(kRt) then player_input := player_input or 8;

    if player_input <> 0 then writeln('player input ', player_input);
    if I_IsKeyDown(kA) then writeln('A pressed');


    if I_WasKeyPressed(kA) then writeln('A was pressed');
  end;

  procedure Draw;
  begin
  end;


begin
 clrscr;
 Timer.Init;
 Keybrd.Init;
{
 repeat
    Event_ProcessEvents;
    Timer.Timer_Delay(100);
 until time > 3000;
 }
    Loop_SetUpdateProc(Update);
  Loop_SetDrawProc(Draw);

  Loop_Run;

 Keybrd.Close;
 Timer.Close;
end.
