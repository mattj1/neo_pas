{ Graphics - SDL }

unit GFX_SDL;

interface

uses
  common,
  gfx,
  SDL2,
  SDL2_Image,
  Image, GFX_SDL_Core;

procedure InitDriver;
function SDL_RectCreate(x, y, w, h: integer): TSDL_Rect; inline;

implementation

var
  colors: array[0..256] of TSDL_Color;
  currentPalette: Palette;


function SDL_RectCreate(x, y, w, h: integer): TSDL_Rect; inline;
var
  rect: TSDL_Rect;
begin
  rect.x := x;
  rect.y := y;
  rect.w := w;
  rect.h := h;

  SDL_RectCreate := rect;
end;

procedure FillColor(c: byte);
var
  rect: TSDL_Rect;
begin
  rect := SDL_RectCreate(0, 0, indexedBackbuffer^.w, indexedBackbuffer^.h);
  SDL_FillRect(indexedBackbuffer, @rect, c);
end;

procedure GFX_FillRect(x, y, w, h: integer; color: byte);

begin

end;

procedure WaitForRetrace;
begin

end;

procedure WaitForRetrace2;
begin

end;

procedure SwapBuffers;
var
  texture: PSDL_Texture;
  srcRect, dstRect: TSDL_Rect;
begin
  srcRect := SDL_RectCreate(0, 0, indexedBackbuffer^.w, indexedBackbuffer^.h);
  dstRect := SDL_RectCreate(0, 0, sdlWindow1^.w, sdlWindow1^.h);

  //SDL_SetPaletteColors(indexedBackbuffer^.format^.palette, colors, 0, 256);


  SDL_SetSurfacePalette(indexedBackbuffer, currentPalette.sdlPalette);

  texture := SDL_CreateTextureFromSurface(GFX_SDL_Core.sdlRenderer, indexedBackbuffer);

  SDL_RenderClear(sdlRenderer);
  if SDL_RenderCopy(sdlRenderer, texture, @srcRect, @dstRect) <> 0 then halt;
  SDL_RenderPresent(sdlRenderer);

  SDL_DestroyTexture(texture);
end;

procedure DrawSpriteAlpha(dstX, dstY, srcX, srcY, srcWidth, srcHeight, a: integer;
  var img: Image_t);
begin

end;

procedure DrawSpriteAlpha2(dstX, dstY, srcX, srcY, srcWidth, srcHeight, a: integer;
  var img: Image_t);
begin

end;

procedure DrawSubImageTransparent(var img: image_t;
  dstX, dstY, srcX, srcY, srcWidth, srcHeight: integer);
var
  srcRect: TSDL_Rect;
  dstRect: TSDL_Rect;
begin
  srcRect := SDL_RectCreate(srcX, srcY, srcWidth, srcHeight);
  dstRect := SDL_RectCreate(dstX, dstY, srcRect.w, srcRect.h);

  {SDL_SetSurfacePalette(img.surface, currentPalette.sdlPalette);}

  SDL_SetPixelFormatPalette(img.surface^.format, currentPalette.sdlPalette);
  SDL_BlitSurface(img.surface, @srcRect, indexedBackbuffer, @dstRect);
end;

procedure DrawSubImageOpaque(var img: image_t;
  dstX, dstY, srcX, srcY, srcWidth, srcHeight: integer);
begin
  DrawSubImageTransparent(img, dstX, dstY, srcX, srcY, srcWidth, srcHeight);
end;

procedure DrawSprite(x, y: integer; var img: image_t);
begin
  DrawSubImageTransparent(img, x, y, 0, 0, img.Width, img.Height);
end;

procedure SetPixel(x, y: word; c: integer);
begin

end;


procedure AllocPalette(var pal: Palette);
begin
  pal.sdlPalette := SDL_AllocPalette(256);
end;

procedure Init;
begin
  if SDL_Init(SDL_INIT_VIDEO) < 0 then Halt;

  screen_width := 320;
  screen_height := 240;

  sdlWindow1 := SDL_CreateWindow('Hello World', 100, 100, screen_width * 2,
    screen_height * 2, 0);

  sdlRenderer := SDL_CreateRenderer(sdlWindow1, -1, SDL_RENDERER_ACCELERATED);
  //SDL_CreateWindowAndRenderer(640, 400, SDL_WINDOW_SHOWN, @sdlWindow1, @sdlRenderer);
  SDL_SetHint(SDL_HINT_RENDER_VSYNC, '1');

  if (sdlWindow1 = nil) or (sdlRenderer = nil) then Halt;

  AllocPalette(currentPalette);

  indexedBackbuffer := SDL_CreateRGBSurface(SDL_SWSURFACE, screen_width,
    screen_height, 8, 0, 0, 0, 0);

  currentPalette.sdlPalette := SDL_AllocPalette(256);

  SDL_SetPaletteColors(currentPalette.sdlPalette, @colors[0], 0, 255);
  screen := SDL_GetWindowSurface(sdlWindow1);
end;


procedure Close;
begin
  SDL_DestroyRenderer(sdlRenderer);
  SDL_DestroyWindow(sdlWindow1);

  //shutting down video subsystem
  SDL_Quit;
end;


procedure LoadPalette(filename: string; var pal: Palette);
var
  rawPal: RawPalette;
  i: integer;
  color: TSDL_Color;
begin
  GFX_LoadRawPalette(filename, rawPal);
  for i := 0 to 255 do
  begin
    color.r := rawPal.c[i][0];
    color.g := rawPal.c[i][1];
    color.b := rawPal.c[i][2];
    color.a := 255;
    SDL_SetPaletteColors(pal.sdlPalette, @color, i, 1);
  end;
end;

procedure SetPalette(var pal: Palette);
begin
  currentPalette := pal;
end;

procedure SetPaletteColor(index: integer; r, g, b: byte);
var
  color: TSDL_Color;
begin
  color.r := r;
  color.g := g;
  color.b := b;
  color.a := 255;
  SDL_SetPaletteColors(currentPalette.sdlPalette, @color, index, 1);
end;

procedure InitDriver;
begin
  R_DrawSubImageTransparent := @DrawSubImageTransparent;
  R_DrawSubImageOpaque := @DrawSubImageOpaque;
  R_DrawSprite := @DrawSprite;
  R_AllocPalette := @AllocPalette;
  R_LoadPalette := @LoadPalette;
  R_SetPaletteColor := @SetPaletteColor;
  R_SetPalette := @SetPalette;
  R_SwapBuffers := @SwapBuffers;
  R_FillColor := @FillColor;
  R_Init := @Init;
  R_Close := @Close;
end;

begin
end.
