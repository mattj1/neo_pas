unit gfx_ext;
{$H+}
interface
uses raylib;
procedure InitDriver;

  var 
  mainImage: TImage;
  mainTexture: TTexture;
implementation

uses engine;



procedure DrawSubImageTransparent(var img: image_t;
  dstX, dstY, srcX, srcY, srcWidth, srcHeight: integer);
 var srcRect, dstRect: TRectangle;
begin

    if dstX < 0 then begin
        inc(srcX, -dstX);
        inc(srcWidth, dstX);
        // srcWidth += dstX;
        dstX := 0;
    end;

    if dstY < 0 then begin
      inc(srcY, -dstY);
      inc(srcHeight, dstY);
        // srcY -= dstY;
        // srcHeight += dstY;
        dstY := 0;
    end;


  srcRect.x := srcX; // = {srcX, srcY, srcWidth, srcHeight};
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
end;

procedure DrawLineImpl(x0, y0, x1, y1, r, g, b, a: integer); external;
procedure DrawTextImpl(x, y: integer; str: PChar); external;

procedure DrawSubImageOpaque(var img: image_t;
  dstX, dstY, srcX, srcY, srcWidth, srcHeight: integer);
begin
  DrawSubImageTransparent(img, dstX, dstY, srcX, srcY, srcWidth, srcHeight);
end;

procedure DrawSprite(x, y: integer; var img: image_t);
begin
  // writeln('DrawSprite...');
  DrawSubImageTransparent(img, x, y, 0, 0, img.Width, img.Height);
end;

procedure DrawText(x, y: integer; str: string);
begin
  ImageDrawText(@mainImage, StrToPChar(str), x, y, 12, WHITE);
end;

procedure SwapBuffers;
  var p: TVector2;
begin

  p.x := 0;
  p.y := 0;
  UpdateTexture(mainTexture, mainImage.data);

  DrawTextureEx(mainTexture, p, 0, 3, WHITE);
end;

procedure DrawLine(x0, y0, x1, y1, r, g, b, a: integer);
  var c: TColor;
begin
  c.r := r;
  c.g := g;
  c.b := b;
  c.a := a;
  // DrawLineImpl(x0, y0, x1, y1, r, g, b, a);

      // Color c = {r, g, b, a};
    ImageDrawLine(@mainImage, x0, y0, x1, y1, c);
end;

procedure Init;
begin
  writeln('R_Init');
    mainImage := GenImageColor(320, 240, BLANK);
    mainTexture := LoadTextureFromImage(mainImage);
end;

procedure InitDriver; alias: 'InitDriver';
begin
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
end;   
end.