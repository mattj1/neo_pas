unit Vect2D;

interface

uses
  fixedint;

type

  Vec2D_f32 = record
    x, y: fix32;
  end;

procedure Add(a, b: Vec2D_f32; var _out: Vec2D_f32);
procedure Subtract(a, b: Vec2D_f32; var _out: Vec2D_f32);
procedure Zero(var v: Vec2D_f32);

implementation

procedure Add(a, b: Vec2D_f32; var _out: Vec2D_f32);
begin
  _out.x := a.x + b.x;
  _out.y := a.y + b.y;
end;

procedure Subtract(a, b: Vec2D_f32; var _out: Vec2D_f32);
begin
  _out.x := a.x - b.x;
  _out.y := a.y - b.y;
end;

procedure Zero(var v: Vec2D_f32);
begin
  v.x := 0;
  v.y := 0;
end;

end.
