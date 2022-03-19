unit g_map;

interface

uses gtypes, fixedint, g_common;

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

procedure World_Move(rect: rect_t; delta: Vec2D_f32; var move_delta: Vec2D_f32);
var
  r1: rect_t;
var
  tx0, ty0, tx1, ty1, tx, ty, t: integer;
begin
  r1 := rect;
  Inc(r1.origin.x, delta.x);
     {
       check if inset inside anything else, and push out based on the max inset
     }

  tx0 := (rect.origin.x >> 14);
  ty0 := rect.origin.y >> 14;
  tx1 := tx0 + 1;
  ty1 := ty0 + 1;

  for ty := ty0 to ty1 do begin
    for tx := tx0 to tx1 do begin
       t := map.fg^[tx + ty * map.width];
       write(t, ' ');
       if t = 2 then begin
         write('hit!');
         { How much should this be pushed out? )

       end;
    end;
  end;

  writeln(tx, ' ', ty);


  Inc(r1.origin.y, delta.y);

  move_delta := delta;
end;

end.
