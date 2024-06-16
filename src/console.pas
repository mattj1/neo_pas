unit console;

interface

procedure Console_Print(s: string);
procedure Console_DrawText;
procedure Console_Dump;
procedure Console_ToggleVisible;
function Console_IsVisible: boolean;
procedure Console_SetWriteStdOut(b: boolean);

implementation

uses strings, text;

var
  msg: array[0..31] of array[0..100] of char;
  p: integer;
  visible: boolean;
  writeStdOut: boolean;

procedure Console_SetWriteStdOut(b: boolean);
begin
  writeStdOut := b;
end;

procedure Console_Print(s: string);
begin
  { TODO: Ensure that the string isn't longer than 100 characters }
  if writeStdOut then writeln(s);
  StrPCopy(msg[p and 31], s);
  Inc(p);
end;


procedure Console_Dump;
var
  j: integer;
begin

  for j := (p - 31) to (p - 1) do
  begin
    if j >= 0 then
    begin
      writeln(msg[j and 31]);
    end;
  end;
end;

procedure Console_DrawText;
var
  i, j: integer;
begin
  if not visible then Exit;

  i := 10;
  Text_FillRectEx(0, 0, 80, 11, 0, 7, $ff);
  for j := (p - 1) downto (p - 31) do
  begin
    if j >= 0 then
    begin
      Text_DrawColorStringEx(0, i, msg[j and 31], 7, $ff);
    end;

    dec(i);
    if i < 0 then break;
  end;

  Text_FillRectEx(0, 11, 80, 1, 205, 7, $ff);
end;

procedure Console_ToggleVisible;
begin
  visible := not visible;
end;

function Console_IsVisible: boolean;
begin
  Console_IsVisible := visible;
end;

begin
end.
