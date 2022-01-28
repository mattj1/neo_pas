program Text_TB;

uses
  Crt,
  Text;

var
  i, j: integer;
begin
  Text_Init(132, 60);

  HideCursor;
  ClrScr;
  gotoxy(5, 5);

  for i := 2 to 40 do
  begin
    FillCharAttrib(177, 7);
    TextBox(i, 2, 20, 10);
    TextBox(i + 5, 7, 20, 10);
    DrawString(i + 2, 2, 'HELLO');
    SwapBuffers;

    {delay(15);}

  end;

  TextColor(31);
  Write('Hello World, mem avail: ', MemAvail);

  readln;
  Text_Close;
end.
