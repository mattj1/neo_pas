unit Text;

interface

uses Engine, gfx, Image, Timer;

procedure Init(Width, Height: integer);
procedure Close;

procedure DrawString(x, y: byte; str: string);
procedure FillCharAttrib(const ascii_char, attr: byte);
procedure TextBox(x, y, w, h: integer);
procedure SwapBuffers;
procedure ShowCursor;
procedure HideCursor;

procedure WriteCharEx(x, y: integer; ch, color, mask: byte);

procedure Text_FillRectEx(x, y, w, h: integer; ch, color, mask: byte);
procedure Text_DrawStringEx(x, y: byte; str: string; color, mask: byte);
function Text_BufferPtr(x, y: integer): byte_ptr;

procedure Text_ToggleFullscreen;

procedure Text_DrawColorStringEx(x, y: byte; str: string; color, mask: byte);

implementation

uses Math;

var
  scrbuf: pointer;
  pal: array[0..15] of array[0..2] of byte;

var
  text_screen_width, text_screen_height, num_chars: integer;
  isFullScreen: boolean;

procedure HideCursor;
begin

end;

procedure ShowCursor;
begin

end;

procedure FillCharAttrib(const ascii_char, attr: byte);
var
  nc: integer;
begin
  nc := num_chars;

end;

procedure SwapBuffers;
begin
end;

procedure TextWriteRaw(ch, color: byte; o: integer);
var
  bp, fg_p, bg_p: byte_ptr;

begin
  {
  bp := scrbuf;
  Inc(bp, o);
  Inc(fg_p, o);
  Inc(bg_p, o);
  bp^ := ch;
  fg_p^ := color and $f;
  }
end;

function Text_BufferPtr(x, y: integer): byte_ptr;
var
  bp: byte_ptr;

begin
  bp := scrbuf;
  Inc(bp, 2 * (y * text_screen_width + x));
  Text_BufferPtr := bp;
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

procedure Text_FillRectEx(x, y, w, h: integer; ch, color, mask: byte);
var
  bp: byte_ptr;
  i, j: integer;
begin

  for j := y to y + h do
  begin
    for i := x to x + w do
    begin
      WriteCharEx(i, j, ch, color, mask);

    end;
  end;
end;


procedure TextBox(x, y, w, h: integer);
var
  row: integer;
  right: integer;
  i, j: integer;
begin
  row := y;
  right := x + w - 1;

  WriteCharEx(x, y, 201, 15, $ff);
  for i := x + 1 to x + w - 1 do
  begin
    WriteCharEx(i, y, 205, 15, $ff);
  end;

  WriteCharEx(i, y, 187, 15, $ff);

  for row := y + 1 to y + h - 1 do
  begin
    WriteCharEx(x, row, 186, 15, $ff);
    for i := x + 1 to x + w - 1 do
    begin
      WriteCharEx(i, row, 0, 15, $ff);
    end;
    WriteCharEx(x + w - 1, row, 186, 15, $ff);
  end;

  WriteCharEx(x, row, 200, 15, $ff);
  WriteCharEx(right, row, 188, 15, $ff);

  for i := x + 1 to right - 1 do
  begin
    WriteCharEx(i, row, 205, 15, $ff);
  end;
end;

procedure Text_DrawStringEx(x, y: byte; str: string; color, mask: byte);
var
  left, right, i, j: integer;
begin
  j := 1;
  left := x;
  right := x + Length(str) - 1;

  if right > text_screen_width then right := text_screen_width;

  for i := left to right do
  begin
    WriteCharEx(i, y, Ord(str[j]), color, mask);
    j := j + 1;
  end;
end;

procedure Text_DrawColorStringEx(x, y: byte; str: string; color, mask: byte);
var
  left, right, i, j, l: integer;
  src, dst: byte_ptr;
begin
  src := @str;
  inc(src);

  dst := scrbuf;
  Inc(dst, 2 * (y * text_screen_width + x));

  i := 0;
  l := Length(str);
  while (x < text_screen_width) and (i < l) do
  begin
    if ord(src^) = 94 then begin
       inc(src);
       inc(i);
       if (ord(src^) >= 48) and (ord(src^) <= 57) then begin
          color := ord(src^) - 48;
          inc(src);
          inc(i);
          continue;
       end;

       if (ord(src^) >= 65) and (ord(src^) <= 70) then begin
          color := ord(src^) - 55;
          inc(src);
          inc(i);
          continue;
       end;
    end;

    dst^ := src^;
    inc(dst);
    inc(src);

    dst^ := (dst^ and (not mask)) or (color and mask);

    Inc(dst);
    Inc(i);
    Inc(x);
  end;
end;

procedure DrawString(x, y: byte; str: string);
begin
  Text_DrawStringEx(x, y, str, 7, $ff);
end;

procedure Text_SetFullscreen(fs: boolean);
begin

end;

procedure Text_ToggleFullscreen;
begin
  Text_SetFullscreen(not isFullScreen);
end;

procedure Init(Width, Height: integer);

begin

end;

procedure Close;
begin

end;

begin
end.
