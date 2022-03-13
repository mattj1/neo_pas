program test;

{$F+}

{$ifdef fpc}
        {$I neo_sdl.inc}
{$else}
        {$I neo_dos.inc}
{$endif}

var
  img, tileset, img_font: pimage_t;
var
  x, x1, y, lastTime: integer;

var
  pal: Palette;

  procedure font_printstr(x, y: integer; str: string);
  var i: integer;
  begin
       for i := 1 to Length(str) do begin
           R_DrawSubImageTransparent(img_font^, x, y, 8 * (ord(str[i]) - 32), 0, 8, 10);
           inc(x, 8);
       end;
  end;

  procedure Update(deltaTime: integer);
  begin
    Inc(x1, 1);

    if I_IsKeyDown(kUp) then Inc(y, -1);
    if I_IsKeyDown(kDn) then Inc(y, 1);
    if I_IsKeyDown(kLf) then Inc(x, -1);
    if I_IsKeyDown(kRt) then Inc(x, 1);

    if I_IsKeyDown(kEnter) then Loop_Cancel;
  end;

  procedure Draw;
  begin
    R_FillColor(1);

    R_DrawSubImageTransparent(tileset^, x, y, 0, 0, 128, 128);

    R_DrawSprite(x1, 0, img^);

    R_DrawSprite(0, 0, img_font^);
    font_printstr(32, 32, 'Hello World! 123456');
    if x1 > 256 then x1 := 0;
  end;

begin
  writeln('--- Init ---');

  img := Image_Load('test2.bmp');
  tileset := Image_Load('tileset.bmp');
  img_font := Image_Load('font.bmp');
  {$ifndef fpc}
          {readln;}
  {$endif}

  {$ifndef fpc}
           SYS_InitGraphicsDriver(1);
  {$else}
         SYS_InitGraphicsDriver(0);
  {$endif}



  Timer.Init;
  Keybrd.Init;

  {
  GFX_SetPaletteColor(0, 0, 0, 0);
  GFX_SetPaletteColor(1, 255, 0, 0);
  GFX_SetPaletteColor(2, 0, 255, 0);
  GFX_SetPaletteColor(3, 255, 255, 255);
   }


  y := 0;

  R_Init;
  R_AllocPalette(pal);
  R_LoadPalette('test.pal', pal);
  R_SetPalette(pal);

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

  R_Close;

end.
