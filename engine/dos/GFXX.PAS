unit GFXX;

{$F+}  
{$G+}

interface

uses crt, gfx, image, common, R_Pal;

procedure InitDriver;

implementation

const SC_INDEX = $3C4;
const SC_DATA = $3C5;

const CRTC_INDEX = $3D4;
const CRTC_DATA = $3D5;

const MAP_MASK = $02;
const MEMORY_MODE = $04;

const H_TOTAL             =$00;
const H_DISPLAY_END       =$01;
const H_BLANK_START       =$02;
const H_BLANK_END         =$03;
const H_RETRACE_START     =$04;
const H_RETRACE_END       =$05;
const V_TOTAL             =$06;
const OVERFLOW            =$07;
const PRESET_ROW_SCAN     =$08;
const MAX_SCAN_LINE       =$09;
const V_RETRACE_START     =$10;
const V_RETRACE_END       =$11;
const V_DISPLAY_END       =$12;
const OFFSET              =$13;
const UNDERLINE_LOCATION  =$14;
const V_BLANK_START       =$15;
const V_BLANK_END         =$16;
const MODE_CONTROL        =$17;

var active_page, visible_page, page_offset: integer;
var cur_pal: Palette;

procedure word_out(_port: integer; register: byte; value: integer);
begin
  { outpw(port,(((word)value<<8) + register)) }

  port[_port] := register;
  port[_port + 1] := value;
end;

procedure set_pixel(x, y: integer; c: byte);
var offset: integer;
begin
  offset := page_offset + y * 80 + (x shr 2);

  word_out(SC_INDEX, MAP_MASK, 1 shl (x and 3));

  mem[$A000 : offset] := c;
end;

procedure FillColor(c: byte);
var o: integer;
var destPtr: pointer;
begin

  destPtr := Ptr(SegA000, page_offset);
  word_out(SC_INDEX, MAP_MASK, 15);

  asm
    les di, destPtr
    mov cx, 9600
    mov al, c
    mov ah, c
    rep stosw
  end;
end;

procedure GFX_SetVisiblePage(page: integer);
var offs: integer;
begin
  visible_page := page;
  offs := page * 19200;

  word_out(CRTC_INDEX, $0C, hi(offs));
  word_out(CRTC_INDEX, $0D, lo(offs));
end;

procedure GFX_SetActivePage(page: integer);
begin
  active_page := page;
  page_offset := active_page * 19200;
end;

procedure SwapBuffers;
begin
      GFX_SetActivePage(active_page xor 1);
      GFX_SetVisiblePage(visible_page xor 1);

      asm
           mov     dx, $03da
           @@1:
           in      al, dx
           test    al, 8
           jz      @@1

           @@2:
           in      al, dx
           test    al, 8
           jnz     @@2
  end;
end;

procedure DrawSubImageTransparent(var img: image_t; dstX, dstY, srcX, srcY, srcWidth, srcHeight: integer);
  var subLeft, subRight, subTop, subBottom: integer;
var numCol, numRow, srcPlane, dstPlane, nc0, nc1, nc2: integer;
var x1: integer;
var x, y, p, o: integer;
var bp: byte_ptr;
var numPlanes: integer;
var srcSkip, dstSkip: word;
var destPtr, srcPtr: pointer;
begin
  if (dstX > 319) or (dstY > (screen_height - 1)) or (dstX + img.width < 0) or (dstY + img.height < 0)
   then Exit;

  subLeft := srcX;
  subRight := srcX + srcWidth;
  subTop := srcY;
  subBottom := srcY + srcHeight;

  GFX_ClipRect(dstX, dstY, subLeft, subTop, subRight, subBottom);


    numRow := (subBottom - subTop);
    dstPlane := dstX and 3;

    x1 := dstX shr 2; {x1 is X pos in plane}

    numPlanes := (subRight - subLeft);
    if numPlanes > 4 then numPlanes := 4;
    if numPlanes = 0 then Exit;

    srcPlane := subLeft and 3;

    for p := 0 to numPlanes - 1 do begin   
    word_out(SC_INDEX, MAP_MASK, 1 shl dstPlane);

    bp := img.data;
    inc(bp, ((img.width shr 2) * img.height) * srcPlane);            {64 >> 2 = 16 per row * 64 rows}

    { Offset into the image plane }
    { should this be srcPlane + p? }
    inc(bp, (subLeft + p) shr 2 + (subTop * (img.width shr 2)));

    { How many columns are we drawing for this plane? }
    { e.g. how many will be memcpy'd for this row? }

    nc0 := ((subLeft + p) shr 2);
    nc1 := ((subRight - srcPlane - 1) shr 2);

    numCol := (nc1 - nc0) + 1;
    {writeln('srcPlane ', srcPlane, 
    ' leftmost ', nc0,
    ' rightmost ', nc1 , 
    ' numCol: ', numCol);
    }
    o := page_offset + dstY * 80 + x1;

    destPtr := Ptr(SegA000, o);
    srcPtr := bp;
    srcSkip := ((img.width shr 2) - numCol);
    dstSkip := (80 - numCol);
    asm

      push ds
      push si

      les di, destPtr
      lds si, srcPtr

      mov cx, numRow

      @@y_loop:

      push cx
      mov cx, numCol

      @@x_loop:
      mov     al, ds:[si]
      cmp     al, 0
      je      @@is_transparent

      movsb
      loop @@x_loop

      jmp @@done

      @@is_transparent:

      inc si
      inc di
      loop @@x_loop

      @@done:
      add si, srcSkip
      add di, dstSkip

      pop cx
      loop @@y_loop

      pop si
      pop ds
    end;

{
    for y := 0 to numRow-1 do begin
      for x := 0 to numCol - 1 do begin

        if bp^ <> 255 then 
          mem[$A000 : o] := bp^;
        inc(o);
        inc(bp);
      end;

      inc(o, 80-numCol);

      inc(bp, 16 - numCol);
    end;
  }

    inc(dstPlane);
    dstPlane := dstPlane and 3;
    if dstPlane = 0 then inc(x1);

    inc(srcPlane);
    srcPlane := srcPlane and 3;
  end;
end;

procedure DrawSprite(x, y: integer; var img: Image_t);
begin
  DrawSubImageTransparent(img, x, y, 0, 0, img.width, img.height);
end;


procedure DrawSubImageOpaque(var img: image_t; dstX, dstY, srcX, srcY, srcWidth, srcHeight: integer);
  var subLeft, subRight, subTop, subBottom: integer;
var numCol, numRow, srcPlane, dstPlane, nc0, nc1, nc2: integer;
var x1: integer;
var x, y, p, o: integer;
var bp: byte_ptr;
var numPlanes: integer;
var srcSkip, dstSkip: word;
var destPtr, srcPtr: pointer;
begin
  if (dstX > 319) or (dstY > (screen_height - 1)) or (dstX + img.width < 0) or (dstY + img.height < 0)
   then Exit;

  subLeft := srcX;
  subRight := srcX + srcWidth;
  subTop := srcY;
  subBottom := srcY + srcHeight;

  GFX_ClipRect(dstX, dstY, subLeft, subTop, subRight, subBottom);

  numRow := (subBottom - subTop);
  dstPlane := dstX and 3;

  x1 := dstX shr 2; {x1 is X pos in plane}

  numPlanes := (subRight - subLeft);
  if numPlanes > 4 then numPlanes := 4;
  if numPlanes = 0 then Exit;

  srcPlane := subLeft and 3;

  for p := 0 to numPlanes - 1 do begin   
    word_out(SC_INDEX, MAP_MASK, 1 shl dstPlane);

    bp := img.data;
    inc(bp, ((img.width shr 2) * img.height) * srcPlane);            {64 >> 2 = 16 per row * 64 rows}

    { Offset into the image plane }
    { should this be srcPlane + p? }
    inc(bp, (subLeft + p) shr 2 + (subTop * (img.width shr 2)));

    { How many columns are we drawing for this plane? }
    { e.g. how many will be memcpy'd for this row? }

    nc0 := ((subLeft + p) shr 2);
    nc1 := ((subRight - srcPlane - 1) shr 2);

    numCol := (nc1 - nc0) + 1;
    {writeln('srcPlane ', srcPlane, 
    ' leftmost ', nc0,
    ' rightmost ', nc1 , 
    ' numCol: ', numCol);
    }
    o := page_offset + dstY * 80 + x1;

    destPtr := Ptr(SegA000, o);
    srcPtr := bp;
    srcSkip := ((img.width shr 2) - numCol);
    dstSkip := (80 - numCol);
    asm        
      push ds
        push si

        les di, destPtr
        lds si, srcPtr

        mov cx, numRow

        @@y_loop:

        push cx
        mov cx, numCol
        rep movsb

        add di, dstSkip
      add si, srcSkip

        pop cx
        loop @@y_loop

        pop si
        pop ds
    end;

    inc(bp, srcSkip);

    inc(dstPlane);
    dstPlane := dstPlane and 3;
    if dstPlane = 0 then inc(x1);

    inc(srcPlane);
  end;
end;


procedure GFX_Line(x0, y0, x1, y1, c: integer);
  var x, y, dx, dy, sx, sy, err, e2: integer;
  begin

  if x1 >= x0 then dx := (x1-x0) else dx := (x0 - x1);
  if y1 >= y0 then dy := (y0-y1) else dy := (y1 - y0);
  if x0 < x1 then sx := 1 else sx := -1;
  if y0 < y1 then sy := 1 else sy := -1;
  
  err := dx + dy;
  x := x0;
  y := y0;

  while true do begin
    set_pixel(x,y,c);
    if (x = x1) and (y = y1) then break;
    e2 := 2 * err;
    if e2 >= dy then begin
      inc(err, dy);
      inc(x, sx);
    end;

    if(e2 <= dx) then begin
      inc(err, dx);
      inc(y, sy)
    end;
  end;
end;

procedure Init;
begin
	GFX_Common_Init;

    screen_width := 320;
  screen_height := 240;

	 asm
	  mov ax, $13
	  int 10h
	end;

	word_out(SC_INDEX, MEMORY_MODE, $06);
	word_out(CRTC_INDEX, UNDERLINE_LOCATION, 0);
	word_out(CRTC_INDEX, MODE_CONTROL, $e3);

	word_out(SC_INDEX, MAP_MASK, 0);

	{ height: 240 or 480}
	word_out(CRTC_INDEX, V_RETRACE_END, $2c);

	word_out(CRTC_INDEX, V_TOTAL, $0d);
	word_out(CRTC_INDEX, OVERFLOW, $3e);
	word_out(CRTC_INDEX, V_RETRACE_START, $ea);
	word_out(CRTC_INDEX, V_RETRACE_END, $ac);
	word_out(CRTC_INDEX, V_DISPLAY_END, $df);
	word_out(CRTC_INDEX, V_BLANK_START, $e7);
	word_out(CRTC_INDEX, V_BLANK_END, $06);

	GFX_SetVisiblePage(0);
	GFX_SetActivePage(1);
end;

procedure Close;
begin
	asm
		mov ax, $3
		int 10h
	end;
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
  R_DrawSubImageTransparent := DrawSubImageTransparent;
  R_DrawSubImageOpaque := DrawSubImageOpaque;
  R_DrawSprite := DrawSprite;
  R_AllocPalette := AllocPalette;
  R_LoadPalette := LoadPalette;
  R_SetPaletteColor := SetPaletteColor;
  R_SetPalette := SetPalette;
  R_SwapBuffers := SwapBuffers;
  R_FillColor := FillColor;
  R_Init := Init;
  R_Close := Close;
end;   

begin
end.