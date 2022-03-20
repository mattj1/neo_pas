unit rect;


interface

uses vect2D, fixedint;

type
  rect_t = record
    origin: Vec2D_f32;
    size: Vec2D_f32;
  end;

function RectTop(var r: rect_t): fix32;
function RectBottom(var r: rect_t): fix32;
function RectLeft(var r: rect_t): fix32;
function RectRight(var r: rect_t): fix32;
procedure RectInflate(var rect: rect_t; x, y: fix32);
procedure RectUnion(r0, r1: rect_t; var outRect: rect_t);

implementation

function RectTop(var r: rect_t): fix32;
begin
  RectTop := r.origin.y;
end;

function RectBottom(var r: rect_t): fix32;
begin
  RectBottom := r.origin.y + r.size.y;
end;

function RectLeft(var r: rect_t): fix32;
begin
  RectLeft := r.origin.x;
end;

function RectRight(var r: rect_t): fix32;
begin
  RectRight := r.origin.x + r.size.x;
end;

function min(a, b: longint): longint;
begin
  if (a < b) then
    min := a
  else
    min := b;
end;


function max(a, b: longint): longint;
begin
  if (a > b) then
    max := a
  else
    max := b;
end;

procedure RectUnion(r0, r1: rect_t; var outRect: rect_t);
var
  right, bottom: fix32;
begin
  outRect.origin.x := min(RectLeft(r0), RectLeft(r1));
  outRect.origin.y := min(RectTop(r0), RectTop(r1));

  right := max(RectRight(r0), RectRight(r1));
  bottom := max(RectBottom(r0), RectBottom(r1));

  outRect.size.x := right - outRect.origin.x;
  outRect.size.y := bottom - outRect.origin.y;
end;


procedure RectInflate(var rect: rect_t; x, y: fix32);
begin
  Inc(rect.origin.x, -x);
  Inc(rect.origin.y, -y);
  Inc(rect.size.x, 2 * x);
  Inc(rect.size.y, 2 * y);
end;


end.
