unit Text;

interface

uses Engine, sdl2, sdl2_image, gfx, gfx_sdl, Image, Timer;

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

implementation

var
  scrbuf: pointer;
  pal: array[0..15] of array[0..2] of byte;

var
  sdlWindow1: PSDL_Window;
  sdlRenderer: PSDL_Renderer;
  screen: PSDL_Surface;
  indexedBackbuffer: PSDL_Surface;
  backBuffer: PSDL_Texture;
  currentPalette: Palette;
  fontImage: pimage_t;
  fontTexture: PSDL_Texture;

var
  text_screen_width, text_screen_height, num_chars: integer;

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
var
  srcRect: TSDL_Rect;
  dstRect: TSDL_Rect;
  texture: PSDL_Texture;
  point: TSDL_Point;

  bp: ^byte;
  fg, bg: byte;
  flash: boolean;
  flash_attr: boolean;
  x, y, row, col: integer;

begin
  bp := scrbuf;
  flash := Timer.Timer_GetTicks mod 800 < 400;

  dstRect := SDL_RectCreate(0, 0, sdlWindow1^.w, sdlWindow1^.h);

  SDL_SetRenderTarget(sdlRenderer, backBuffer);
  SDL_RenderClear(sdlRenderer);

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

      dstRect := SDL_RectCreate(x * 8, y * 16, 8, 16);
      SDL_SetRenderDrawColor(sdlRenderer, pal[bg][0], pal[bg][1], pal[bg][2], 255);
      //SDL_SetRenderDrawColor(sdlRenderer, 255, 0, 0, 255);
      SDL_RenderFillRect(sdlRenderer, @dstRect);

      if (flash_attr and (not flash)) then
      begin
        Inc(bp);
        Continue;
      end;

      fg := bp^ and $f;
      SDL_SetTextureColorMod(fontTexture, pal[fg][0], pal[fg][1], pal[fg][2]);

      srcRect := SDL_RectCreate(col * 8, row * 16, 8, 16);



      SDL_RenderCopyEx(sdlRenderer, fontTexture, @srcRect, @dstRect, 0, @point, 0);

      Inc(bp);
    end;
  end;


  SDL_SetRenderTarget(sdlRenderer, nil);

  srcRect := SDL_RectCreate(0, 0, 640, 400);
  dstRect := SDL_RectCreate(0, 0, sdlWindow1^.w, sdlWindow1^.h);
  SDL_RenderCopy(sdlRenderer, backBuffer, @srcRect, @dstRect);
  SDL_RenderPresent(sdlRenderer);

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

  for j := y to y + h do begin
    for i := x to x + w do begin
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

procedure DrawString(x, y: byte; str: string);
var
  left, right, i, j: integer;
begin
  j := 1;
  left := x;
  right := x + Length(str) - 1;

  if right > text_screen_width then right := text_screen_width;

  for i := left to right do
  begin
    WriteCharEx(i, y, Ord(str[j]), 7, $ff);
    j := j + 1;
  end;
end;

procedure Init(Width, Height: integer);
var
  window_width, window_height: integer;
var
  scale: integer;
var
  i: integer;
begin
  InitDriver;

  scale := 2;

  text_screen_width := Width;
  text_screen_height := Height;

  window_width := Width * 8;
  window_height := Height * 16;

  num_chars := Width * Height;

  writeln('Text_Init: ', Width, 'x', Height);

  GetMem(scrbuf, 2 * text_screen_width * text_screen_height);

  if SDL_Init(SDL_INIT_VIDEO) < 0 then
  begin
    writeln('SDL_Init failed');
    Halt;
  end;

  sdlWindow1 := SDL_CreateWindow('Hello World', 100, 100, window_width *
    scale, window_height * scale, 0);
  sdlRenderer := SDL_CreateRenderer(sdlWindow1, -1, SDL_RENDERER_ACCELERATED);
  if (sdlWindow1 = nil) or (sdlRenderer = nil) then Halt;

  SDL_SetHint(SDL_HINT_RENDER_VSYNC, '1');

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

  indexedBackbuffer := SDL_CreateRGBSurface(SDL_SWSURFACE, window_width,
    window_height, 8, 0, 0, 0, 0);

  //backBuffer := SDL_CreateRGBSurface();

  screen := SDL_GetWindowSurface(sdlWindow1);

  fontImage := Image_Load('dev/test.png');

  fontTexture := SDL_CreateTextureFromSurface(sdlRenderer, fontImage^.surface);

  backBuffer:= SDL_CreateTexture(sdlRenderer, SDL_PIXELFORMAT_RGB24, SDL_TEXTUREACCESS_TARGET, window_width, window_height);

  FillByte(scrbuf^, 2 * num_chars, 0);
end;

procedure Close;
begin
  FreeMem(scrbuf, 2 * text_screen_width * text_screen_height);

  SDL_DestroyRenderer(sdlRenderer);
  SDL_DestroyWindow(sdlWindow1);

  //shutting down video subsystem
  SDL_Quit;
end;

begin
end.
