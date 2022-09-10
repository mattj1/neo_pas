unit fixedint;

interface

type
  fix16 = integer;
  fix32 = longint;



function floatToFix32(Value: real): fix32;
function intToFix32(Value: longint): fix32;
function fix32Mul(val1, val2: fix32): fix32;
function fix32Div(val1, val2: fix32): fix32;
function fix32ToFix16(Value: fix32): fix16;

implementation

function intToFix32(Value: longint): fix32;
begin
  intToFix32 := Value shl 10;
end;

function floatToFix32(Value: real): fix32;
begin
  floatToFix32 := round((Value * (1 shl 10)));
end;

function fix32ToFix16(Value: fix32): fix16;
begin

  fix32ToFix16 := ((Value shl 6) shr 10);
end;

function fix32Mul(val1, val2: fix32): fix32;
begin
  fix32Mul := ((val1 shr 5) * (val2 shr 5));
end;

function fix32Div(val1, val2: fix32): fix32;
begin
  if val1 = 0 then
  begin
     fix32Div := 0;
     exit;
  end;

  fix32Div := (val1 shl 5) div (val2 shr 5);
end;
{
function VectorLength2D_f32(var v: Vec2D_f32): fix32;
begin
  VectorLength2D_f32 := Sqr(v.x * v.x + v.y * v.y);
end;
 }


begin
end.
