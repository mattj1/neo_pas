unit g_map;

interface

uses gtypes;

procedure LoadMap(filename: string; var m: TLevelMap);

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
  AllocMap(32, 32, m);

  Assign(f, filename);
  Reset(f, 1);
  BlockRead(f, m.fg^, sizeof(integer) * m.Width * m.Height);
  Close(f);
end;

end.
