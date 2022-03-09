{ GFX API }

procedure GFX_FillColor(c: byte);
procedure GFX_FillRect(x, y, w, h: integer; color: byte);
procedure WaitForRetrace;
procedure WaitForRetrace2;
procedure SwapBuffers;
procedure DrawSpriteAlpha(
          dstX, dstY, srcX, srcY, srcWidth, srcHeight, a: integer;
          var img: Image_t);
procedure DrawSpriteAlpha2(
          dstX, dstY, srcX, srcY, srcWidth, srcHeight, a: integer;
          var img: Image_t);
procedure DrawSprite(x, y: integer; var img: Image_t);

procedure SetPixel(x, y: word; c: integer);

{ Palette }
procedure GFX_AllocPalette(var pal: Palette);
procedure GFX_LoadPalette(filename: string; var pal: Palette);
procedure GFX_SetPalette(var pal: Palette);
procedure GFX_SetPaletteColor(index: integer; r, g, b: byte);

procedure GFX_Init;
procedure GFX_Close;

procedure DrawSubImageTransparent(var img: image_t; dstX, dstY, srcX, srcY, srcWidth, srcHeight: integer);
procedure DrawSubImageOpaque(var img: image_t; dstX, dstY, srcX, srcY, srcWidth, srcHeight: integer);
