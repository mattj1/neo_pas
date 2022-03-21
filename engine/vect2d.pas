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

procedure SetFromInt(var _out: Vec2D_f32; x, y: longint);
procedure MultFix32(v: Vec2D_f32; c: fix32; _out: Vec2D_f32);
function LengthSquared(v: Vec2D_f32) : fix32;
function LengthApprox(v: Vec2D_f32) : fix32;
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

procedure SetFromInt(var _out: Vec2D_f32; x, y: longint);
begin
  _out.x := intToFix32(x);
  _out.y := intToFix32(y);
end;

procedure MultFix32(v: Vec2D_f32; c: fix32; _out: Vec2D_f32);
begin
  _out.x := fix32Mul(v.x, c);
  _out.y := fix32Mul(v.y, c);
end;

function LengthSquared(v: Vec2D_f32) : fix32;
begin
     LengthSquared := fix32Mul(v.x, v.x) + fix32Mul(v.y, v.y);
end;

function LengthApprox(v: Vec2D_f32) : fix32;
var dx, dy: fix32;
begin
     dx := abs(v.x);
     dy := abs(v.y);
     if dx < dy then begin
       LengthApprox := dx + dy - (dx shr 1);
       Exit;
     end;

     LengthApprox := dx + dy - (dy shr 1);
end;
end.
