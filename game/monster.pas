unit Monster;

interface

uses objtypes, rect, vect2d, fixedint, g_map, g_common;

procedure Monster_Update(Data: Pointer);

implementation

procedure Hitbox(var self: EntityMonster; var rect: rect_t);
begin
  rect.origin.x := self.origin.x - intToFix32(8);
  rect.origin.y := self.origin.y - intToFix32(8);

  rect.size.x := intToFix32(16);
  rect.size.y := intToFix32(16);
end;


procedure Monster_Update(Data: Pointer);
var
  self: PEntityMonster;
  r0: rect_t;
  moveInfo: TMoveInfo;
  vel: Vec2D_f32;

  delta: Vec2D_f32;

  distance: fix32;
  frac: fix32;

begin
  writeln('-- monster update');
  self := PEntityMonster(Data);
  Vect2D.Subtract(Global.player^.origin, self^.origin, delta);
  writeln('monster delta ', delta.x, ' ', delta.y);
  distance := Vect2D.Length(delta);

  if distance = 0 then
  begin
    exit;
  end;

  {  writeln('delta ', Global.player^.origin.x, ' - ', self^.origin.x, ' = ', delta.x, ' ', delta.y, ' distance ', distance);
}
  vel.x := fix32Div(delta.x, distance);
  vel.y := fix32Div(delta.y, distance);

  frac := fix32Div(intToFix32(2), intToFix32(3));

        {writeln('vel ', vel.x, ' ', vel.y, ' ', frac);
}
    {
    vel.x := fix32Mul(vel.x, frac);
    vel.y := fix32Mul(vel.y, frac);
    }


  Hitbox(self^, r0);
  World_Move(r0, vel, moveInfo);

  Vect2D.Add(self^.origin, moveInfo.result_delta, self^.origin);
end;



procedure Monster_Hitbox(Data: Pointer; var rect: rect_t);
var
  self: PEntityMonster;

begin
  self := PEntityMonster(Data);
  Hitbox(self^, rect);
end;

end.
