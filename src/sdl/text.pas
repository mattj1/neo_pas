unit Text;

interface

uses crt, common, sdl2;

procedure Text_Init(width, height: integer);
procedure Text_Close;

procedure DrawString(x, y: byte; str: string);
procedure FillCharAttrib(const ascii_char, attr: byte);
procedure TextBox(x, y, w, h: integer);
procedure Text_SwapBuffers;
procedure ShowCursor;
procedure HideCursor;

implementation

var
  scrbuf: pointer;

var
  sdlWindow1: PSDL_Window;
  sdlRenderer: PSDL_Renderer;
  screen: PSDL_Surface;
  indexedBackbuffer: PSDL_Surface;

var text_screen_width, text_screen_height, num_chars: integer;

procedure HideCursor;
begin

end;

procedure ShowCursor;
begin

end;

procedure FillCharAttrib(const ascii_char, attr: byte);
var nc: integer;
begin
  nc := num_chars;

end;

procedure Text_SwapBuffers;
var nc: integer;
begin
    nc := num_chars;
   SDL_RenderPresent(sdlRenderer);
end;

procedure TextWriteRaw(ch, color: byte; var o: integer);
var
  bp: byte_ptr;
begin

end;

procedure TextBox(x, y, w, h: integer);
var
  o, i, j: integer;
begin
  o := 2 * (y * text_screen_width + x);
  TextWriteRaw(201, 15, o);
  for i := x + 1 to x + w - 1 do
  begin
    TextWriteRaw(205, 15, o);
  end;
  TextWriteRaw(187, 15, o);
  for j := y + 1 to y + h - 1 do
  begin
    o := 2 * (j * text_screen_width + x);
    TextWriteRaw(186, 15, o);
    for i := x + 1 to x + w - 1 do
    begin
      TextWriteRaw(0, 15, o);
    end;
    TextWriteRaw(186, 15, o);
  end;
  o := 2 * ((y + h) * text_screen_width + x);
  TextWriteRaw(200, 15, o);
  for i := x + 1 to x + w - 1 do
  begin
    TextWriteRaw(205, 15, o);
  end;
  TextWriteRaw(188, 15, o);

end;

procedure DrawString(x, y: byte; str: string);
var
  left, right, i, j, o: integer;
begin
  j := 1;
  left := x;
  right := x + Length(str) - 1;

  if right > text_screen_width then right := text_screen_width;

  o := 2 * (y * text_screen_width + left);

  for i := left to right do
  begin
    TextWriteRaw(Ord(str[j]), 7, o);
    j := j + 1;
  end;
end;

procedure Text_Init(width, height: integer);
var mode, param: integer;
  var window_width, window_height: integer;
  var scale: integer;
begin
  scale := 1;
  text_screen_width := width;
  text_screen_height := height;

  window_width := width * 8 * scale;
  window_height := height * 16 * scale;

  num_chars := width * height;
  GetMem(scrbuf, 2 * text_screen_width * text_screen_height);

    if SDL_Init(SDL_INIT_VIDEO) < 0 then Halt;

  sdlWindow1 := SDL_CreateWindow('Hello World', 100, 100, window_width, window_height, 0);

  sdlRenderer := SDL_CreateRenderer(sdlWindow1, -1, SDL_RENDERER_ACCELERATED);
  //SDL_CreateWindowAndRenderer(640, 400, SDL_WINDOW_SHOWN, @sdlWindow1, @sdlRenderer);
  SDL_SetHint(SDL_HINT_RENDER_VSYNC, '1');

  if (sdlWindow1 = nil) or (sdlRenderer = nil) then Halt;
  
  indexedBackbuffer := SDL_CreateRGBSurface(SDL_SWSURFACE, window_width, window_height, 8, 0, 0, 0, 0);

  screen := SDL_GetWindowSurface(sdlWindow1);

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

