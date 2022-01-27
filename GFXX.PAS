unit GFXX;
interface

uses GFXCom, Image, Common;

procedure GFX_FillColor(c: byte);

procedure DrawSprite(dstX, dstY: integer; var img: Image_t);

procedure GFXX_Init;
procedure GFXX_Close;
procedure GFXX_SwapBuffers;

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

procedure word_out(_port: integer; register: byte; value: integer);
begin
  { outpw(port,(((word)value<<8) + register)) }

  port[_port] := register;
  port[_port + 1] := value;
end;

procedure set_pixel(x, y: integer; c: byte);
var offset: integer;
begin

  offset := (y * 320 + x) shr 2;
  word_out(SC_INDEX, MAP_MASK, 1 shl (x and 3));

  mem[$A000 : offset] := c;
end;

procedure GFX_FillColor(c: byte);
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

procedure GFXX_SwapBuffers;
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

procedure DrawSprite(dstX, dstY: integer; var img: Image_t);
var subLeft, subRight, subTop, subBottom, numCol, numRow, srcPlane, dstPlane, nc0, nc1, nc2: integer;
var x1: integer;
var x, y, p, o: integer;
var bp: byte_ptr;
begin
    subLeft := 0;  { 5 and 62}
    subRight := img.width;

    subTop := 0;
    subBottom := img.height;

    numRow := (subBottom - subTop);
    dstPlane := dstX and 3;

    x1 := dstX shr 2; {x1 is X pos in plane}

    srcPlane := subLeft and 3;

    for p := 0 to 3 do begin   
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

    for y := 0 to numRow-1 do begin
      for x := 0 to numCol - 1 do begin

        mem[$A000 : o] := bp^;
        inc(o);
        inc(bp);
      end;

      inc(o, 80-numCol);

      inc(bp, 16 - numCol);
    end;

    inc(dstPlane);
    dstPlane := dstPlane and 3;
    if dstPlane = 0 then inc(x1);

    inc(srcPlane);
    srcPlane := srcPlane and 3;
  end;
end;



procedure GFXX_Init;
begin
	GFX_Common_Init;

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

procedure GFXX_Close;
begin
	asm
		mov ax, $3
		int 10h
	end;
end;

begin
end.