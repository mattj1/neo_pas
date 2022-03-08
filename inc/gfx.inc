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

procedure GFX_Init;
procedure GFX_Close;
