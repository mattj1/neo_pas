program test;

{$F+}

{$ifdef fpc}
        {$I neo_sdl.inc}
{$else}
        {$I neo_dos.inc}
{$endif}

var
  img, tileset: pimage_t;
var
  x, x1, y, lastTime: integer;

var
  pal: Palette;

  procedure Update(deltaTime: integer);
  begin
    Inc(x1, 1);

    if I_IsKeyDown(kUp) then inc(y, -1);
    if I_IsKeyDown(kDn) then inc(y, 1);
    if I_IsKeyDown(kLf) then inc(x, -1);
    if I_IsKeyDown(kRt) then inc(x, 1);

    if I_IsKeyDown(kEnter) then Loop_Cancel;
  end;

  procedure Draw;
  begin
    GFX_FillColor(1);

    GFX.DrawSubImageTransparent(tileset^, x, y, 0, 0, 128, 128);

    {DrawSprite(0, 0, tileset^);}
    DrawSprite(x1, 0, img^);

    if x1 > 256 then x1 := 0;
  end;

begin
  writeln('--- Init ---');
  GFX_Init;
  Timer.Init;
  Keybrd.Init;

  GFX_AllocPalette(pal);
  GFX_LoadPalette('test.pal', pal);
  GFX_SetPalette(pal);
  {
  GFX_SetPaletteColor(0, 0, 0, 0);
  GFX_SetPaletteColor(1, 255, 0, 0);
  GFX_SetPaletteColor(2, 0, 255, 0);
  GFX_SetPaletteColor(3, 255, 255, 255);
   }
  img := Image_Load('test2.bmp');
  tileset := Image_Load('tileset.bmp');

  y := 0;
  {$ifdef fpc}
  Loop_SetUpdateProc(@Update);
  Loop_SetDrawProc(@Draw);
  {$else}
  Loop_SetUpdateProc(Update);
  Loop_SetDrawProc(Draw);
  {$endif}

  Loop_Run;

  Keybrd.Close;
  Timer.Close;
  GFX_Close;

end.
