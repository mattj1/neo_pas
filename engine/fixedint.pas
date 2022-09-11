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

function fix32Sqrt(val: fix32): fix32;

function lsqrt(n: longint): longint;

implementation

function intToFix32(Value: longint): fix32;
begin
  {intToFix32 := Value shl 10;}
  intToFix32 := Value * 1024;
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
  {fix32Mul := ((val1 shr 5) * (val2 shr 5)); }

  fix32Mul := (val1 div 32) * (val2 div 32);

  {fix32Mul := (val1 * val1) shr 10;  }
{
  writeln('fix32Mul: ', val1, ' * ',  val2);
  writeln(' shr 5: ', val1 shr 5, ' ', val2 shr 5);

  if (abs(val1) > abs(val2)) then
    fix32Mul := (val1 shr 5 * val2) shr 5
    else
    fix32Mul := (val2 shr 5 * val1) shr 5;

    writeln('result: ', fix32Mul);
}

end;

function fix32Div(val1, val2: fix32): fix32;
begin
 { val1 := val1 shl 5;
  val2 := val2 shr 5;  }

  {  val1 := val1 * 32;
  val2 := val2 div 32;
   }
  if (val2 = 0) then
  begin
    fix32Div := 0;
    exit;
  end;

  {fix32Div := (val1 * 32) div (val2 div 32);     }
  fix32Div := (val1 shl 5) div (val2 shr 5);
end;

function lsqrt(n: longint): longint;
var
  x, c, d: longint;
begin
  if n < 0 then
  begin

    lsqrt:=0;
    exit;
  end;

  x := n;
  c := 0;
  d := 1 shl 14; { 30 ? }
  while (d > n) do
  begin
    d := d shr 2;
  end;

  while (d <> 0) do
  begin
    if (x >= c + d) then
    begin  
      x := x - (c + d);       
      c := (c shr 1) + d; 
    end
    else
    begin
      c := c shr 1;
    end;
    d := d shr 2;
  end;

  lsqrt := c;
end;

function fix32Sqrt(val: fix32): fix32;
begin
  {https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Binary_numeral_system_.28base_2.29}
  if val < 0 then
  begin
    fix32Sqrt := 0;
    writeln('fix32Sqrt: Got negative value.');
    halt;

  end;
  fix32Sqrt := lsqrt(val div 1024) * 1024;
end;


begin
end.
