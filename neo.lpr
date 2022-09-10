program test;

{$ifdef fpc}
  {$IFDEF DARWIN}
    {$linkFramework SDL2}
    {$linkFramework SDL2_image}
  {$endif}

 uses
  {$I neo_sdl.inc},
  {$I game.inc};

{$else}
  {$F+}

uses
  {$I neo_dos.inc},
  {$I game.inc};
{$endif}

var
  tileset, sprites, img_font: pimage_t;
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
    for i := 1 to System.Length(str) do
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
    e: PEntity;
    es: ^entity_state_t;

  begin


    player_input := 0;
    if I_IsKeyDown(kUp) then player_input := player_input or 1;
    if I_IsKeyDown(kDn) then player_input := player_input or 2;
    if I_IsKeyDown(kLf) then player_input := player_input or 4;
    if I_IsKeyDown(kRt) then player_input := player_input or 8;

    if I_IsKeyDown(kEnter) then Loop_Cancel;

    {$ifndef fpc}
    {if I_WasKeyPressed(kRt) then SND_PlaySound(tempSound);}
    {$endif}

    for i := 0 to MAX_ENT - 1 do
    begin

      e := entities2[i];

      if e = nil then continue;
      {writeln('update ', i, ' ');
}
      es := @entity_states[Ord(e^.state)];

      Inc(e^.stateTime);

      if e^.stateTime = es^.numFrames then
      begin
        Entity_SetState(e, es^.nextState);
      end;

{
      if (es^.onFrameProc) <> nil then
      begin
        writeln('call onFrameProc ', es^.onFrameProc);
        es^.onFrameProc(e);
      end;}
      
  {writeln('--update entity', i, ' ', e^.classID);}

      entityTypes[e^.classID].updateProc(e);
    end;
  end;

  procedure Draw_Sprite_State(x, y: integer; _spriteState: spriteState;
    direction: TDirection);
  var
    si: ^sprite_info_t;
    ss: ^sprite_state_t;
  begin

    ss := @sprite_states[Ord(_spriteState)];
    si := @sprite_infos[Ord(ss^.sprites[ord(direction)])];
    R_DrawSubImageTransparent(sprites^, x - si^.offsX, y - si^.offsY,
      si^.srcX, si^.srcY, si^.Width, si^.Height);

  end;

  procedure Draw;
  var
    i: integer;
    e: PEntity;
    es: ^entity_state_t;
    ss: ^sprite_state_t;
    tx, ty, sx, sy: integer;
    tile_index: integer;

  begin
    R_FillColor(1);


    {R_DrawSubImageTransparent(tileset^, x, y, 0, 0, 256, 256);}

    for ty := 0 to map.Height - 1 do
    begin
      for tx := 0 to map.Width - 1 do
      begin

        tile_index := map.tiles^[tx + ty * map.Width].fg;
        if tile_index <> -1 then
        begin
          sx := tile_index mod 19;
          sy := tile_index div 19;
          R_DrawSubImageOpaque(tileset^, 0 + tx * 16, 0 + ty *
            16, sx * 16, sy * 16, 16, 16);
        end;
      end;
    end;
    { R_DrawSprite(x1, 0, img^); }

    {R_DrawSprite(0, 0, img_font^);}
    {font_printstr(32, 32, 'Hello World! 123456');}
    if x1 > 256 then x1 := 0;

    for i := 0 to MAX_ENT - 1 do
    begin
      e := entities2[i];
      if e <> nil then
      begin
        es := @entity_states[Ord(e^.state)];

        Draw_Sprite_State(e^.origin.x shr 10, e^.origin.y shr 10, es^.spriteState_, e^.dir);
      end;
    end;
  end;


var
  i, j: integer;
  monsterInstance: PEntityMonster;
var delta: Vec2D_f32;
  distance: fix32;

begin

  writeln('--- Init ---');
  RegisterObjectTypes;

  tileset := Image_Load('proto2.bmp');
  sprites := Image_Load('proto2s.bmp');
  img_font := Image_Load('font.bmp');
  LoadMap('./dev/m_main.bin', map);


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
  R_LoadPalette('proto2.pal', pal);
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

 { SND_PlaySound(tempSound);    }
  {$endif}

  Global.player := AllocEntity(@ObjectTypes.Player);
  Global.player^.origin.x := intToFix32(64);
  Global.player^.origin.y := intToFix32(64);
  Entity_SetState(Global.player, STATE_PLAYER_IDLE0);

  monsterInstance := PEntityMonster(AllocEntity(@ObjectTypes.Monster));
  monsterInstance^.origin.x := intToFix32(128);
  monsterInstance^.origin.y := intToFix32(128);
  Entity_SetState(monsterInstance, STATE_MONSTER_WALK0);

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
