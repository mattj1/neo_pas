unit TextLib;

interface
uses crt;
procedure DrawString(x, y: byte; str: string);
procedure FillCharAttrib(const ascii_char, attr: byte);
procedure TextBox(x, y, w, h: integer);
procedure SwapBuffers;
procedure ShowCursor;
procedure HideCursor;

implementation

var
  scrbuf: array[0..3999] of byte;

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

procedure FillCharAttrib(const ascii_char, attr: byte); assembler;
asm
   mov ax, seg scrbuf
   mov es, ax
   mov di, offset scrbuf

   mov al, ascii_char
   mov ah, attr
   mov cx, 2000

   rep stosw
end;


procedure SwapBuffers; assembler;
asm
      mov dx, $03da
      @@1:
          in al, dx
          test al, 8
          jz @@1

      mov ax, SegB800
      mov es, ax
      mov di, 0

      mov ax, seg scrbuf
      mov ds, ax
      mov si, offset scrbuf

      mov cx, 4000
      rep movsb

      @@2:
          in al, dx
          test al, 8
          jnz @@2

end;


procedure TextWriteRaw(ch, color: byte; var o: integer);
begin
  scrbuf[o] := ch;
  Inc(o);
  scrbuf[o] := color;
  Inc(o);
end;

procedure TextBox(x, y, w, h: integer);
var
  o, i, j: integer;
begin
  o := 2 * (y * 80 + x);
  TextWriteRaw(201, 15, o);
  for i := x + 1 to x + w - 1 do
  begin
    TextWriteRaw(205, 15, o);
  end;
  TextWriteRaw(187, 15, o);
  for j := y + 1 to y + h - 1 do
  begin
    o := 2 * (j * 80 + x);
    TextWriteRaw(186, 15, o);
    for i := x + 1 to x + w - 1 do
    begin
      TextWriteRaw(0, 15, o);
    end;
    TextWriteRaw(186, 15, o);
  end;
  o := 2 * ((y + h) * 80 + x);
  TextWriteRaw(200, 15, o);
  for i := x + 1 to x + w - 1 do
  begin
    TextWriteRaw(205, 15, o);
  end;
  TextWriteRaw(188, 15, o);

end;

procedure DrawString(x, y: byte; str: string);
var left, right, i, j, o: Integer;
begin
     j := 1;
     left := x;
     right := x + Length(str) - 1;

     if right > 80 then right := 80;

     o := 2 * (y * 80 + left);

     for i := left to right do begin
         TextWriteRaw(ord(str[j]), 7, o);
         j := j + 1
     end;
end;

begin
end.