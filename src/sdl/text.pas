unit Text;

interface

uses crt, common, sdl2, sdl2_image, gfx, gfx_sdl, Image;

procedure Text_Init(Width, Height: integer);
procedure Text_Close;

procedure DrawString(x, y: byte; str: string);
procedure FillCharAttrib(const ascii_char, attr: byte);
procedure TextBox(x, y, w, h: integer);
procedure SwapBuffers;
procedure ShowCursor;
procedure HideCursor;

implementation

var
  scrbuf: pointer;
  pal: array[0..15] of array[0..2] of byte;

var
  sdlWindow1: PSDL_Window;
  sdlRenderer: PSDL_Renderer;
  screen: PSDL_Surface;
  indexedBackbuffer: PSDL_Surface;
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
  fg: byte;

  x, y, row, col: integer;

begin
  bp := scrbuf;

  dstRect := SDL_RectCreate(0, 0, sdlWindow1^.w, sdlWindow1^.h);

  SDL_RenderClear(sdlRenderer);

  for y := 0 to text_screen_height - 1 do
  begin
    for x := 0 to text_screen_width - 1 do
    begin

      row := bp^ div 32;
      col := bp^ mod 32;
      Inc(bp);
      fg := bp^ and $f;
      SDL_SetTextureColorMod(fontTexture, pal[fg][0], pal[fg][1], pal[fg][2]);

      srcRect := SDL_RectCreate(col * 8, row * 16, 8, 16);
      dstRect := SDL_RectCreate(x * 8, y * 16, 8, 16);


      SDL_RenderCopyEx(sdlRenderer, fontTexture, @srcRect, @dstRect, 0, @point, 0);

      Inc(bp);
    end;
  end;

  SDL_RenderPresent(sdlRenderer);
end;

procedure TextWriteRaw(ch, color: byte; o: integer);
var
  bp, fg_p, bg_p: byte_ptr;

begin
  {{
  bp := scrbuf;
  Inc(bp, o);
  Inc(fg_p, o);
  Inc(bg_p, o);
  bp^ := ch;
  fg_p^ := color and $f;
   }}
end;

procedure WriteCharEx(x, y: integer; ch, color: byte);
var
  bp: byte_ptr;
begin
  bp := scrbuf;

  Inc(bp, 2 * (y * text_screen_width + x));
  bp^ := ch;

  Inc(bp);
  bp^ := color;
end;

procedure TextBox(x, y, w, h: integer);
var
  i, j: integer;
begin
  WriteCharEx(x, y, 201, 15);
  for i := x + 1 to x + w - 1 do
  begin
    WriteCharEx(i, y, 205, 15);
  end;
  WriteCharEx(i + 1, y, 187, 15);

  for j := y + 1 to y + h - 1 do
  begin
    WriteCharEx(x, j, 186, 15);
    for i := x + 1 to x + w - 1 do
    begin
      WriteCharEx(i, j, 0, 15);
    end;
    WriteCharEx(x + w, j, 186, 15);
  end;

  WriteCharEx(x, y + h, 200, 15);
  WriteCharEx(x + w, y + h, 188, 15);
  for i := x + 1 to x + w - 1 do
  begin
    WriteCharEx(i, y + h, 205, 15);
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
    WriteCharEx(i, y, Ord(str[j]), 7);
    j := j + 1;
  end;
end;

procedure Text_Init(Width, Height: integer);
var
  window_width, window_height: integer;
var
  scale: integer;
var
  i: integer;
begin
  InitDriver;

  scale := 1;

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
  pal[i][0] := 68;
  pal[i][1] := 170;
  pal[i][2] := 204;
  Inc(i);
  pal[i][0] := 138;
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
  pal[i][0] := 181;
  pal[i][1] := 181;
  pal[i][2] := 181;
  Inc(i);
  pal[i][0] := 127;
  pal[i][1] := 127;
  pal[i][2] := 127;
  Inc(i);

  pal[i][0] := 94;
  pal[i][1] := 96;
  pal[i][2] := 110;
  Inc(i);
  pal[i][0] := 76;
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

  screen := SDL_GetWindowSurface(sdlWindow1);

  fontImage := Image_Load('font.bmp');

  fontTexture := SDL_CreateTextureFromSurface(sdlRenderer, fontImage^.surface);

  FillByte(scrbuf^, 2 * num_chars, 0);

  i := 0;
  for i := 0 to 15 do
  begin
    TextWriteRaw(65 + i, i, i);
  end;

  DrawString(10, 10, 'Hello');
end;

procedure Text_Close;
begin
  FreeMem(scrbuf, 2 * text_screen_width * text_screen_height);

  SDL_DestroyRenderer(sdlRenderer);
  SDL_DestroyWindow(sdlWindow1);

  //shutting down video subsystem
  SDL_Quit;
end;

begin
end.
