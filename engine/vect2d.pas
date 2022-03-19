unit Vect2D;

interface

uses
  fixedint;

type

  Vec2D_f32 = record
    x, y: fix32;
  end;

procedure Zero(var v: Vec2D_f32);

implementation

procedure Zero(var v: Vec2D_f32);
begin
  v.x := 0;
  v.y := 0;
end;

end.
