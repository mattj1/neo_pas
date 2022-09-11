unit Player;

interface

uses
  {$ifdef fpc}
     SysUtils,
  {$endif}
  common, g_common, g_map, fixedint, vect2d, rect, entity, res_enum, objtypes;

procedure Player_Update(Data: Pointer);

implementation

procedure Player_Hitbox(Data: Pointer; var rect: rect_t);
var
  self: PEntityPlayer;
begin
  self := PEntityPlayer(Data);

  rect.origin.x := self^.origin.x - intToFix32(7);
  rect.origin.y := self^.origin.y - intToFix32(8);

  rect.size.x := intToFix32(14);
  rect.size.y := intToFix32(8);
end;


procedure Player_Update(Data: Pointer);
var
  self: PEntityPlayer;
  vel, slideVel: Vec2D_f32;
  r0: rect_t;
  moveInfo: TMoveInfo;

begin
  self := PEntityPlayer(Data);

  vel.x := 0;
  vel.y := 0;

  if player_input and 1 <> 0 then vel.y := intToFix32(-1);
  if player_input and 2 <> 0 then vel.y := intToFix32(1);
  if player_input and 4 <> 0 then vel.x := intToFix32(-1);
  if player_input and 8 <> 0 then vel.x := intToFix32(1);

  if player_input and 15 = 0 then
  begin
    if self^.player_state <> 0 then
    begin
      Entity_SetState(self, STATE_PLAYER_IDLE0);
    end;

    self^.player_state := 0;
  end
  else
  begin
    if self^.player_state <> 1 then
    begin
      Entity_SetState(self, STATE_PLAYER_WALK0);
    end;

    self^.player_state := 1;
  end;
  if player_input and 15 <> 0 then
  begin

    if vel.x < 0 then self^.dir := DirectionLeft;
    if vel.x > 0 then self^.dir := DirectionRight;
    if vel.y < 0 then self^.dir := DirectionUp;
    if vel.y > 0 then self^.dir := DirectionDown;

    Player_Hitbox(self, r0);
    World_Move(r0, vel, moveInfo);

   {writeln(format('will move %d %d length approx: %d / desired %d',
      [moveInfo.result_delta.x, moveInfo.result_delta.y,
      Vect2D.LengthApprox(moveInfo.result_delta), Vect2D.LengthApprox(vel)])); }

    Vect2D.Add(self^.origin, moveInfo.result_delta, self^.origin);

    { Sliding should only happen if we didn't move before }

    if (moveInfo.allowedSlideDirection <> DirectionNone) and
      (Vect2D.LengthSquared(moveInfo.result_delta) < 16) then
    begin
      DirectionToVec2D(moveInfo.allowedSlideDirection, intToFix32(1), slideVel);
      { writeln('slide vel ', slideVel.x, ' ', slideVel.y);   }

      Player_Hitbox(self, r0);
      World_Move(r0, slideVel, moveInfo);
      Vect2D.Add(self^.origin, moveInfo.result_delta, self^.origin);

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
