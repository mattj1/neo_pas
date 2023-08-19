unit gfx_ext;
{$H+}
interface
procedure InitDriver;
implementation

uses engine;

procedure DrawSubImageTransparent(var img: image_t;
  dstX, dstY, srcX, srcY, srcWidth, srcHeight: integer); external;

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
  DrawTextImpl(x, y, PChar(str));
end;

procedure SwapBuffers;
begin
end;

procedure DrawLine(x0, y0, x1, y1, r, g, b, a: integer);
begin
  DrawLineImpl(x0, y0, x1, y1, r, g, b, a);
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
  // R_Init := Init;
  // R_Close := Close;
end;   
end.