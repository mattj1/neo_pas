unit g_player;

interface

uses gtypes, g_common, g_map, fixedint, vect2d, rect;

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

    Inc(e.origin.x, Result.x);
    Inc(e.origin.y, Result.y);
  end;



  {writeln(player^.origin.x, ' ', player^.origin.y);}
end;

end.
