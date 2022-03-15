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
  {$ifndef fpc}
var
  tempSound: PSoundEffect;

  {$endif}
  procedure font_printstr(x, y: integer; str: string);
  var
    i: integer;
  begin
    for i := 1 to Length(str) do
    begin
      R_DrawSubImageTransparent(img_font^, x, y, 8 * (Ord(str[i]) - 32), 0, 8, 10);
      Inc(x, 8);
    end;
  end;

{
  ===================================================================
  Update
  ===================================================================
}

  procedure Update(deltaTime: integer);
  var
    i: integer;
    e: pent_t;
    es: ^entity_state_t;

  begin
    Inc(x1, 1);

    if I_IsKeyDown(kUp) then Inc(y, -1);
    if I_IsKeyDown(kDn) then Inc(y, 1);
    if I_IsKeyDown(kLf) then Inc(x, -1);
    if I_IsKeyDown(kRt) then Inc(x, 1);

    if I_IsKeyDown(kEnter) then Loop_Cancel;

    {$ifndef fpc}
    if I_WasKeyPressed(kRt) then SND_PlaySound(tempSound);
    {$endif}

    for i := 0 to MAX_ENT - 1 do
    begin
      e := @entities[i];

      if e^.entity_type = 0 then continue;

      es := @entity_states[ord(e^.state)];
      
      inc(e^.stateTime);
      
      if e^.stateTime = es^.numFrames then begin
        Entity_SetState(e^, es^.nextState);
      end;



      if (@es^.onFrameProc) <> nil then begin
         es^.onFrameProc(e^);
      end;
    end;
  end;

  procedure Draw_Sprite_State(x, y: integer; _spriteState: spriteState;
    direction: integer);
  var
    si: ^sprite_info_t;
    ss: ^sprite_state_t;
  begin
    ss := @sprite_states[Ord(_spriteState)];
    si := @sprite_infos[Ord(ss^.sprites[direction])];
    R_DrawSubImageTransparent(tileset^, x + si^.offsX, y + si^.offsY,
      si^.srcX, si^.srcY, si^.Width, si^.Height);

  end;

  procedure Draw;
  var 
    i: integer;
    e: pent_t;
    es: ^entity_state_t;
    ss: ^sprite_state_t;
    tx, ty: integer;
  begin
    R_FillColor(1);

    R_DrawSubImageTransparent(tileset^, x, y, 80, 16, 16, 16);

    for ty := 0 to 16 do begin
      for tx := 0 to 16 do begin
        R_DrawSubImageTransparent(tileset^, x + tx * 16, y + ty * 16, 80, 16, 16, 16);
      end;
    end;
    { R_DrawSprite(x1, 0, img^); }

    R_DrawSprite(0, 0, img_font^);
    font_printstr(32, 32, 'Hello World! 123456');
    if x1 > 256 then x1 := 0;

  
    for i := 0 to MAX_ENT - 1 do
    begin
      e := @entities[i];
      if e^.entity_type <> 0 then begin
        es := @entity_states[ord(e^.state)];

        Draw_Sprite_State(64, 64, es^.spriteState_, 0);
      end;
    end;

  end;


var
  i, j: integer;
  e: pent_t;
begin
  writeln('--- Init ---');

  img := Image_Load('test2.bmp');
  tileset := Image_Load('test3.bmp');
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
  R_LoadPalette('cica26.pal', pal);
  R_SetPalette(pal);

  {$ifndef fpc}
  tempSound := SND_AllocSoundEffect(256);
  tempSound^.length := 30;

{  for i := 0 to 15 do begin
    tempSound^[i] := 2000 - i * 200;
  end;
 }

  i := 0;
  for j := 0 to 15 do
  begin
    tempSound^.Data^[i] := 40 + Random(100);
    Inc(i, 1);
    tempSound^.Data^[i] := tempSound^.Data^[i - 1];
    Inc(i, 1);
  end;

  SND_PlaySound(tempSound);
  {$endif}

  e := Entity_Alloc(1);
  Entity_SetState(e^, STATE_PLAYER0);

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
