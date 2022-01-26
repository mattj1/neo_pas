{$G+}
unit gfx;

interface

uses crt, image;

type
  Palette = record
    c: array[0..255] of array[0..2] of byte;
  end;

procedure FillColor(c: byte);
procedure FillRect(x, y, w, h: integer; color: byte);
procedure WaitForRetrace;
procedure WaitForRetrace2;
procedure SwapBuffers;
procedure DrawSpriteAlpha(
          dstX, dstY, srcX, srcY, srcWidth, srcHeight, a: integer;
          var img: Image_t);
procedure DrawSprite(x, y: integer; var img: Image_t);
procedure LoadPalette(filename: string; var pal: Palette);
procedure SetPalette(var pal: Palette);

procedure SetPixel(x, y: word; c: integer);

procedure InitGFX;
procedure CloseGFX;

var double_buffer: boolean;

implementation

var
  scrbuf: pointer;

var
  blendlut: ^BlendLUT_t;

var
  cur_pal: Palette;

procedure ClipRect(var x, y, subLeft, subTop, subRight, subBottom: integer);
 var sw: integer;
begin
  sw := subRight - subLeft;

  if x < 0 then begin
      inc(subLeft, -x);
      x := 0;
  end;
  {
  if x + subLeft < 0 then begin
     inc(subLeft, -(x + subLeft));
     x := 0;
  end;
  }
  if subLeft > subRight then Exit;

  sw := subRight - subLeft;


  if x + sw >= 320 then begin
     dec(subRight, (x + sw - 320));
  end;

  if y + subTop < 0 then begin
     inc(subTop, -(y + subTop));
{     inc(subTop, -y);           }
     y := 0;
  end;

  if y + subBottom > 200 then begin
     subBottom := 200 - y;
  end;
end;

procedure LoadPalette(filename: string; var pal: Palette);
var
  palFile: file;
begin
  Assign(palFile, filename);
  Reset(palFile, 1);
  BlockRead(palFile, pal, sizeof(Palette));
  Close(palFile);

end;

procedure FillColor(c: byte);
var destPtr: pointer;
begin
  if double_buffer then begin destPtr := scrBuf; end
  else begin destPtr := Ptr(SegA000, 0); end;
  asm
           les     di, destPtr

           mov     cx, 32000
           mov     al, c
           mov     ah, c
           rep stosw
  end;
end;

procedure WaitForRetrace;
begin
asm
           mov     dx, $03da
           @@1:
           in      al, dx
           test    al, 8
           jz      @@1
end;
end;

{ Wait for next frame?}

procedure WaitForRetrace2;
begin
asm
           mov     dx, $03da
           @@2:
           in      al, dx
           test    al, 8
           jnz     @@2
end;
end;


procedure SwapBuffers;
begin
   if not double_buffer then Exit;

  asm
           mov     dx, $03da
           @@1:
           in      al, dx
           test    al, 8
           jz      @@1

           mov     ax, SegA000
           mov     es, ax
           mov     di, 0

           push ds
           push    si
           lds     si, scrbuf

           mov     cx, 32000
           rep     movsw

           pop     si
           pop     ds

           @@2:
           in      al, dx
           test    al, 8
           jnz     @@2

  end;
end;

procedure FillRect(x, y, w, h: integer; color: byte);
var
  i, j: integer;
var
  left, right, top, bottom: integer;
var
  offs, amount, skip: integer;

var destPtr: pointer;
begin
  left := x;
  if left < 0 then left := 0;

  right := x + w - 1;
  if right > 319 then right := 319;

  top := y;
  if top < 0 then top := 0;

  bottom := y + h - 1;
  if bottom > 199 then bottom := 199;

  offs := top * 320 + left;
  amount := right - left;
  skip := 320 - amount;

  j := bottom - top;

  if double_buffer then begin destPtr := scrBuf; end
  else begin destPtr := Ptr(SegA000, 0); end;

  asm
           les     di, destPtr
           add     di, offs

           mov     cx, j

           mov     ah, 0
           mov     al, color

           @@loop:
           { Draw row }
           push    cx

           mov     cx, amount
           rep     stosb

           add     di, skip
           pop     cx

           loop    @@loop
  end;
end;


procedure DrawSpriteAlpha(
          dstX, dstY, srcX, srcY, srcWidth, srcHeight, a: integer;
          var img: Image_t);
var
  scrX, scrY, offs, spr_offs: integer;
  subLeft, subRight, subTop, subBottom: integer;
  sx, sy: integer;
var
  xi, yi, v: byte;
var
  bp: byte_ptr;
  sprite_bp: byte_ptr;
var
  r, g, b, r1, g1, b1: byte;
var
  o: integer;
begin

  if a < 0 then Exit;
  if a > 15 then Exit;

  subLeft := srcX;
  subRight := srcX + srcWidth;
  subTop := srcY;
  subBottom := srcY + srcHeight;

  ClipRect(dstX, dstY, subLeft, subTop, subRight, subBottom);

  if dstX < 0 then begin
     write('error! ', dstX);
  end;

  if subLeft >= subRight then Exit;

  if (dstX > 319)
     or (dstY > 199)
     or (dstX + (subRight - subLeft) < 0) or (dstY + (subBottom - subTop) < 0)
   then Exit;

  scrY := dstY;
  yi := subBottom - subTop;
  sy := subTop;
  spr_offs := 0;

  repeat
    xi := subRight - subLeft;
    sx := subLeft;

    scrX := dstX;

    bp := scrbuf;
    Inc(bp, scrY * 320 + scrX);

    sprite_bp := img.data;
    inc(sprite_bp, sy * img.width + subLeft);

    repeat
      v := sprite_bp^;

      if (v <> 255) then
      begin
        { Get RGB under current pixel }
        r := cur_pal.c[bp^][0];
        g := cur_pal.c[bp^][1];
        b := cur_pal.c[bp^][2];

        r1 := cur_pal.c[v][0];
        g1 := cur_pal.c[v][1];
        b1 := cur_pal.c[v][2];

        r := blendlut^.multlut[r * 16 + (15 - a)];
        Inc(r, blendlut^.multlut[r1 * 16 + a]);

        g := blendlut^.multlut[g * 16 + (15 - a)];
        Inc(g, blendlut^.multlut[g1 * 16 + a]);

        b := blendlut^.multlut[b * 16 + (15 - a)];
        Inc(b, blendlut^.multlut[b1 * 16 + a]);

        r := blendlut^.downsampleLUT[r];
        g := blendlut^.downsampleLUT[g];
        b := blendlut^.downsampleLUT[b];

        o := b * 256 + g * 16 + r;

        bp^ := blendlut^.lut[o];
      end;
      Inc(sprite_bp);
      Inc(bp);
      Dec(xi);
    until xi = 0;
    Inc(scrY);
    inc(sy);
    Dec(yi);
  until yi = 0;
end;


procedure DrawSprite(x, y: integer; var img: Image_t);
var
  scrX, scrY, offs, spr_offs: integer;
var
  xi, yi, v: byte;

  var bp, scrp: byte_ptr;
  var p2, destPtr: pointer;

  var subLeft, subRight, subTop, subBottom: integer;

  var subWidth, subHeight: integer;
  var rowSkip, subRowSkip: integer;
begin

  if (x > 319) or (y > 199) or (x + img.width < 0) or (y + img.height < 0)
   then Exit;

  if double_buffer then begin destPtr := scrBuf; end
  else begin destPtr := Ptr(SegA000, 0); end;

  subLeft := 0;
  subRight := img.width;
  subTop := 0;
  subBottom := img.height;

  ClipRect(x, y, subLeft, subTop, subRight, subBottom);

  subWidth := subRight - subLeft;
  subHeight := subBottom - subTop;

  rowSkip := 320 - subWidth;
  subRowSkip := img.width - subWidth;

  bp := img.data;
  p2 := img.data;

  inc(bp, subTop * img.Width + subLeft);
  p2 := bp;
{
     scrY := y;
     yi := img.height;

     spr_offs := 0;

     repeat
         xi := img.width;
         scrX := x;
         offs := scrY * 320 + scrX;
         repeat
             v := bp^;
             scrp := destPtr;
             inc(scrp, offs);

             if (v <> 255) then
                scrp^ := v;

             inc(spr_offs);
             inc(offs);
             dec(xi);
             inc(bp);
         until xi = 0;
         inc(scrY);
         dec(yi);
     until yi = 0;

     Exit;

 }
  scrY := y;
  scrX := x;


  asm
           cld
           push    ds
           push    si

           { Get screen buffer offs to di }

           mov     ax, scrY
           shl     ax, 8
           mov     bx, scrY
           shl     bx, 6
           add     ax, bx
           add     ax, scrX

           les     di, destPtr
           add     di, ax

           lds si, p2

           mov     cx, subHeight

           @@y_loop:
           push    cx
           mov     cx, subWidth

           @@x_loop:
           mov     al, ds:[si]
           cmp     al, 255
           je      @@is_transparent

           movsb
           loop @@x_loop

           jmp @@done

           @@is_transparent:
           inc     di
           inc     si

           @@next_loop:
           loop    @@x_loop

           @@done:

           { Move screen offset to next correct x position }
           add     di, rowSkip
           add     si, subRowSkip
           pop     cx
           loop    @@y_loop


           pop     si
           pop     ds
  end;
end;

procedure SetPalette(var pal: Palette);
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

procedure InitGFX;
var
  lutfile: file;
var
  numRead: word;
begin
  GetMem(scrbuf, 64000);
  GetMem(blendLut, sizeof(BlendLUT_t));

  Assign(lutfile, 'lut.dat');
  Reset(lutfile, 1);
  BlockRead(lutFile, blendLut^, sizeof(BlendLUT_t), numRead);
  Close(lutfile);

  double_buffer := true;

  asm
           mov     ax, $13
           int     $10
  end;

end;

procedure CloseGFX;
begin
  asm
           mov     ax, $3
           int     $10
  end;

  FreeMem(scrbuf, 64000);
  FreeMem(blendLut, sizeof(BlendLUT_t));
end;

procedure SetPixel(x, y: word; c: integer);
var bp: byte_ptr;
begin
  bp := scrbuf;
  inc(bp, y * 320 + x);
  bp^ := c;
end;

begin
end.
