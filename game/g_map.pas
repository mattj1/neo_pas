unit g_map;

interface

uses gtypes, fixedint, g_common, Vect2D, rect;

procedure LoadMap(filename: string; var m: TLevelMap);
procedure World_Move(rect: rect_t; delta: Vec2D_f32; var move_delta: Vec2D_f32);

implementation

procedure AllocMap(Width, Height: integer; var m: TLevelMap);
begin

  m.Width := Width;
  m.Height := Height;

  GetMem(m.fg, sizeof(integer) * Width * Height);
  GetMem(m.info, sizeof(byte) * Width * Height);
end;

procedure LoadMap(filename: string; var m: TLevelMap);
var
  f: file;
begin
  AllocMap(18, 13, m);

  Assign(f, filename);
  Reset(f, 1);
  BlockRead(f, m.fg^, sizeof(integer) * m.Width * m.Height);
  Close(f);
end;

procedure RectForTile(tx, ty: integer; var r: rect_t);
begin

  r.origin.x := intToFix32(tx * 16);
  r.origin.y := intToFix32(ty * 16);
  r.size.x := intToFix32(16);
  r.size.y := intToFix32(16);
end;

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

function IsRectIntersect(r0, r1: rect_t): boolean;
begin
  if (RectRight(r0) < RectLeft(r0)) or (RectLeft(r0) > RectRight(r1)) or
    (RectBottom(r0) < RectTop(r1)) or (RectTop(r0) > RectBottom(r1)) then
  begin
    IsRectIntersect := False;
    Exit;
  end;

  IsRectIntersect := True;
end;

function CalcRectInsetX(r0, r1: rect_t): fix32;
begin
  { Calculate how much r1 is inset into r0 }
  CalcRectInsetX := 0;
end;

procedure World_Move(rect: rect_t; delta: Vec2D_f32; var move_delta: Vec2D_f32);
var
  r1, tileRect: rect_t;
var
  tx0, ty0, tx1, ty1, tx, ty, t: integer;
begin
  r1 := rect;
  Inc(r1.origin.x, delta.x);
  Inc(r1.origin.y, delta.y);

     {
       check if inset inside anything else, and push out based on the max inset
     }

  tx0 := rect.origin.x shr 14;
  ty0 := rect.origin.y shr 14;
  tx1 := tx0 + 1;
  ty1 := ty0 + 1;

  for ty := ty0 to ty1 do
  begin
    for tx := tx0 to tx1 do
    begin
      t := map.fg^[tx + ty * map.Width];
      Write(t, ' ');
      if t = 2 then
      begin
        RectForTile(tx, ty, tileRect);
        CalcRectInsetX(r1, tileRect);

        if IsRectIntersect(r1, tileRect) then begin
          Vect2D.Zero(move_delta);
          Write('hit!');
          Exit;

        end;

        { How much should this be pushed out? }

      end;
    end;
  end;

  writeln(tx, '.', ty);

  move_delta := delta;
end;

end.
