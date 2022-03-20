unit g_player;

interface

uses
  {$ifdef fpc}
     SysUtils,
  {$endif}
  gtypes, g_common, g_map, fixedint, vect2d, rect;

procedure Player_Move(var e: ent_t);
procedure Player_Frame(var e: ent_t);

implementation

procedure Player_Move(var e: ent_t);
begin

end;

procedure Player_Frame(var e: ent_t);
var
  vel, Result: Vec2D_f32;

var
  r0: rect_t;

begin

  vel.x := 0;
  vel.y := 0;

  if player_input and 1 <> 0 then vel.y := intToFix32(-1);
  if player_input and 2 <> 0 then vel.y := intToFix32(1);
  if player_input and 4 <> 0 then vel.x := intToFix32(-1);
  if player_input and 8 <> 0 then vel.x := intToFix32(1);

  r0.origin := e.origin;
  r0.size.x := intToFix32(16);
  r0.size.y := intToFix32(16);

  if player_input and 15 <> 0 then
  begin
    World_Move(r0, vel, Result);

  {  writeln(format('will move %d %d', [Result.x, Result.y]));}
    Inc(e.origin.x, Result.x);
    Inc(e.origin.y, Result.y);

{    writeln(format('%d %d, %d %d', [player^.origin.x, player^.origin.y,
      player^.origin.x >> 10, player^.origin.y >> 10]));
 }
  end;

end;

end.
