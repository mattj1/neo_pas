unit Text;

interface

uses crt, common;

procedure Init(width, height: integer);
procedure Close;

procedure DrawString(x, y: byte; str: string);
procedure FillCharAttrib(const ascii_char, attr: byte);
procedure TextBox(x, y, w, h: integer);
procedure SwapBuffers;
procedure ShowCursor;
procedure HideCursor;
procedure WriteCharEx(x, y: integer; ch, color, mask: byte);
  
implementation

var
  scrbuf: pointer;

var text_screen_width, text_screen_height, num_chars: integer;

{ https://www.baskent.edu.tr/~tkaracay/etudio/ders/prg/pascal/PasHTM2/pas/pasl2013.html }

procedure HideCursor;
begin
  asm
           MOV     AX,$0100
           MOV     CX,$2607
           INT     $10
  end;
end;

procedure ShowCursor;
begin
  asm
           MOV     AX,$0100
           MOV     CX,$0506
           INT     $10
  end;
end;

procedure FillCharAttrib(const ascii_char, attr: byte);
var nc: integer;
begin
  nc := num_chars;
asm
         les     di, scrbuf

         mov     al, ascii_char
         mov     ah, attr
         mov     cx, nc

         rep     stosw
end;
end;

procedure SwapBuffers;
var nc: integer;
begin
    nc := num_chars;
asm
         mov     dx, $03da
         @@1:
         in      al, dx
         test    al, 8
         jz      @@1

         mov     ax, SegB800
         mov     es, ax
         mov     di, 0

         push    ds
         push    si
         lds     si, scrbuf

         mov     cx, nc
         rep     movsw

         pop     si
         pop     ds

         @@2:
         in      al, dx
         test    al, 8
         jnz     @@2

end;
end;

procedure TextWriteRaw(ch, color: byte; var o: integer);
var
  bp: byte_ptr;
begin
  bp := scrbuf;
  Inc(bp, o);

  bp^ := ch;
  Inc(bp);
  bp^ := color;
  Inc(o, 2);
end;

procedure WriteCharEx(x, y: integer; ch, color, mask: byte);
var
  bp: byte_ptr;
begin
  bp := scrbuf;

  Inc(bp, 2 * (y * text_screen_width + x));
  bp^ := ch;

  Inc(bp);

  bp^ := (bp^ and (not mask)) or (color and mask);
end;  

procedure TextBox(x, y, w, h: integer);
var
  o, i, j: integer;
begin
  o := 2 * (y * text_screen_width + x);
  TextWriteRaw(201, 15, o);
  for i := x + 1 to x + w - 1 do
  begin
    TextWriteRaw(205, 15, o);
  end;
  TextWriteRaw(187, 15, o);
  for j := y + 1 to y + h - 1 do
  begin
    o := 2 * (j * text_screen_width + x);
    TextWriteRaw(186, 15, o);
    for i := x + 1 to x + w - 1 do
    begin
      TextWriteRaw(0, 15, o);
    end;
    TextWriteRaw(186, 15, o);
  end;
  o := 2 * ((y + h) * text_screen_width + x);
  TextWriteRaw(200, 15, o);
  for i := x + 1 to x + w - 1 do
  begin
    TextWriteRaw(205, 15, o);
  end;
  TextWriteRaw(188, 15, o);

end;

procedure DrawString(x, y: byte; str: string);
var
  left, right, i, j, o: integer;
begin
  j := 1;
  left := x;
  right := x + Length(str) - 1;

  if right > text_screen_width then right := text_screen_width;

  o := 2 * (y * text_screen_width + left);

  for i := left to right do
  begin
    TextWriteRaw(Ord(str[j]), 7, o);
    j := j + 1;
  end;
end;

procedure Init(width, height: integer);
var mode, param: integer;
begin
  mode := 0;
  param := 0;

  if (width = 80) and (height = 25) then mode := $3;

  if (width = 80) and (height = 60) then begin
    mode := $4F02; param := $108;
  end;

  if (width = 132) and (height = 25) then begin
    mode := $4F02; param := $109;
  end;

  if (width = 132) and (height = 43) then begin
    mode := $4F02; param := $10A;
  end;

  if (width = 132) and (height = 50) then begin
    mode := $4F02; param := $10B;
  end;

  if (width = 132) and (height = 60) then begin
    mode := $4F02; param := $10B;
  end;

  if mode = 0 then begin
    mode := $3;
    param := 0;
    width := 80;
    height := 25;
  end;

  asm
         mov     ax, mode
         mov     bx, param
         int     $10
  end;

  text_screen_width := width;
  text_screen_height := height;
  
  num_chars := width * height;
  GetMem(scrbuf, 2 * text_screen_width * text_screen_height);
  FillChar(scrbuf^, 2 * text_screen_width * text_screen_height, 0);
end;

procedure Close;
begin
  FreeMem(scrbuf, 2 * text_screen_width * text_screen_height);
  asm
           mov     ax, $3
           int     $10
  end;

  ShowCursor;

  TextColor(7);
  clrscr;
end;

begin
end.
