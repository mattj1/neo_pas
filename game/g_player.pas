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

procedure Player_Hitbox(e: ent_t; var rect: rect_t);
begin
  rect.origin.x := e.origin.x - intToFix32(7);
  rect.origin.y := e.origin.y - intToFix32(8);

  rect.size.x := intToFix32(14);
  rect.size.y := intToFix32(8);
end;

procedure Player_Frame(var e: ent_t);
var
  vel, slideVel: Vec2D_f32;
  r0: rect_t;
  moveInfo: TMoveInfo;

begin

  vel.x := 0;
  vel.y := 0;

  if player_input and 1 <> 0 then vel.y := intToFix32(-1);
  if player_input and 2 <> 0 then vel.y := intToFix32(1);
  if player_input and 4 <> 0 then vel.x := intToFix32(-1);
  if player_input and 8 <> 0 then vel.x := intToFix32(1);

  if player_input and 15 <> 0 then
  begin

    Player_Hitbox(e, r0);
    World_Move(r0, vel, moveInfo);

   {writeln(format('will move %d %d length approx: %d / desired %d',
      [moveInfo.result_delta.x, moveInfo.result_delta.y,
      Vect2D.LengthApprox(moveInfo.result_delta), Vect2D.LengthApprox(vel)])); }

    Vect2D.Add(e.origin, moveInfo.result_delta, e.origin);

    { Sliding should only happen if we didn't move before }

    if (moveInfo.allowedSlideDirection <> DirectionNone) and
      (Vect2D.LengthSquared(moveInfo.result_delta) < 16) then
    begin
      DirectionToVec2D(moveInfo.allowedSlideDirection, intToFix32(1), slideVel);
     { writeln('slide vel ', slideVel.x, ' ', slideVel.y);   }

      Player_Hitbox(e, r0);
      World_Move(r0, slideVel, moveInfo);
      Vect2D.Add(e.origin, moveInfo.result_delta, e.origin);

     { writeln(format('Slide result: %d %d length: %d',
        [moveInfo.result_delta.x, moveInfo.result_delta.y,
        Vect2D.Length(moveInfo.result_delta)]));    }
    end;

{    writeln(format('%d %d, %d %d', [player^.origin.x, player^.origin.y,
      player^.origin.x >> 10, player^.origin.y >> 10]));
 }
  end;

end;

end.
