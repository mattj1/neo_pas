uses crt, common, keybrd, timer;
var t: integer;
begin
 clrscr;
 Timer.Init;
 Keybrd.Init;

 repeat
 
 until time > 3000;
 
 Keybrd.Close;
 Timer.Close;
end.
