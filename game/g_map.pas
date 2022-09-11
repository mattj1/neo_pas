unit g_map;

interface

uses fixedint, g_common, Vect2D, rect;

procedure LoadMap(filename: string; var m: TLevelMap);
procedure World_Move(rect: rect_t; delta: Vec2D_f32; var moveInfo: TMoveInfo);

implementation

const
  SLIDE_FAC: fix32 = 256;

procedure AllocMap(Width, Height: integer; var m: TLevelMap);
var
  mapSize: integer;
begin

  m.Width := Width;
  m.Height := Height;
  mapSize := sizeOf(TMapTile) * Width * Height;
  writeln('allocate ', mapSize, ' bytes for map');
  GetMem(m.tiles, mapSize);
end;

procedure LoadMap(filename: string; var m: TLevelMap);
var
  f: file;
  i: integer;
  tile: PMapTile;
begin
  AllocMap(18, 13, m);

  Assign(f, filename);
  Reset(f, 1);

  for i := 0 to m.Width * m.Height - 1 do
  begin
    tile := @m.tiles^[i];
    tile^.x := i mod m.Width;
    tile^.y := i div m.Width;

    BlockRead(f, tile^.fg, sizeof(integer));
  end;

  for i := 0 to m.Width * m.Height - 1 do
  begin
    tile := @m.tiles^[i];
    BlockRead(f, tile^.info, sizeof(byte));
  end;

  Close(f);
end;

procedure RectForTile(var tile: TMapTile; var outRect: rect_t);
begin
  outRect.origin.x := intToFix32(tile.x * 16);
  outRect.origin.y := intToFix32(tile.y * 16);
  outRect.size.x := intToFix32(16);
  outRect.size.y := intToFix32(16);
end;

function IsRectIntersect(r0, r1: rect_t): boolean;
begin
  if (RectRight(r0) <= RectLeft(r1)) or (RectLeft(r0) >= RectRight(r1)) or
    (RectBottom(r0) <= RectTop(r1)) or (RectTop(r0) >= RectBottom(r1)) then
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

procedure AdjustCollisionRect(var rect: rect_t; other: rect_t; delta: Vec2D_f32);
var
  this_top, this_bottom, this_left, this_right, other_top, other_bottom,
  other_left, other_right: fix32;
begin

  if delta.y <> 0 then
  begin
    other_bottom := RectBottom(other);
    other_top := RectTop(other);
    this_bottom := RectBottom(rect);
    this_top := RectTop(rect);

    if (this_top < other_bottom) and (this_bottom > other_bottom) then
    begin
      rect.origin.y := other_bottom;
      Exit;
    end;

    if (this_bottom > other_top) and (this_top < other_top) then
    begin
      rect.origin.y := other_top - rect.size.y;
      Exit;
    end;
  end;

  if delta.x <> 0 then
  begin
    other_left := RectLeft(other);
    other_right := RectRight(other);
    this_left := RectLeft(rect);
    this_right := RectRight(rect);

    if (this_left < other_right) and (this_right > other_right) then
    begin
      rect.origin.x := other_right;
      Exit;
    end;

    if (this_right > other_left) and (this_left < other_left) then
    begin
      rect.origin.x := other_left - rect.size.x;
      Exit;
    end;
  end;

end;

procedure InitMoveInfo(var moveInfo: TMoveInfo);
var
  i: integer;
begin
  moveInfo.numItems := 0;
  moveInfo.allowedSlideDirection := DirectionNone;
  Vect2D.Zero(moveInfo.result_delta);
end;

procedure AddTileToMoveInfo(var moveInfo: TMoveInfo; tile: PMapTile);
begin
  moveInfo.collisionSet[moveInfo.numItems].collisionType := kCollisionTypeTile;
  moveInfo.collisionSet[moveInfo.numItems].tile := tile;
  Inc(moveInfo.numItems);
end;

function Map_TileAt(x, y: integer): PMapTile;
begin
  Map_TileAt := nil;
  if (x < 0) or (y < 0) or (x >= map.Width) or (y >= map.Height) then Exit;

  Map_TileAt := @map.tiles^[x + y * map.Width];
end;

function Map_TileNear(var tile: TMapTile; dir: TDirection): PMapTile;
begin

  Map_TileNear := nil;

  case (dir) of
    DirectionUp: Map_TileNear := Map_TileAt(tile.x, tile.y - 1);
    DirectionDown: Map_TileNear := Map_TileAt(tile.x, tile.y + 1);
    DirectionLeft: Map_TileNear := Map_TileAt(tile.x - 1, tile.y);
    DirectionRight: Map_TileNear := Map_TileAt(tile.x + 1, tile.y);
  end;
end;

procedure SlideAgainstTile(var tile: TMapTile; delta: Vec2D_f32;
  var moveInfo: TMoveInfo);
var
  tileRect: rect_t;
  tc, c: Vec2D_f32;
  fac: fix32;
  checkDirection: TDirection;
  tileNear: PMapTile;
begin
  checkDirection := DirectionNone;

  RectForTile(tile, tileRect);
  RectGetCenter(moveInfo.rect, c);
  RectGetCenter(tileRect, tc);

  if (delta.X <> 0) then
  begin
    fac := fix32Div(c.y - tc.y, tileRect.size.y);
    if fac <= -SLIDE_FAC then checkDirection := DirectionUp;
    if fac >= SLIDE_FAC then checkDirection := DirectionDown;
  end;

  if (delta.Y <> 0) then
  begin
    fac := fix32Div(c.x - tc.x, tileRect.size.x);
    if fac <= -SLIDE_FAC then checkDirection := DirectionLeft;
    if fac >= SLIDE_FAC then checkDirection := DirectionRight;
  end;

  if checkDirection <> DirectionNone then
  begin

    tileNear := Map_TileNear(tile, checkDirection);

    { Only slide if the adjacent tile is not solid }

    if (tileNear <> nil) and (tileNear^.info = 0)  then
    begin
      {writeln('clear to slide ', ord(checkDirection));}
      moveInfo.allowedSlideDirection := checkDirection;
    end;
  end;
end;

procedure World_Move1D(var moveInfo: TMoveInfo; delta: Vec2D_f32);
var
  i: integer;
  ci: ^TCollisionItem;
  otherRect: rect_t;
begin

  Vect2D.Add(moveInfo.rect.origin, delta, moveInfo.rect.origin);

  for i := 0 to moveInfo.numItems - 1 do
  begin
    ci := @moveInfo.collisionSet[i];

    case (ci^.collisionType) of
      kCollisionTypeTile:
      begin
        RectForTile(ci^.tile^, otherRect);
      end;
    end;

    if IsRectIntersect(moveInfo.rect, otherRect) then
    begin
      AdjustCollisionRect(moveInfo.rect, otherRect, delta);

      if (ci^.collisionType = kCollisionTypeTile) then
      begin
        SlideAgainstTile(ci^.tile^, delta, moveInfo);
      end;
    end;
  end;
end;



procedure World_Move(rect: rect_t; delta: Vec2D_f32; var moveInfo: TMoveInfo);
var
  bounds: rect_t;
  v: Vec2D_f32;
var
  tx0, ty0, tx1, ty1, tx, ty: integer;
  t: PMapTile;
begin
  InitMoveInfo(moveInfo);
  moveInfo.rect := rect;


  bounds := rect;
  RectInflate(bounds, abs(delta.x), abs(delta.y));

  tx0 := bounds.origin.x shr 14;
  ty0 := bounds.origin.y shr 14;
  tx1 := RectRight(bounds) shr 14;
  ty1 := RectBottom(bounds) shr 14;

  { Collect potential collisions }

  for ty := ty0 to ty1 do
  begin
    for tx := tx0 to tx1 do
    begin
      t := @map.tiles^[tx + ty * map.Width];
      if t^.info = 1 then
      begin
        AddTileToMoveInfo(moveInfo, t);
      end;
    end;
  end;

  v.x := delta.x;
  v.y := 0;
  World_Move1D(moveInfo, v);
  v.x := 0;
  v.y := delta.y;
  World_Move1D(moveInfo, v);

  Vect2D.Subtract(moveInfo.rect.origin, rect.origin, moveInfo.result_delta);
end;

begin

end.
