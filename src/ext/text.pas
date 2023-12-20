unit Text;

interface

uses Engine, gfx, Image, gfx_ext, raylib;

procedure Init(Width, Height: integer);
procedure Close;

procedure DrawString(x, y: byte; str: string);
procedure FillCharAttrib(const ascii_char, attr: byte);
procedure TextBox(x, y, w, h: integer);
procedure SwapBuffers;
procedure ShowCursor;
procedure HideCursor;

procedure WriteCharEx(x, y: integer; ch, color, mask: byte);

procedure Text_FillRectEx(x, y, w, h: integer; ch, color, mask: byte);
procedure Text_DrawStringEx(x, y: byte; str: string; color, mask: byte);
function Text_BufferPtr(x, y: integer): byte_ptr;

procedure Text_ToggleFullscreen;

procedure Text_DrawColorStringEx(x, y: byte; str: string; color, mask: byte);

implementation

uses Math;

var
  scrbuf: pointer;
  pal: array[0..15] of array[0..2] of byte;
  fontImage: pimage_t;
  text_screen_width, text_screen_height, num_chars: integer;
  isFullScreen: boolean;

procedure HideCursor;
begin

end;

procedure ShowCursor;
begin

end;

procedure FillCharAttrib(const ascii_char, attr: byte);
var
  nc: integer;
begin
  nc := num_chars;

end;

procedure SwapBuffers;
var p: TVector2;
      srcRect, dstRect: TRectangle;

  bp: ^byte;
  fg, bg: byte;
  flash: boolean;
  flash_attr: boolean;
  x, y, row, col: integer;
  scaleFac: integer;
  tint: TColor;
begin
  p.x := 0;
  p.y := 0;

  bp := scrbuf;
  flash := True; // Timer_GetTicks mod 800 < 400;

  for y := 0 to text_screen_height - 1 do
  begin
    for x := 0 to text_screen_width - 1 do
    begin

      row := bp^ div 16;
      col := bp^ mod 16;
      Inc(bp);
      fg := bp^ and $f;
      flash_attr := (bp^ and $80) <> 0;

      bg := (bp^ shr 4) and $f;

      // If flashing text is enabled:
      bg := bg and $7;

      // dstRect := SDL_RectCreate(x * 8, y * 16, 8, 16);
      dstRect.x := x * 8;
      dstRect.y := y * 16;
      dstRect.width := 8;
      dstRect.height := 16;


      // SDL_SetRenderDrawColor(sdlRenderer, pal[bg][0], pal[bg][1], pal[bg][2], 255);
      // SDL_RenderFillRect(sdlRenderer, @dstRect);

      tint.r := pal[bg][0];
      tint.g := pal[bg][1];
      tint.b := pal[bg][2];
      tint.a := 255;

      ImageDrawRectangleRec(@mainImage, dstRect, tint);

      // if (flash_attr and (not flash)) then
      // begin
      //   Inc(bp);
      //   Continue;
      // end;

      fg := bp^ and $f;
      // SDL_SetTextureColorMod(fontTexture, pal[fg][0], pal[fg][1], pal[fg][2]);

      srcRect.x := col * 8; // = {srcX, srcY, srcWidth, srcHeight};
      srcRect.y := row * 16;
      srcRect.width := 8;
      srcRect.height := 16;

      // srcRect := SDL_RectCreate(col * 8, row * 16, 8, 16);
      // SDL_RenderCopyEx(sdlRenderer, fontTexture, @srcRect, @dstRect, 0, @point, 0);

      tint.r := pal[fg][0];
      tint.g := pal[fg][1];
      tint.b := pal[fg][2];
      tint.a := 255;
      
     ImageDraw(@mainImage, PImage(fontImage^.data)^,
         srcRect,
         dstRect,
         tint);

     Inc(bp);
    end;
  end;



  //dstRect = {dstX, dstY, srcWidth, srcHeight};
        BeginDrawing;
             ClearBackground(RAYWHITE);
             DrawText('Congrats! You created your first window!', 190, 200, 20, LIGHTGRAY);
            UpdateTexture(mainTexture, mainImage.data);
          DrawTextureEx(mainTexture, p, 0, 2, WHITE);
        EndDrawing;
end;

procedure TextWriteRaw(ch, color: byte; o: integer);
var
  bp, fg_p, bg_p: byte_ptr;

begin
  {
  bp := scrbuf;
  Inc(bp, o);
  Inc(fg_p, o);
  Inc(bg_p, o);
  bp^ := ch;
  fg_p^ := color and $f;
  }
end;

function Text_BufferPtr(x, y: integer): byte_ptr;
var
  bp: byte_ptr;

begin
  bp := scrbuf;
  Inc(bp, 2 * (y * text_screen_width + x));
  Text_BufferPtr := bp;
end;

procedure WriteCharEx(x, y: integer; ch, color, mask: byte);
var
  bp: byte_ptr;
begin
  bp := scrbuf;

  Inc(bp, 2 * (y * text_screen_width + x));
  bp^ := ch;

  Inc(bp);

  bp^ := (bp^ and (not mask)) or (color and mask);
end;

procedure Text_FillRectEx(x, y, w, h: integer; ch, color, mask: byte);
var
  bp: byte_ptr;
  i, j: integer;
begin

  for j := y to y + h do
  begin
    for i := x to x + w do
    begin
      WriteCharEx(i, j, ch, color, mask);

    end;
  end;
end;


procedure TextBox(x, y, w, h: integer);
var
  row: integer;
  right: integer;
  i, j: integer;
begin
  row := y;
  right := x + w - 1;

  WriteCharEx(x, y, 201, 15, $ff);
  for i := x + 1 to x + w - 1 do
  begin
    WriteCharEx(i, y, 205, 15, $ff);
  end;

  WriteCharEx(i, y, 187, 15, $ff);

  for row := y + 1 to y + h - 1 do
  begin
    WriteCharEx(x, row, 186, 15, $ff);
    for i := x + 1 to x + w - 1 do
    begin
      WriteCharEx(i, row, 0, 15, $ff);
    end;
    WriteCharEx(x + w - 1, row, 186, 15, $ff);
  end;

  WriteCharEx(x, row, 200, 15, $ff);
  WriteCharEx(right, row, 188, 15, $ff);

  for i := x + 1 to right - 1 do
  begin
    WriteCharEx(i, row, 205, 15, $ff);
  end;
end;

procedure Text_DrawStringEx(x, y: byte; str: string; color, mask: byte);
var
  left, right, i, j: integer;
begin
  j := 1;
  left := x;
  right := x + Length(str) - 1;

  if right > text_screen_width then right := text_screen_width;

  for i := left to right do
  begin
    WriteCharEx(i, y, Ord(str[j]), color, mask);
    j := j + 1;
  end;
end;

procedure Text_DrawColorStringEx(x, y: byte; str: string; color, mask: byte);
var
  left, right, i, j, l: integer;
  src, dst: byte_ptr;
begin
  src := @str;
  inc(src);

  dst := scrbuf;
  Inc(dst, 2 * (y * text_screen_width + x));

  i := 0;
  l := Length(str);
  while (x < text_screen_width) and (i < l) do
  begin
    if ord(src^) = 94 then begin
       inc(src);
       inc(i);
       if (ord(src^) >= 48) and (ord(src^) <= 57) then begin
          color := ord(src^) - 48;
          inc(src);
          inc(i);
          continue;
       end;

       if (ord(src^) >= 65) and (ord(src^) <= 70) then begin
          color := ord(src^) - 55;
          inc(src);
          inc(i);
          continue;
       end;
    end;

    dst^ := src^;
    inc(dst);
    inc(src);

    dst^ := (dst^ and (not mask)) or (color and mask);

    Inc(dst);
    Inc(i);
    Inc(x);
  end;
end;

procedure DrawString(x, y: byte; str: string);
begin
  Text_DrawStringEx(x, y, str, 7, $ff);
end;

procedure Text_SetFullscreen(fs: boolean);
begin

end;

procedure Text_ToggleFullscreen;
begin
  Text_SetFullscreen(not isFullScreen);
end;

procedure Init(Width, Height: integer);
var
  window_width, window_height: integer;
var
  scale: integer;
var
  i: integer;
  // rect: TSDL_Rect;
begin
  // InitDriver;

  scale := 2;

  text_screen_width := Width;
  text_screen_height := Height;

  window_width := Width * 8;
  window_height := Height * 16;

  num_chars := Width * Height;

  writeln('Text_Init: ', Width, 'x', Height);

  GetMem(scrbuf, 2 * text_screen_width * text_screen_height);
  FillChar(scrbuf^, 2 * text_screen_width * text_screen_height, 0);

  {$ifdef PLATFORM_DESKTOP}
  InitWindow(80 * 8 * 2, 25 * 16 * 2, 'raylib [core] example - basic window');

  //SetTraceLogLevel(LOG_WARNING);
  SetTargetFPS(60);
  {$endif}
  mainImage := GenImageColor(window_width, window_height, BLANK);
  mainTexture := LoadTextureFromImage(mainImage);
  SetTextureFilter(mainTexture, TEXTURE_FILTER_POINT);

  fontImage := Image_Load('dev/test.png');
  ImageColorReplace(PImage(fontImage^.data), BLACK, BLANK);

  i := 0;
  pal[i][0] := 0;
  pal[i][1] := 0;
  pal[i][2] := 0;
  Inc(i);
  pal[i][0] := 34;
  pal[i][1] := 52;
  pal[i][2] := 209;
  Inc(i);
  pal[i][0] := 12;
  pal[i][1] := 126;
  pal[i][2] := 69;
  Inc(i);
  pal[i][0] := 68;      // 3 cyan
  pal[i][1] := 170;
  pal[i][2] := 204;
  Inc(i);
  pal[i][0] := 138;      // 4 red
  pal[i][1] := 54;
  pal[i][2] := 34;
  Inc(i);
  pal[i][0] := 92;
  pal[i][1] := 46;
  pal[i][2] := 120;
  Inc(i);
  pal[i][0] := 170;
  pal[i][1] := 92;
  pal[i][2] := 61;
  Inc(i);
  pal[i][0] := 181;      // 7 white
  pal[i][1] := 181;
  pal[i][2] := 181;
  Inc(i);
  pal[i][0] := 94;
  pal[i][1] := 96;
  pal[i][2] := 110;
  Inc(i);
  pal[i][0] := 76;       // 9 light blue
  pal[i][1] := 129;
  pal[i][2] := 251;
  Inc(i);
  pal[i][0] := 108;
  pal[i][1] := 217;
  pal[i][2] := 71;
  Inc(i);
  pal[i][0] := 123;
  pal[i][1] := 226;
  pal[i][2] := 249;
  Inc(i);
  pal[i][0] := 235;
  pal[i][1] := 138;
  pal[i][2] := 96;
  Inc(i);
  pal[i][0] := 226;
  pal[i][1] := 61;
  pal[i][2] := 105;
  Inc(i);
  pal[i][0] := 255;
  pal[i][1] := 217;
  pal[i][2] := 63;
  Inc(i);
  pal[i][0] := 255;
  pal[i][1] := 255;
  pal[i][2] := 255;
  Inc(i);

end;

procedure Close;
begin
  CloseWindow;
end;

begin
end.
