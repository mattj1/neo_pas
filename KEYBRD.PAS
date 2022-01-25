uses crt, dos;
procedure KeyClose; forward;

type
 scanCode = byte;

var
  oldKeyInt : Pointer;
  ExitSave: Pointer;
  keyTable: array [0..127] of boolean;

procedure keyISR; interrupt;
var
 k: scanCode;
 b: byte;
begin
     asm
     in al, $60
     mov b, al
     and al, $7F
     mov k, al
     pushF
     call [oldKeyInt]

     end;

     memW[$40 : $1A] := memW[$40 : $1C];

     writeln('got ', k, ' ', b, ' ', (b and 128) = 0);

     keyTable[k] := (b and $80) = 0;

     if k = 28 then begin
        writeln('done...');
        KeyClose;
     end;
end;


procedure KeyInit;
var i: integer;
begin
     for i := 0 to 127 do
         keyTable[i] := False;

     getIntVec(9, oldKeyInt);
     setIntVec(9, @keyISR);
end;

procedure KeyClose;
begin
     setIntVec(9, oldKeyInt);
end;

begin
 clrscr;

 KeyInit;

 readln;

end.