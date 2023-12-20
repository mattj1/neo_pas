unit console;

interface
procedure Console_Print(s: string); 
procedure Console_Dump;
implementation
uses Sys, engine;

var msg: array[0..31] of string;

var p: integer;
procedure Console_Print(s: string);
begin
	writeln(s);
	msg[p and 31] := s;

	{Timer_Delay(1000);}

	Inc(p);
end;


procedure Console_Dump;
var i, j: integer;
begin

	for j := (p - 31) to (p - 1) do begin
		if j >= 0 then begin
			writeln(msg[j and 31]); end
	end;
end;

begin
end.