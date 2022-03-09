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
  x, lastTime: integer;

var
  pal: Palette;

  procedure Update(deltaTime: integer);
  begin
    Inc(x, 2);

    {$IfNDef fpc}
    if KeyPressed then Loop_Cancel;
    {$else}
         {  writeln('Update ', deltaTime);}
    {$endif}
  end;

  procedure Draw;
  begin
    GFX_FillColor(1);

    GFX.DrawSubImageTransparent(tileset^, 32, 32, 0, 0, 128, 128);

    {DrawSprite(0, 0, tileset^);}
    DrawSprite(x, 0, img^);

    if x > 256 then x := 0;
  end;

begin
  writeln('--- Init ---');
  GFX_Init;
  Timer_Init;

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

  {$ifdef fpc}
  Loop_SetUpdateProc(@Update);
  Loop_SetDrawProc(@Draw);
  {$else}
  Loop_SetUpdateProc(Update);
  Loop_SetDrawProc(Draw);
  {$endif}

  Loop_Run;

  Timer_Close;
  GFX_Close;

end.
