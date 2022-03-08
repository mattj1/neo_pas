{ Graphics - SDL }

unit GFX;

interface

uses
  SDL2,
  SDL2_Image,
  Image, GFX_SDL_Core;

{$I GFX.inc}

implementation

var
  colors: array[0..256] of TSDL_Color;
  palette: PSDL_Palette;

procedure SDL_RectCreate(var rect: TSDL_Rect; x, y, w, h: integer); inline;
begin
  rect.x := x;
  rect.y := y;
  rect.w := w;
  rect.h := h;
end;

procedure GFX_FillColor(c: byte);
begin

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
  SDL_RectCreate(srcRect, 0, 0, indexedBackbuffer^.w, indexedBackbuffer^.h);
  SDL_RectCreate(dstRect, 0, 0, sdlWindow1^.w, sdlWindow1^.h);

  //SDL_SetPaletteColors(indexedBackbuffer^.format^.palette, colors, 0, 256);


  SDL_SetSurfacePalette(indexedBackbuffer, palette);

  texture := SDL_CreateTextureFromSurface(GFX_SDL_Core.sdlRenderer, indexedBackbuffer);

  SDL_RenderClear(sdlRenderer);
  if SDL_RenderCopy(sdlRenderer, texture,@srcRect, @dstRect) <> 0 then halt;
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



procedure DrawSprite(x, y: integer; var img: image_t);
var
  srcRect: TSDL_Rect;
  dstRect: TSDL_Rect;
begin

  SDL_RectCreate(srcRect, 0, 0, img.surface^.w, img.surface^.h);
  SDL_RectCreate(dstRect, x, y, img.surface^.w, img.surface^.h);

  SDL_SetSurfacePalette(img.surface, palette);
  SDL_BlitSurface(img.surface, @srcRect, indexedBackbuffer, @dstRect);
end;

procedure SetPixel(x, y: word; c: integer);
begin

end;

procedure GFX_Init;
begin
  if SDL_Init(SDL_INIT_VIDEO) < 0 then Halt;

  sdlWindow1 := SDL_CreateWindow('Hello World', 100, 100, 640, 400, 0);

  sdlRenderer := SDL_CreateRenderer(sdlWindow1, -1, SDL_RENDERER_ACCELERATED);
  //SDL_CreateWindowAndRenderer(640, 400, SDL_WINDOW_SHOWN, @sdlWindow1, @sdlRenderer);
  SDL_SetHint(SDL_HINT_RENDER_VSYNC, '1');

  if (sdlWindow1 = nil) or (sdlRenderer = nil) then Halt;

  colors[0].r := 0;
  colors[0].g := 0;
  colors[0].b := 0;
  colors[0].a := 0;

  colors[1].r := 255;
  colors[1].g := 0;
  colors[1].b := 0;
  colors[1].a := 255;
//
  colors[2].r := 0;
  colors[2].g := 255;
  colors[2].b := 0;
  colors[2].a := 255;
//
  colors[3].r := 255;
  colors[3].g := 255;
  colors[3].b := 255;
  colors[3].a := 255;

  indexedBackbuffer := SDL_CreateRGBSurface(SDL_SWSURFACE, 320, 200, 8, 0, 0, 0, 0);

  palette := SDL_AllocPalette(256);

  SDL_SetPaletteColors(palette, @colors[0], 0, 255);
  screen := SDL_GetWindowSurface(sdlWindow1);
end;


procedure GFX_Close;
begin
  SDL_DestroyRenderer(sdlRenderer);
  SDL_DestroyWindow(sdlWindow1);

  //shutting down video subsystem
  SDL_Quit;
end;

begin
end.
