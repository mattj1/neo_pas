unit GFX_SDL;

interface

{$mode fpc}
uses
  Engine,
  gfx,
  SDL2,
  SDL2_Image, sdl2_ttf,
  Image, GFX_SDL_Core;

procedure InitDriver;
function SDL_RectCreate(x, y, w, h: integer): TSDL_Rect; inline;

implementation

var
  colors: array[0..256] of TSDL_Color;
  currentPalette: Palette;
  backBuffer: PSDL_Texture;
  fnt: PTTF_Font;


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
  scaleFac: integer;
begin
  srcRect := SDL_RectCreate(0, 0, indexedBackbuffer^.w, indexedBackbuffer^.h);
  dstRect := SDL_RectCreate(0, 0, sdlWindow1^.w, sdlWindow1^.h);

  scaleFac := 0;

  //SDL_SetPaletteColors(indexedBackbuffer^.format^.palette, colors, 0, 256);

{
  SDL_SetSurfacePalette(indexedBackbuffer, currentPalette.sdlPalette);

  texture := SDL_CreateTextureFromSurface(GFX_SDL_Core.sdlRenderer, indexedBackbuffer);

  SDL_RenderClear(sdlRenderer);
  if SDL_RenderCopy(sdlRenderer, texture, @srcRect, @dstRect) <> 0 then halt;
  SDL_RenderPresent(sdlRenderer);


  SDL_DestroyTexture(texture);}

  { Render backbuffer }

  SDL_SetRenderTarget(sdlRenderer, nil);

 { srcRect := SDL_RectCreate(0, 0, 640, 400);
  dstRect := SDL_RectCreate(sdlWindow1^.w div 2 - (640 * scaleFac div 2),
    sdlWindow1^.h div 2 - (400 * scaleFac div 2), 640 * scaleFac, 400 * scaleFac);}
  SDL_RenderCopy(sdlRenderer, backBuffer, @srcRect, @dstRect);

  SDL_RenderPresent(sdlRenderer);

  { Ready for next frame }

  SDL_SetRenderTarget(sdlRenderer, backBuffer);
  SDL_RenderClear(sdlRenderer);
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
  point: TSDL_Point;
begin
  srcRect := SDL_RectCreate(srcX, srcY, srcWidth, srcHeight);
  dstRect := SDL_RectCreate(dstX, dstY, srcRect.w, srcRect.h);
  point.x := 0;
  point.y := 0;
  {SDL_SetSurfacePalette(img.surface, currentPalette.sdlPalette);}

  {
  SDL_SetPixelFormatPalette(img.surface^.format, currentPalette.sdlPalette);
  SDL_BlitSurface(img.surface, @srcRect, indexedBackbuffer, @dstRect);}


  if not Assigned(img.texture) then
  begin
    img.texture := SDL_CreateTextureFromSurface(sdlRenderer, img.surface);
  end;

  //SDL_SetTextureAlphaMod(img.texture, 127);
  //SDL_SetTextureColorMod(img.texture, 127, 0, 0);
  SDL_RenderCopyEx(sdlRenderer, img.texture, @srcRect, @dstRect, 0, @point, 0);

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

procedure Init;
var
  i: integer;
begin
  if SDL_Init(SDL_INIT_VIDEO) < 0 then Halt;

  screen_width := 320;
  screen_height := 240;

  sdlWindow1 := SDL_CreateWindow('Hello World', 100, 100, screen_width * 3,
    screen_height * 3, 0);

    SDL_SetHint(SDL_HINT_RENDER_VSYNC, '1');

  sdlRenderer := SDL_CreateRenderer(sdlWindow1, -1, SDL_RENDERER_ACCELERATED);
  //SDL_CreateWindowAndRenderer(640, 400, SDL_WINDOW_SHOWN, @sdlWindow1, @sdlRenderer);


  if (sdlWindow1 = nil) or (sdlRenderer = nil) then Halt;

  AllocPalette(currentPalette);

  indexedBackbuffer := SDL_CreateRGBSurface(SDL_SWSURFACE, screen_width,
    screen_height, 8, 0, 0, 0, 0);

  currentPalette.sdlPalette := SDL_AllocPalette(256);

  SDL_SetPaletteColors(currentPalette.sdlPalette, @colors[0], 0, 255);

  SetPaletteColor(0, 0, 0, 255);

  for i := 1 to 254 do
  begin
    colors[i].a := 255;
    colors[i].r := 255;
  end;

  SetPaletteColor(15, 255, 255, 255);

  backBuffer := SDL_CreateTexture(sdlRenderer, SDL_PIXELFORMAT_RGB24,
    SDL_TEXTUREACCESS_TARGET, screen_width, screen_height);

  SDL_SetRenderTarget(sdlRenderer, backBuffer);
  SDL_RenderClear(sdlRenderer);

  screen := SDL_GetWindowSurface(sdlWindow1);


  //fnt := TTF_OpenFont('MesloLGS-Regular-Powerline.ttf', 12);
  fnt := TTF_OpenFont('slkscr.ttf', 9);
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

procedure DrawText(x, y: integer; str: AnsiString);
var
  textColor: TSDL_Color;
  fontSurface: PSDL_Surface;
  fontTexture: PSDL_Texture;
  fontRect: TSDL_Rect;

begin

  textColor.r := 255;
  textColor.g := 255;
  textColor.b := 255;
  textColor.a := 255;
  fontSurface := TTF_RenderText_Solid(fnt, PChar(str), textColor);
  fontTexture := SDL_CreateTextureFromSurface(sdlRenderer, fontSurface);
  fontRect := SDL_RectCreate(x, y, fontSurface^.w, fontSurface^.h);
  SDL_RenderCopy(sdlRenderer, fontTexture, nil, @fontRect);

  //SDL_SetRenderDrawColor(sdlRenderer, 255, 0, 0, 255);
  //SDL_RenderDrawPoint(sdlRenderer, x, y + 24);
  //SDL_RenderDrawLine(sdlRenderer, x, y, x, y - 10);

  SDL_DestroyTexture(fontTexture);
  SDL_FreeSurface(fontSurface);


end;

procedure DrawLine(x0, y0, x1, y1, r, g, b, a: integer);
begin
  SDL_SetRenderDrawColor(sdlRenderer, r, g, b, a);
  SDL_RenderDrawLine(sdlRenderer, x0, y0, x1, y1);
  SDL_SetRenderDrawColor(sdlRenderer, 0, 0, 0 ,0);
end;

procedure InitDriver;
begin
  R_DrawSubImageTransparent := R_DrawSubImageTransparentProc(@DrawSubImageTransparent);
  R_DrawSubImageOpaque := R_DrawSubImageOpaqueProc(@DrawSubImageOpaque);
  R_DrawSprite := R_DrawSpriteProc(@DrawSprite);
  R_AllocPalette := @AllocPalette;
  R_LoadPalette := R_LoadPaletteProc(@LoadPalette);
  R_SetPaletteColor := R_SetPaletteColorProc(@SetPaletteColor);
  R_SetPalette := @SetPalette;
  R_SwapBuffers := @SwapBuffers;
  R_FillColor := @FillColor;
  R_DrawText := R_DrawTextProc(@DrawText);
  R_DrawLine := R_DrawLineProc(@DrawLine);
  R_Init := @Init;
  R_Close := @Close;
end;

begin
end.
