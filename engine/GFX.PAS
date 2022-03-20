unit GFX;

interface

uses Image, Common, R_Pal;


type
  BlendLUT_t = record
    lut: array[0..4095] of byte;
    downsampleLut: array[0..255] of byte;
    multLut: array[0..4095] of byte;
  end;
 

type
  RawPalette = record
    c: array[0..255] of array[0..2] of byte;
  end;

type
  R_DrawSubImageTransparentProc = procedure(var img: image_t;
    dstX, dstY, srcX, srcY, srcWidth, srcHeight: integer);
  R_DrawSubImageOpaqueProc = procedure(var img: image_t;
    dstX, dstY, srcX, srcY, srcWidth, srcHeight: integer);
  R_DrawSpriteProc = procedure(x, y: integer; var img: image_t);
  R_AllocPaletteProc = procedure(var pal: Palette);
  R_LoadPaletteProc = procedure(filename: string; var pal: Palette);
  R_SetPaletteColorProc = procedure(index: integer; r, g, b: byte);
  R_SetPaletteProc = procedure(var pal: Palette);
  R_SwapBuffersProc = procedure;
  R_FillColorProc = procedure(c: byte);
  R_InitProc = procedure;
  R_CloseProc = procedure;

var
  screen_width, screen_height: integer;

var
  blendlut: ^BlendLUT_t;

var
  R_DrawSubImageTransparent: R_DrawSubImageTransparentProc;
  R_DrawSubImageOpaque: R_DrawSubImageOpaqueProc;
  R_DrawSprite: R_DrawSpriteProc;
  R_AllocPalette: R_AllocPaletteProc;
  R_LoadPalette: R_LoadPaletteProc;
  R_SetPaletteColor: R_SetPaletteColorProc;
  R_SetPalette: R_SetPaletteProc;
  R_SwapBuffers: R_SwapBuffersProc;
  R_FillColor: R_FillColorProc;
  R_Init: R_InitProc;
  R_Close: R_CloseProc;

procedure GFX_Common_Init;
procedure GFX_Common_Close;
procedure GFX_LoadRawPalette(filename: string; var pal: RawPalette);

function GFX_ClipRect(var x, y, subLeft, subTop, subRight, subBottom: integer): boolean;

implementation

{ TODO: save the screen height and use it for clipping here }

function GFX_ClipRect(var x, y, subLeft, subTop, subRight, subBottom: integer): boolean;
var
  c: integer;
begin
  GFX_ClipRect := False;

  if y >= screen_height then Exit;

  if x < 0 then
  begin
    Inc(subLeft, -x);
    x := 0;
  end;

  if subLeft >= subRight then Exit;

  c := subRight - subLeft;

  if x + c >= screen_width then
  begin
    Dec(subRight, (x + c - screen_width));
  end;

  if y < 0 then
  begin
    Inc(subTop, -y);
    y := 0;
  end;

  if subTop >= subBottom then Exit;

  c := subBottom - subTop;

  if y + c >= screen_height then
  begin
    Dec(subBottom, (y + c - screen_height));
  end;

  GFX_ClipRect := True;
end;

procedure GFX_Common_Init;
var
  lutfile: file;
begin
  GetMem(blendLut, sizeof(BlendLUT_t));

  {Assign(lutfile, 'lut.dat');
  Reset(lutfile, 1);
  BlockRead(lutFile, blendLut^, sizeof(BlendLUT_t));
  Close(lutfile);}
end;

procedure GFX_Common_Close;
begin
  FreeMem(blendLut, sizeof(BlendLUT_t));
end;

procedure GFX_LoadRawPalette(filename: string; var pal: RawPalette);
var
  palFile: file;
begin
  Assign(palFile, filename);
  Reset(palFile, 1);
  BlockRead(palFile, pal, sizeof(RawPalette));
  Close(palFile);
end;

begin
end.
