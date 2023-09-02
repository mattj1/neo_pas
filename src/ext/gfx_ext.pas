
Unit gfx_ext;
{$H+}

Interface

Uses raylib;
Procedure InitDriver;

Var 
  mainImage: TImage;
  mainTexture: TTexture;

Implementation

Uses engine;



Procedure DrawSubImageTransparent(Var img: image_t;
                                  dstX, dstY, srcX, srcY, srcWidth, srcHeight: integer);

Var srcRect, dstRect: TRectangle;
Begin

  If dstX < 0 Then
    Begin
      inc(srcX, -dstX);
      inc(srcWidth, dstX);
      // srcWidth += dstX;
      dstX := 0;
    End;

  If dstY < 0 Then
    Begin
      inc(srcY, -dstY);
      inc(srcHeight, dstY);
      // srcY -= dstY;
      // srcHeight += dstY;
      dstY := 0;
    End;


  srcRect.x := srcX;
  // = {srcX, srcY, srcWidth, srcHeight};
  srcRect.y := srcY;
  srcRect.width := srcWidth;
  srcRect.height := srcHeight;

  dstRect.x := dstX;
  dstRect.y := dstY;
  dstRect.width := srcWidth;
  dstRect.height := srcHeight;
  //dstRect = {dstX, dstY, srcWidth, srcHeight};

  ImageDraw(@mainImage, PImage(img.data)^,
  srcRect,
  dstRect,
  WHITE);
End;

Procedure DrawLineImpl(x0, y0, x1, y1, r, g, b, a: integer);
external;
Procedure DrawTextImpl(x, y: integer; str: PChar);
external;

Procedure DrawSubImageOpaque(Var img: image_t;
                             dstX, dstY, srcX, srcY, srcWidth, srcHeight: integer);
Begin
  DrawSubImageTransparent(img, dstX, dstY, srcX, srcY, srcWidth, srcHeight);
End;

Procedure DrawSprite(x, y: integer; Var img: image_t);
Begin
  // writeln('DrawSprite...');
  DrawSubImageTransparent(img, x, y, 0, 0, img.Width, img.Height);
End;

Procedure DrawText(x, y: integer; str: String);
Begin
  ImageDrawText(@mainImage, StrToPChar(str), x, y, 12, WHITE);
End;

Procedure SwapBuffers;

Var p: TVector2;
Begin

  p.x := 0;
  p.y := 0;
  UpdateTexture(mainTexture, mainImage.data);

  DrawTextureEx(mainTexture, p, 0, 3, WHITE);
End;

Procedure DrawLine(x0, y0, x1, y1, r, g, b, a: integer);

Var c: TColor;
Begin
  c.r := r;
  c.g := g;
  c.b := b;
  c.a := a;
  // DrawLineImpl(x0, y0, x1, y1, r, g, b, a);

  // Color c = {r, g, b, a};
  ImageDrawLine(@mainImage, x0, y0, x1, y1, c);
End;

Procedure Init;
Begin
  writeln('R_Init');
  mainImage := GenImageColor(320, 240, BLANK);
  mainTexture := LoadTextureFromImage(mainImage);
End;

Procedure InitDriver;
alias: 'InitDriver';
Begin
  writeln('InitDriver');
  R_DrawSubImageTransparent := DrawSubImageTransparent;
  // R_DrawSubImageOpaque := DrawSubImageOpaque;
  R_DrawSprite := DrawSprite;
  // R_AllocPalette := AllocPalette;
  // R_LoadPalette := LoadPalette;
  // R_SetPaletteColor := SetPaletteColor;
  // R_SetPalette := SetPalette;
  R_SwapBuffers := SwapBuffers;
  R_DrawText := DrawText;
  R_DrawLine := DrawLine;
  // R_FillColor := FillColor;
  R_Init := Init;
  // R_Close := Close;
End;
End.
