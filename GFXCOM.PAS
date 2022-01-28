unit GFXCom;

interface

type
  Palette = record
    c: array[0..255] of array[0..2] of byte;
  end;

type
  BlendLUT_t = record
    lut: array[0..4095] of byte;
    downsampleLut: array[0..255] of byte;
    multLut: array[0..4095] of byte;
  end;

var
  cur_pal: Palette;

var
  blendlut: ^BlendLUT_t;

procedure GFX_Common_Init;
procedure GFX_LoadPalette(filename: string; var pal: Palette);
procedure GFX_SetPalette(var pal: Palette);
function GFX_ClipRect(var x, y, subLeft, subTop, subRight, subBottom: integer) : boolean;
	
implementation

{ TODO: save the screen height and use it for clipping here }

function GFX_ClipRect(var x, y, subLeft, subTop, subRight, subBottom: integer) : boolean;
var c: integer;
begin
  GFX_ClipRect := false;

  if y >= 240 then Exit;

  if x < 0 then begin
      inc(subLeft, -x);
      x := 0;
  end;

  if subLeft >= subRight then Exit;

  c := subRight - subLeft;

  if x + c >= 320 then begin
     dec(subRight, (x + c - 320));
  end;

  if y < 0 then begin
     inc(subTop, -y);
     y := 0;
  end;

  if subTop >= subBottom then Exit;

  c := subBottom - subTop;

  if y + subBottom >= 240 then begin
     dec(subBottom, (y + c - 240));
  end;

  GFX_ClipRect := true;
end;


procedure GFX_LoadPalette(filename: string; var pal: Palette);
var
  palFile: file;
begin
  Assign(palFile, filename);
  Reset(palFile, 1);
  BlockRead(palFile, pal, sizeof(Palette));
  Close(palFile);

end;

procedure GFX_SetPalette(var pal: Palette);
var
  i: integer;
begin
  cur_pal := pal;
     {for i:= 16 to 47 do begin
        writeln(i, ' ', cur_pal.c[i][0], ' ', cur_pal.c[i][1], ' ', cur_pal.c[i][2]);

        if i = 32 then Readln;
     end;}
{
asm

   mov ax, $1012
   mov bx, 0
   mov cx, 256
   les dx, pal
   int $10
end
}
  port[$3c6] := $ff;
  port[$3c8] := $00;
  for i := 0 to 255 do
  begin
    port[$3c9] := pal.c[i][0] shr 2;
    port[$3c9] := pal.c[i][1] shr 2;
    port[$3c9] := pal.c[i][2] shr 2;

  end;
end;

procedure GFX_Common_Init;
var
  lutfile: file;
begin
  GetMem(blendLut, sizeof(BlendLUT_t));
  
  Assign(lutfile, 'lut.dat');
  Reset(lutfile, 1);
  BlockRead(lutFile, blendLut^, sizeof(BlendLUT_t));
  Close(lutfile);
end;

begin
end.