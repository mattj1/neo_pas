{ Graphics - DOS }

{$F+}  
{$G+}

unit GFX13;
interface

uses crt, gfx, image, common;

var double_buffer: boolean;

procedure InitDriver;

implementation

var
  scrbuf: pointer;

var cur_pal: Palette;

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

           {mov     cx, 32000
           rep     movsw
}
           mov cx, 16000
           rep
           DB $66; movsw

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


procedure DrawSpriteAlpha2(
          dstX, dstY, srcX, srcY, srcWidth, srcHeight, a: integer;
          var img: Image_t);
var
  scrX, scrY, offs, spr_offs: integer;
  subLeft, subRight, subTop, subBottom: integer;
  sx, sy: integer;
var
  xi, yi: byte;
var current_color, v, one_minus_a: integer;
var
  bp: byte_ptr;
  sprite_bp: byte_ptr;
var
  r, g, b, r1, g1, b1, pixCount: byte;
var
  o: integer;
var pal_color_pointer, multlut_pointer: Pointer;
begin

  if a < 0 then Exit;
  if a > 15 then Exit;

  subLeft := srcX;
  subRight := srcX + srcWidth;
  subTop := srcY;
  subBottom := srcY + srcHeight;

  GFX_ClipRect(dstX, dstY, subLeft, subTop, subRight, subBottom);

  if subLeft >= subRight then Exit;

  if (dstX > 319)
     or (dstY > 199)
     or (dstX + (subRight - subLeft) < 0) or (dstY + (subBottom - subTop) < 0)
   then Exit;

  scrY := dstY;
  yi := subBottom - subTop;
  sy := subTop;
  spr_offs := 0;

  pixCount := a;
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
      current_color := bp^;
{(v <> 255) and }
      if (pixCount = 1) then
      begin
        bp^ := v;
      end;

      dec(pixCount);

      if pixCount = 0 then
        pixCount := a;
      

      Inc(sprite_bp);
      Inc(bp);
      Dec(xi);
    until xi = 0;
    Inc(scrY);
    inc(sy);
    Dec(yi);
  until yi = 0;

end;



procedure DrawSpriteAlpha(
          dstX, dstY, srcX, srcY, srcWidth, srcHeight, a: integer;
          var img: Image_t);
var
  scrX, scrY, offs, spr_offs: integer;
  subLeft, subRight, subTop, subBottom: integer;
  sx, sy: integer;
var
  xi, yi: byte;
var current_color, v, one_minus_a: integer;
var
  bp: byte_ptr;
  sprite_bp: byte_ptr;
var
  r, g, b, r1, g1, b1: byte;
var
  o: integer;
var pal_color_pointer, multlut_pointer: Pointer;
begin

  if a < 0 then Exit;
  if a > 15 then Exit;

  subLeft := srcX;
  subRight := srcX + srcWidth;
  subTop := srcY;
  subBottom := srcY + srcHeight;

  GFX_ClipRect(dstX, dstY, subLeft, subTop, subRight, subBottom);

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

  pal_color_pointer := @cur_pal.c;
  multlut_pointer := @blendlut^.multlut;

  one_minus_a := 15 - a;

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
      current_color := bp^;

      if (v <> 255) then
      begin
        
        v := 3 * v;
        current_color := 3 * current_color;

        asm
            push ds
            push si

          mov ah, 0

          lds si, pal_color_pointer
          mov bx, si
          add si, current_color
          lodsb
          mov r, al
          lodsb
          mov g, al
          lodsb
          mov b, al

          mov si, bx
          add si, v
          lodsb
          mov r1, al
          lodsb
          mov g1, al
          lodsb
          mov b1, al

            mov ah, 0
            mov al, r
            shl ax, 4
            add ax, one_minus_a

            lds si, multlut_pointer
            mov bx, si
            add si, ax
            lodsb
            mov r, al

            { r += multlut[r1 * 16 + a] }
            mov si, bx
            mov ah, 0
            mov al, r1
            shl ax, 4
            add ax, a
            add si, ax
            lodsb
            add r, al

            { GREEN }

            mov ah, 0
            mov al, g
            shl ax, 4
            add ax, one_minus_a

            {lds si, multlut_pointer}
            mov si, bx
            add si, ax
            lodsb
            mov g, al

            { g += multlut[g1 * 16 + a] }
            mov si, bx
            mov ah, 0
            mov al, g1
            shl ax, 4
            add ax, a
            add si, ax
            lodsb
            add g, al

            { BLUE }

            mov ah, 0
            mov al, b
            shl ax, 4
            add ax, one_minus_a

            {lds si, multlut_pointer}
            mov si, bx
            add si, ax
            lodsb
            mov b, al
            
            { b += multlut[b1 * 16 + a] }
            mov si, bx
            mov ah, 0
            mov al, b1
            shl ax, 4
            add ax, a
            add si, ax
            lodsb
            add b, al

            pop si
            pop ds
        end;

        { Get RGB under current pixel }
       (* r := cur_pal.c[bp^][0];
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
        *)

        r := blendlut^.downsampleLUT[r];
        g := blendlut^.downsampleLUT[g];
        b := blendlut^.downsampleLUT[b];

        asm
          mov dx, 0
          mov ah, 0
          mov al, b
          shl ax, 8

          add dx, ax

          mov ah, 0
          mov al, g
          shl ax, 4

          add dx, ax

          mov ah, 0
          mov al, r

          add dx, ax

          mov word ptr o, dx
        end;
        {o := b * 256 + g * 16 + r;}

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


procedure DrawSubImageTransparent(var img: image_t; dstX, dstY, srcX, srcY, srcWidth, srcHeight: integer);
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

 { if (dstX > 319) or (dstY > (screen_height - 1)) or (dstX + img.width < 0) or (dstY + img.height < 0)}
  if (dstX > 319) or (dstY > (screen_height - 1)) or (dstX + srcWidth < 0) or (dstY + srcHeight < 0)
   then Exit;

  if double_buffer then begin destPtr := scrBuf; end
  else begin destPtr := Ptr(SegA000, 0); end;

  subLeft := srcX;
  subRight := srcX + srcWidth;
  subTop := srcY;
  subBottom := srcY + srcHeight;

  GFX_ClipRect(dstX, dstY, subLeft, subTop, subRight, subBottom);

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
  scrY := dstY;
  scrX := dstX;


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
           cmp     al, 0
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

procedure DrawSubImageOpaque(var img: image_t; dstX, dstY, srcX, srcY, srcWidth, srcHeight: integer);      
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
  if (dstX > 319) or (dstY > (screen_height - 1)) or (dstX + img.width < 0) or (dstY + img.height < 0)
   then Exit;

  if double_buffer then begin destPtr := scrBuf; end
  else begin destPtr := Ptr(SegA000, 0); end;

  subLeft := srcX;
  subRight := srcX + srcWidth;
  subTop := srcY;
  subBottom := srcY + srcHeight;

  GFX_ClipRect(dstX, dstY, subLeft, subTop, subRight, subBottom);

  subWidth := subRight - subLeft;
  subHeight := subBottom - subTop;

  rowSkip := 320 - subWidth;
  subRowSkip := img.width - subWidth;

  bp := img.data;
  p2 := img.data;

  inc(bp, subTop * img.Width + subLeft);
  p2 := bp;

  scrY := dstY;
  scrX := dstX;

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

           rep movsb

           { Move screen offset to next correct x position }
           add     di, rowSkip
           add     si, subRowSkip

           pop     cx
           loop    @@y_loop


           pop     si
           pop     ds
  end;  
end;

procedure DrawSprite(x, y: integer; var img: Image_t);
begin
  DrawSubImageTransparent(img, x, y, 0, 0, img.width, img.height);
end;

procedure Init;
var
  numRead: word;
begin
  screen_width := 320;
  screen_height := 200;

  GetMem(scrbuf, screen_width * screen_height);
  
  GFX_Common_Init;

  double_buffer := true;

  asm
           mov     ax, $13
           int     $10
  end;

end;

procedure Close;
begin
  asm
           mov     ax, $3
           int     $10
  end;

  GFX_Common_Close;
  FreeMem(scrbuf, screen_width * screen_height);
end;

procedure SetPixel(x, y: word; c: integer);
var bp: byte_ptr;
begin
  bp := scrbuf;
  inc(bp, y * 320 + x);
  bp^ := c;
end;



procedure LoadPalette(filename: string; var pal: Palette);
var
  palFile: file;
var rawPal: RawPalette;
var i: integer;
begin
  GFX_LoadRawPalette(filename, rawPal);

  for i := 0 to 255 do
  begin
    pal.c[i][0] := rawPal.c[i][0];
    pal.c[i][1] := rawPal.c[i][1];
    pal.c[i][2] := rawPal.c[i][2];
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

procedure AllocPalette(var pal: Palette);
begin

end; 

procedure SetPaletteColor(index: integer; r, g, b: byte);
begin
  cur_pal.c[index][0] := r;
  cur_pal.c[index][1] := g;
  cur_pal.c[index][2] := b;

  { FIX! }
  SetPalette(cur_pal);
end; 


procedure InitDriver;
begin
  R_FillColor := FillColor;
  R_FillRect := FillRect;

  R_DrawSubImageTransparent := DrawSubImageTransparent;
  R_DrawSprite := DrawSprite;
  R_AllocPalette := AllocPalette;
  R_LoadPalette := LoadPalette;
  R_SetPaletteColor := SetPaletteColor;
  R_SetPalette := SetPalette;
  R_SwapBuffers := SwapBuffers;

  R_Init := Init;
  R_Close := Close;
end;   

begin
end.
